import 'package:flutter/material.dart';
import 'main.dart';

class ProfilScreen extends StatelessWidget {
  final VoidCallback onHomeTapped;
  final VoidCallback onBackTapped;
  const ProfilScreen({super.key, required this.onHomeTapped, required this.onBackTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBackTapped,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: onHomeTapped,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF283593),
                  Color(0xFF3949AB),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        titlePadding: EdgeInsets.zero,
                        title: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF283593),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: const Text(
                            'Identitas Mahasiswa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NIM: 224443024'),
                            SizedBox(height: 8),
                            Text('Nama: Abyan Maheswara'),
                            SizedBox(height: 8),
                            Text('Jurusan: Teknik Otomasi Manufaktur dan Mekatronika'),
                            SizedBox(height: 8),
                            Text('Prodi: Teknologi Rekayasa Informatika Industri'),
                            SizedBox(height: 8),
                            Text('Email: 224443024@mhs.polman-bandung.ac.id'),
                            SizedBox(height: 8),
                            Text('Github: github.com/abyanmaheswara'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup',
                              style: TextStyle(
                                color: Color(0xFF283593),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/foto_profil.jpg'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Abyan Maheswara',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '224443024',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Details Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildListTile(Icons.badge, 'NIM', '224443024'),
                        const Divider(height: 1, color: surfaceColor),
                        _buildListTile(Icons.person, 'Nama', 'Abyan Maheswara'),
                        const Divider(height: 1, color: surfaceColor),
                        _buildListTile(Icons.engineering, 'Jurusan', 'Teknik Otomasi Manufaktur dan Mekatronika'),
                        const Divider(height: 1, color: surfaceColor),
                        _buildListTile(Icons.computer, 'Program Studi', 'Teknologi Rekayasa Informatika Industri'),
                        const Divider(height: 1, color: surfaceColor),
                        _buildListTile(Icons.email, 'Email', '224443024@mhs.polman-bandung.ac.id'),
                        const Divider(height: 1, color: surfaceColor),
                        _buildListTile(Icons.link, 'Github', 'github.com/abyanmaheswara'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Logos Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo_pddikti.png', width: 40, height: 40, fit: BoxFit.contain),
                      const SizedBox(width: 16),
                      Image.asset('assets/images/polman_logo_transparent.png', width: 40, height: 40, fit: BoxFit.contain),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Watermark Area
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                Text('Sumber: PDDikti Kemendiktisaintek | Politeknik Manufaktur Bandung', style: TextStyle(color: Colors.grey, fontSize: 10)),
                SizedBox(height: 4),
                Text('API: Hipolabs Universities API', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: accentColor),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
    );
  }
}
