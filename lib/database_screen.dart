import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'main.dart';

class DatabaseScreen extends StatefulWidget {
  final VoidCallback onHomeTapped;
  final VoidCallback onBackTapped;
  const DatabaseScreen({super.key, required this.onHomeTapped, required this.onBackTapped});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _kampusList = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  Map<String, dynamic>? _lastDeletedItem;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _dbHelper.searchKampus(_searchKeyword);
      if (!mounted) return;
      setState(() {
        _kampusList = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Database: Eksekusi SQLite gagal.\nDetail: $e'),
          backgroundColor: dangerColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showDeleteDialog(Map<String, dynamic> item) {
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
          child: const Text('Hapus Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text('Apakah Anda yakin ingin menghapus data ini?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // Simpan data yang akan dihapus
              _lastDeletedItem = Map.from(item);

              await _dbHelper.deleteKampus(item['id']);
              if (!context.mounted) return;
              Navigator.pop(context);
              _refreshList();

              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data "${item['name']}" dihapus',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: primaryColor,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: accentColor,
                    onPressed: () async {
                      if (_lastDeletedItem != null) {
                        final restored = Map<String, dynamic>.from(
                          _lastDeletedItem!
                        )..remove('id');
                        await _dbHelper.insertKampus(restored);
                        _lastDeletedItem = null;
                        if (!mounted) return;
                        _refreshList();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Data dikembalikan!'),
                            backgroundColor: Color(0xFF00C853),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: dangerColor)),
          ),
        ],
      ),
    );
  }

  void _showFormDialog([Map<String, dynamic>? existingData]) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existingData?['name'] ?? '');
    final domainController = TextEditingController(text: existingData?['domain'] ?? '');
    final webPageController = TextEditingController(text: existingData?['web_page'] ?? '');
    final typeController = TextEditingController(text: existingData?['type'] ?? '');
    final provinceController = TextEditingController(text: existingData?['province_name'] ?? '');
    final catatanController = TextEditingController(text: existingData?['catatan'] ?? '');

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
          child: Text(existingData == null ? 'Tambah Data' : 'Edit Data', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        content: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Nama Kampus'),
                _buildTextField(domainController, 'Domain (ex: ui.ac.id)', isRequired: false),
                _buildTextField(webPageController, 'Website URL', isRequired: false),
                _buildTextField(typeController, 'Tipe (Univ/Inst/Pol)'),
                _buildTextField(provinceController, 'Provinsi'),
                _buildTextField(catatanController, 'Catatan', isRequired: false),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final Map<String, dynamic> data = {
                    'name': nameController.text,
                    'domain': domainController.text,
                    'web_page': webPageController.text,
                    'type': typeController.text,
                    'province_name': provinceController.text,
                    'catatan': catatanController.text,
                  };
                  if (existingData == null) {
                    await _dbHelper.insertKampus(data);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil disimpan!', style: TextStyle(color: primaryColor)), backgroundColor: accentColor),
                    );
                  } else {
                    data['id'] = existingData['id'];
                    await _dbHelper.updateKampus(data);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data berhasil diupdate!', style: TextStyle(color: primaryColor)), backgroundColor: accentColor),
                    );
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshList();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error menyimpan: $e', style: const TextStyle(color: Colors.white)), backgroundColor: dangerColor),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: secondaryColor, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: dangerColor),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: dangerColor, width: 2.0),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Field ini tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCampusAvatar(String name, String shortName, String domain) {
    const colors = [
      Color(0xFF283593), Color(0xFF1565C0),
      Color(0xFF0277BD), Color(0xFF00695C),
      Color(0xFF2E7D32), Color(0xFF558B2F),
      Color(0xFF6A1B9A), Color(0xFF4527A0),
      Color(0xFFAD1457), Color(0xFFC62828),
      Color(0xFFE65100), Color(0xFF4E342E),
    ];
    final color = colors[name.length % colors.length];

    String _getInitials(String n, String sn) {
      if (sn.isNotEmpty) {
        return sn.substring(0, sn.length >= 2 ? 2 : 1);
      }
      return n[0];
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: color,
      child: domain.isNotEmpty
        ? ClipOval(
            child: Image.network(
              'https://www.google.com/s2/favicons?domain=$domain&sz=64',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Center(
                child: Text(
                  _getInitials(name, shortName).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        : Center(
            child: Text(
              _getInitials(name, shortName).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
        title: const Text('Catatan Kampus', style: TextStyle(color: Colors.white)),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        foregroundColor: primaryColor,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari kampus...',
                prefixIcon: const Icon(Icons.search, color: accentColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchKeyword = value);
                _refreshList();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _kampusList.isEmpty
                    ? const Center(child: Text('Tidak ada catatan kampus tersimpan.'))
                    : ListView.builder(
                        itemCount: _kampusList.length,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context, index) {
                          final item = _kampusList[index];
                          String name = item['name'] ?? '';
                          String shortName = item['short_name'] ?? '';
                          String domain = item['domain'] ?? '';
                          String type = item['type'] ?? '';
                          
                          return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: _buildCampusAvatar(name, shortName, domain),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: primaryColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: accentColor.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                type,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                domain,
                                                style: TextStyle(
                                                  fontSize: 10,
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
                                ),
                                Container(
                                  width: 1,
                                  color: Colors.grey[100],
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: accentColor, size: 20),
                                      onPressed: () => _showFormDialog(item),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: dangerColor, size: 20),
                                      onPressed: () => _showDeleteDialog(item),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

