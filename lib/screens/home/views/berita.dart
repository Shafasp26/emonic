import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EnergyMonitoringApp());
}

class EnergyMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Energy Monitoring Community',
      theme: ThemeData(
        primaryColor: Color(0xFF0057A3),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Sans',
      ),
      home: BeritaScreen(),
    );
  }
}

class BeritaScreen extends StatefulWidget {
  @override
  _BeritaScreenState createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isMainElectricityOn = false;
  String _selectedCategory = 'Semua Kategori';
  
  final List<String> _tags = [
    'Energi Terbarukan',
    'Tips Hemat Energi',
    'Kebijakan Energi Terbarukan',
    'Barang Rumah Tangga yang'
  ];

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE d, yyyy').format(now);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              _buildHeader(formattedDate),
              SizedBox(height: 24),
              _buildNewsTitle(),
              SizedBox(height: 16),
              _buildSearchBar(),
              SizedBox(height: 12),
              _buildCategoryDropdown(),
              SizedBox(height: 16),
              _buildRecommendationTags(),
              SizedBox(height: 16),
              Expanded(
                child: _buildNewsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi Charlie',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'Switch to main electricity',
              style: TextStyle(fontSize: 12),
            ),
            Switch(
              value: _isMainElectricityOn,
              onChanged: (value) {
                setState(() {
                  _isMainElectricityOn = value;
                });
              },
              activeColor: Color(0xFF0057A3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.menu_book, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text(
              'NEWS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.bookmark_border),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCategory,
              style: TextStyle(color: Colors.black87),
            ),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekomendasi :',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.close, size: 12),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNewsList() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildArticleCard(
          title: 'Apa Itu Energi?',
          content:
              'Energi adalah kemampuan untuk melakukan pekerjaan atau menggerakkan sesuatu.',
          subtitle: 'Mengapa kita harus menghemat energi?',
          subtitleContent:
              'Kita perlu menghemat energi karena sumber daya terbatas, mengurangi emisi, mejaga lingkungan, mengurangi biaya, dan melestarikan energi.',
          image: 'assets/energy_illustration.png',
          imageAlignment: ImageAlignment.right,
          showImage: true,
        ),
        Divider(),
        _buildSmallArticleCard(
          title: 'Energi Terbarukan Sumbang Rekor 30% Listrik Global di 2023',
          image: 'assets/renewable_energy.jpg',
          content:
              'Tahun ini sumber energi terbarukan seperti tenaga surya dan angin, menyumbang rekor tertinggi dalam sejarah sebagai sumber listrik di dunia. Data studi global menunjukkan peningkatan investasi di negara-negara seperti Tiongkok, AS, dan Eropa.',
        ),
        Divider(),
        _buildSmallArticleCard(
          title: 'Pemerintah Optimis Tahun 2025 Tercapai',
          image: 'assets/government.jpg',
          content:
              'Pemerintah Indonesia yakin akan di tercapainya target 23% energi terbarukan pada tahun 2025 berkat pembangunan energi baru terbarukan (EBT).',
        ),
        Divider(),
        _buildFullWidthArticleCard(
          title: 'Program Penghematan Energi oleh Pemerintah dan PLN',
          content:
              'Berbagai program diluncurkan oleh Pemerintah dan PLN untuk meningkatkan efisiensi energi pada bangunan pemerintah dan layanan publik, termasuk membangun teknologi pintar untuk pengelolaan energi.',
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String content,
    String? subtitle,
    String? subtitleContent,
    String? image,
    bool showImage = false,
    ImageAlignment imageAlignment = ImageAlignment.left,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageAlignment == ImageAlignment.left && showImage)
                _buildImageContainer(image),
              SizedBox(width: imageAlignment == ImageAlignment.left && showImage ? 12 : 0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: imageAlignment == ImageAlignment.right && showImage ? 12 : 0),
              if (imageAlignment == ImageAlignment.right && showImage)
                _buildImageContainer(image),
            ],
          ),
          if (subtitle != null && subtitleContent != null) ...[
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitleContent,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallArticleCard({
    required String title,
    required String content,
    required String image,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.energy_savings_leaf, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthArticleCard({
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.energy_savings_leaf, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(String? imagePath) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        image: imagePath != null
            ? DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imagePath == null
          ? Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey[400],
              ),
            )
          : null,
    );
  }
}

enum ImageAlignment {
  left,
  right,
}