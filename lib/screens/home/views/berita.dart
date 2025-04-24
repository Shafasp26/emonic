import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EnergyMonitoringApp());
}

class EnergyMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Monitoring Community',
      theme: ThemeData(
        primaryColor: Color(0xFF0057A3), // Biru tua
        scaffoldBackgroundColor: Color(0xFFEAF6FF), // Biru muda
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0057A3),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFC700), // Kuning
          foregroundColor: Colors.black,
        ),
      ),
      home: EnergyDashboard(),
    );
  }
}

class EnergyDashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bolt, color: Colors.yellow, size: 28),
            SizedBox(width: 8),
            Text(
              'EMONIC',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('news').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final newsDocs = snapshot.data!.docs;

          if (newsDocs.isEmpty) {
            return Center(
              child: Text(
                'Belum ada berita.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: newsDocs.length,
            itemBuilder: (context, index) {
              final data = newsDocs[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Image.network(data['imageUrl'], fit: BoxFit.cover),
                        ),
                      Text(
                        data['content'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(data['title']),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                              Image.network(data['imageUrl']),
                            Text(data['content']),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BeritaScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  void _addNews() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      _firestore.collection('news').add({
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : null,
      });
      _titleController.clear();
      _contentController.clear();
      _imageUrlController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berita berhasil ditambahkan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Berita Energi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Judul Berita'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Konten Berita'),
                  maxLines: 4,
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'Link Gambar Cover (Opsional)'),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _addNews,
                  icon: Icon(Icons.add),
                  label: Text('Tambah Berita'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC700),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
