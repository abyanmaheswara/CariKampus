import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home_screen.dart'; // To access University class and staticUniversityData
import 'main.dart';

class BandingScreen extends StatefulWidget {
  final VoidCallback onHomeTapped;
  final VoidCallback onBackTapped;
  const BandingScreen({super.key, required this.onHomeTapped, required this.onBackTapped});

  @override
  State<BandingScreen> createState() => _BandingScreenState();
}

class _BandingScreenState extends State<BandingScreen> {
  List<University> _allCampuses = [];
  University? _campus1;
  University? _campus2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCampuses();
  }

  Future<void> _loadCampuses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=Indonesia'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final universities = data.map((item) => University.fromJson(item)).toList();
        
        if (!mounted) return;
        setState(() {
          _allCampuses = universities;
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCampusAvatar(University u, {double radius = 25, double fontSize = 16}) {
    const colors = [
      Color(0xFF283593), Color(0xFF1565C0),
      Color(0xFF0277BD), Color(0xFF00695C),
      Color(0xFF2E7D32), Color(0xFF558B2F),
      Color(0xFF6A1B9A), Color(0xFF4527A0),
      Color(0xFFAD1457), Color(0xFFC62828),
      Color(0xFFE65100), Color(0xFF4E342E),
    ];
    final color = colors[u.name.length % colors.length];

    String getInitials(University university) {
      if (university.shortName.isNotEmpty) {
        return university.shortName.substring(0, university.shortName.length >= 2 ? 2 : 1);
      }
      return university.name[0];
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: u.domain.isNotEmpty
        ? ClipOval(
            child: Image.network(
              'https://www.google.com/s2/favicons?domain=${u.domain}&sz=64',
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Center(
                child: Text(
                  getInitials(u).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          )
        : Center(
            child: Text(
              getInitials(u).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
    );
  }

  void _selectCampus(int slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Pilih Kampus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: _allCampuses.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final u = _allCampuses[index];
                    return ListTile(
                      leading: _buildCampusAvatar(u, radius: 20, fontSize: 12),
                      title: Text(u.name, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(u.domain.isNotEmpty ? u.domain : u.type, style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        setState(() {
                          if (slot == 1) {
                            _campus1 = u;
                          } else {
                            _campus2 = u;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Bandingkan Kampus', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackTapped,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: widget.onHomeTapped,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSelector(1, _campus1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 18)),
                    ),
                    Expanded(child: _buildSelector(2, _campus2)),
                  ],
                ),
                const SizedBox(height: 24),
                if (_campus1 != null && _campus2 != null)
                  _buildComparisonTable()
                else
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(Icons.compare_arrows, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('Pilih dua kampus untuk dibandingkan', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildSelector(int slot, University? university) {
    return InkWell(
      onTap: () => _selectCampus(slot),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: university != null ? primaryColor : Colors.grey[300]!, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: university == null 
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.grey, size: 30),
                SizedBox(height: 8),
                Text('Pilih Kampus', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCampusAvatar(university, radius: 25, fontSize: 14),
                  const SizedBox(height: 8),
                  Text(
                    university.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
      ),
    );
  }


  Widget _buildComparisonTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCompareRow('Domain', _campus1!.domain, _campus2!.domain),
            const Divider(),
            _buildCompareRow('Website', _campus1!.webPage, _campus2!.webPage),
            const Divider(),
            _buildCompareRow('Tipe', _campus1!.type, _campus2!.type),
            const Divider(),
            _buildCompareRow('Provinsi', _campus1!.provinceName, _campus2!.provinceName),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareRow(String label, String val1, String val2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(val1.isNotEmpty ? val1 : '-', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
              const SizedBox(width: 20),
              Expanded(child: Text(val2.isNotEmpty ? val2 : '-', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }
}
