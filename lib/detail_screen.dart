import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'main.dart'; // for primaryColor, secondaryColor, accentColor, bgColor, surfaceColor
import 'db_helper.dart';

class DetailScreen extends StatelessWidget {
  final University university;
  
  const DetailScreen({super.key, required this.university});

  void _simpanKeCatatan(BuildContext context) async {
    final dbHelper = DBHelper();
    final data = {
      'name': university.name,
      'domain': university.domain,
      'web_page': university.webPage,
      'country': university.country,
      'catatan': '',
    };
    await dbHelper.insertKampus(data);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil disimpan!', style: TextStyle(color: primaryColor)),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(university.name, style: const TextStyle(fontSize: 16)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            tooltip: 'Simpan ke Catatan',
            onPressed: () => _simpanKeCatatan(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      const colors = [
                        Color(0xFF283593), Color(0xFF1565C0),
                        Color(0xFF0277BD), Color(0xFF00695C),
                        Color(0xFF2E7D32), Color(0xFF558B2F),
                        Color(0xFF6A1B9A), Color(0xFF4527A0),
                        Color(0xFFAD1457), Color(0xFFC62828),
                        Color(0xFFE65100), Color(0xFF4E342E),
                      ];
                      final color = colors[university.name.length % colors.length];
                      
                      String getInitials(String name) {
                        final words = name.split(' ');
                        if (words.length >= 2) {
                          return '${words[0][0]}${words[1][0]}';
                        }
                        return name.substring(0, name.length >= 2 ? 2 : 1);
                      }

                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: color,
                        child: university.domain.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                'https://www.google.com/s2/favicons?domain=${university.domain}&sz=128',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    getInitials(university.name).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                    ),
                                  ),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
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
                                getInitials(university.name).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    university.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.public, color: accentColor),
                      title: const Text('Domain', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        university.domain.isNotEmpty ? university.domain : '-', 
                        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)
                      ),
                    ),
                    const Divider(height: 1, color: surfaceColor),
                    ListTile(
                      leading: const Icon(Icons.language, color: accentColor),
                      title: const Text('Website', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        university.webPage.isNotEmpty ? university.webPage : '-', 
                        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)
                      ),
                    ),
                    const Divider(height: 1, color: surfaceColor),
                    ListTile(
                      leading: const Icon(Icons.flag, color: accentColor),
                      title: const Text('Negara', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(
                        university.country.isNotEmpty ? university.country : '-', 
                        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _simpanKeCatatan(context),
              icon: const Icon(Icons.bookmark_add),
              label: const Text('Simpan ke Catatan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
