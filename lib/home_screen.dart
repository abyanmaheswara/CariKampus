import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_helper.dart';
import 'main.dart';
import 'detail_screen.dart';

class University {
  final String name;
  final String country;
  final String domain;
  final String webPage;

  University({
    required this.name,
    required this.country,
    required this.domain,
    required this.webPage,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    final domains = List<String>.from(json['domains'] ?? []);
    final webPages = List<String>.from(json['web_pages'] ?? []);
    return University(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      domain: domains.isNotEmpty ? domains[0] : '',
      webPage: webPages.isNotEmpty ? webPages[0] : '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<University> _allData = [];
  List<University> _filteredData = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'Universitas',
    'Institut',
    'Politeknik',
    'Akademi',
    'Sekolah Tinggi'
  ];

  int _totalSaved = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTotalSaved();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=Indonesia'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List jsonBody = json.decode(response.body);
        final data = jsonBody.map((item) => University.fromJson(item)).toList();
        if (!mounted) return;
        setState(() {
          _allData = data;
          _isLoading = false;
        });
        _applyFilter();
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      List<University> filtered = _allData;
      
      // Apply keyword search
      if (_searchController.text.isNotEmpty) {
        filtered = filtered.where((u) =>
          u.name.toLowerCase().contains(
            _searchController.text.toLowerCase()) ||
          u.domain.toLowerCase().contains(
            _searchController.text.toLowerCase())
        ).toList();
      }
      
      // Apply category filter
      if (_selectedFilter != 'Semua') {
        filtered = filtered.where((u) =>
          u.name.toLowerCase().contains(
            _selectedFilter.toLowerCase())
        ).toList();
      }
      
      _filteredData = filtered;
    });
  }

  void _onSearchChanged(String keyword) {
    _applyFilter();
  }

  Future<void> _loadTotalSaved() async {
    final db = DBHelper();
    final data = await db.getAllKampus();
    if (!mounted) return;
    setState(() {
      _totalSaved = data.length;
    });
  }

  int _countByFilter(String filter) {
    if (filter == 'Semua') return _allData.length;
    return _allData.where((u) =>
      u.name.toLowerCase().contains(filter.toLowerCase())
    ).length;
  }

  void _simpanKeCatatan(University university) async {
    final dbHelper = DBHelper();
    final data = {
      'name': university.name,
      'domain': university.domain,
      'web_page': university.webPage,
      'country': university.country,
      'catatan': '',
    };
    await dbHelper.insertKampus(data);
    await _loadTotalSaved();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil disimpan!', style: TextStyle(color: primaryColor)),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOnTapDialog(BuildContext context, University university) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text('Info Kampus', style: TextStyle(color: Colors.white)),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nama: ${university.name}"),
                const SizedBox(height: 8),
                Text("Domain: ${university.domain}"),
                const SizedBox(height: 8),
                Text("Website: ${university.webPage}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _simpanKeCatatan(university);
                Navigator.of(context).pop();
              },
              child: const Text('Simpan ke Catatan', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showOnLongPressDialog(BuildContext context, University university) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text('Detail Kampus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nama: ${university.name}"),
                const Divider(color: surfaceColor),
                Text("Negara: ${university.country}"),
                const SizedBox(height: 8),
                Text("Domain: ${university.domain}"),
                const SizedBox(height: 8),
                Text("Website: ${university.webPage}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('CariKampus', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kampus atau domain...',
                prefixIcon: const Icon(Icons.search, color: accentColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildStatCard(
                  'Total Kampus',
                  '${_allData.length}',
                  Icons.account_balance,
                  const Color(0xFF283593),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Hasil Cari',
                  '${_filteredData.length}',
                  Icons.search,
                  const Color(0xFF3949AB),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  'Tersimpan',
                  '$_totalSaved',
                  Icons.bookmark,
                  const Color(0xFFFFC107),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: _filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      '$filter (${_countByFilter(filter)})',
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: _selectedFilter == filter,
                    selectedColor: accentColor,
                    backgroundColor: surfaceColor,
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter ? primaryColor : Colors.black87,
                      fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        _applyFilter();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Align(
               alignment: Alignment.centerLeft,
               child: Text(
                 '${_filteredData.length} kampus ditemukan',
                 style: const TextStyle(
                   color: Color(0xFF283593),
                   fontSize: 12,
                   fontWeight: FontWeight.w500,
                 ),
               ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: primaryColor),
                        SizedBox(height: 16),
                        Text("Memuat data kampus...", style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  );
                }

                if (_errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: dangerColor),
                        const SizedBox(height: 16),
                        Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: dangerColor)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadData,
                          child: const Text("Coba Lagi", style: TextStyle(color: primaryColor)),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredData.isEmpty && _allData.isNotEmpty) {
                  return const Center(child: Text("Kampus tidak ditemukan", style: TextStyle(color: Colors.grey)));
                }

                return RefreshIndicator(
                  color: const Color(0xFF283593),
                  backgroundColor: const Color(0xFFFFC107),
                  onRefresh: () async {
                    await _loadData();
                    await _loadTotalSaved();
                    _searchController.clear();
                    setState(() {
                      _selectedFilter = 'Semua';
                    });
                  },
                  child: ListView.separated(
                    itemCount: _filteredData.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final university = _filteredData[index];

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          leading: _buildCampusAvatar(university),
                          title: Text(
                            university.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(university.domain.isNotEmpty ? university.domain : 'Tidak ada domain', style: const TextStyle(fontSize: 12)),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: accentColor, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(university: university),
                              ),
                            );
                          },
                          onLongPress: () => _showOnLongPressDialog(context, university),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF283593),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusAvatar(University university) {
    const colors = [
      Color(0xFF283593), Color(0xFF1565C0),
      Color(0xFF0277BD), Color(0xFF00695C),
      Color(0xFF2E7D32), Color(0xFF558B2F),
      Color(0xFF6A1B9A), Color(0xFF4527A0),
      Color(0xFFAD1457), Color(0xFFC62828),
      Color(0xFFE65100), Color(0xFF4E342E),
    ];
    final color = colors[university.name.length % colors.length];

    String _getInitials(String name) {
      final words = name.split(' ');
      if (words.length >= 2) {
        return '${words[0][0]}${words[1][0]}';
      }
      return name.substring(0, name.length >= 2 ? 2 : 1);
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: color,
      child: university.domain.isNotEmpty
        ? ClipOval(
            child: Image.network(
              'https://www.google.com/s2/favicons'
              '?domain=${university.domain}&sz=64',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Center(
                  child: Text(
                    _getInitials(university.name).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          )
        : Center(
            child: Text(
              _getInitials(university.name).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
    );
  }
}
