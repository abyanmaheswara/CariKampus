import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'db_helper.dart';
import 'main.dart';
import 'detail_screen.dart';

class University {
  final int id;
  final String name;
  final String shortName;
  final String type;
  final String group;
  final String address;
  final String provinceName;
  final String regencyName;
  final String domain;
  final String webPage;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.group,
    required this.address,
    required this.provinceName,
    required this.regencyName,
    this.domain = '',
    this.webPage = '',
  });

  factory University.fromJson(Map<String, dynamic> json) {
    String name = json['name'] ?? '';
    
    // Guess type from name
    String type = 'Lainnya';
    if (name.toLowerCase().contains('universitas')) type = 'Universitas';
    else if (name.toLowerCase().contains('institut')) type = 'Institut';
    else if (name.toLowerCase().contains('politeknik')) type = 'Politeknik';
    else if (name.toLowerCase().contains('sekolah tinggi')) type = 'Sekolah Tinggi';
    else if (name.toLowerCase().contains('akademi')) type = 'Akademi';

    // Guess shortName from name
    String shortName = '';
    final words = name.split(' ');
    if (words.length >= 2) {
      shortName = words.map((w) => w.isNotEmpty ? w[0] : '').join();
    }

    return University(
      id: 0, // Hipolabs doesn't provide ID
      name: name,
      shortName: shortName,
      type: type,
      group: '-',
      address: '-',
      provinceName: json['state-province'] ?? '-',
      regencyName: '-',
      domain: (json['domains'] as List?)?.isNotEmpty == true ? json['domains'][0] : '',
      webPage: (json['web_pages'] as List?)?.isNotEmpty == true ? json['web_pages'][0] : '',
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
    'Sekolah Tinggi',
    'Akademi'
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
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final universities = data
          .map((item) => University.fromJson(item))
          .toList();
        
        if (!mounted) return;
        setState(() {
          _allData = universities;
          _filteredData = universities;
          _isLoading = false;
        });
        _applyFilter();
      } else {
        throw Exception('Gagal memuat data (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
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
          u.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          u.shortName.toLowerCase().contains(_searchController.text.toLowerCase())
        ).toList();
      }
      
      // Apply category filter
      if (_selectedFilter != 'Semua') {
        filtered = filtered.where((u) =>
          u.type.toLowerCase().contains(_selectedFilter.toLowerCase())
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
      u.type.toLowerCase().contains(filter.toLowerCase())
    ).length;
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
                Text("Tipe: ${university.type}"),
                const SizedBox(height: 8),
                Text("Grup: ${university.group}"),
                const SizedBox(height: 8),
                Text("Alamat: ${university.address}"),
                const SizedBox(height: 8),
                Text("Provinsi: ${university.provinceName}"),
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
                hintText: 'Cari kampus atau singkatan...',
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
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final university = _filteredData[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showDetailDialog(context, university),
                            onLongPress: () => _showOnLongPressDialog(context, university),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  _buildCampusAvatar(university),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                university.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: primaryColor,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: accentColor.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                university.type,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                university.domain,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                ],
                              ),
                            ),
                          ),
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

  void _showDetailDialog(BuildContext context, University university) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Text('Nama: ${university.name}'),
              const SizedBox(height: 8),
              if (university.domain.isNotEmpty) ...[
                Text('Domain: ${university.domain}'),
                const SizedBox(height: 8),
              ],
              if (university.webPage.isNotEmpty) ...[
                Text('Website: ${university.webPage}'),
                const SizedBox(height: 8),
              ],
              Text('Tipe: ${university.type}'),
              const SizedBox(height: 8),
              Text('Kota: ${university.regencyName}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(university: university),
                ),
              ).then((_) => _loadTotalSaved());
            },
            child: const Text('Simpan ke Catatan', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
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

    String getInitials(University u) {
      if (u.shortName.isNotEmpty) {
        return u.shortName.substring(0, u.shortName.length >= 2 ? 2 : 1);
      }
      return u.name[0];
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: color,
      child: university.domain.isNotEmpty
        ? ClipOval(
            child: Image.network(
              'https://www.google.com/s2/favicons?domain=${university.domain}&sz=64',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  getInitials(university).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
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
              getInitials(university).toUpperCase(),
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
