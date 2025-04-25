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
      home: HomeScreen(),
    );
  }
}

// Add HomeScreen as the main screen that can navigate to BeritaScreen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Energy Monitoring Community'),
        backgroundColor: Color(0xFF0057A3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat Datang di Energy Monitoring Community',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BeritaScreen()),
                );
              },
              child: Text('Lihat Berita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0057A3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsArticle {
  final String id;
  final String title;
  final String content;
  final String? subtitle;
  final String? subtitleContent;
  final String? imageUrl;
  final String category;
  final String? type; // 'full', 'small', 'standard'
  final DateTime createdAt;
  bool isFavorite;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    this.subtitle,
    this.subtitleContent,
    this.imageUrl,
    required this.category,
    this.type = 'standard',
    required this.createdAt,
    this.isFavorite = false,
  });

  factory NewsArticle.fromFirestore(DocumentSnapshot doc, {List<String> favoriteIds = const []}) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NewsArticle(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      subtitle: data['subtitle'],
      subtitleContent: data['subtitleContent'],
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'Uncategorized',
      type: data['type'] ?? 'standard',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      isFavorite: favoriteIds.contains(doc.id),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'subtitle': subtitle,
      'subtitleContent': subtitleContent,
      'imageUrl': imageUrl,
      'category': category,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
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
  String _searchQuery = '';
  List<NewsArticle> _newsArticles = [];
  List<String> _favoriteArticleIds = [];
  bool _isLoading = true;
  String _userId = 'user_charlie'; // In a real app, this would be the authenticated user's ID
  
  final List<String> _tags = [
    'Energi Terbarukan',
    'Tips Hemat Energi',
    'Kebijakan Energi Terbarukan',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final favoritesDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .get();
      
      setState(() {
        _favoriteArticleIds = favoritesDoc.docs.map((doc) => doc.id).toList();
      });
      
      _fetchNewsArticles();
    } catch (e) {
      print('Error fetching favorites: $e');
      _fetchNewsArticles();
    }
  }

  Future<void> _fetchNewsArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot;
      
      if (_selectedCategory == 'Semua Kategori') {
        querySnapshot = await _firestore
            .collection('news')
            .orderBy('createdAt', descending: true)
            .get();
      } else {
        querySnapshot = await _firestore
            .collection('news')
            .where('category', isEqualTo: _selectedCategory)
            .orderBy('createdAt', descending: true)
            .get();
      }

      List<NewsArticle> articles = querySnapshot.docs
          .map((doc) => NewsArticle.fromFirestore(doc, favoriteIds: _favoriteArticleIds))
          .toList();

      // Filter by search query if provided
      if (_searchQuery.isNotEmpty) {
        articles = articles
            .where((article) =>
                article.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                article.content.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      setState(() {
        _newsArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching news articles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(NewsArticle article) async {
    final favoriteRef = _firestore
      .collection('users')
      .doc(_userId)
      .collection('favorites')
      .doc(article.id);

    setState(() {
      article.isFavorite = !article.isFavorite;
      
      if (article.isFavorite) {
        _favoriteArticleIds.add(article.id);
      } else {
        _favoriteArticleIds.remove(article.id);
      }
    });

    try {
      if (article.isFavorite) {
        // Add to favorites
        await favoriteRef.set(article.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artikel ditambahkan ke favorit'))
        );
      } else {
        // Remove from favorites
        await favoriteRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artikel dihapus dari favorit'))
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert state if operation fails
      setState(() {
        article.isFavorite = !article.isFavorite;
        
        if (article.isFavorite) {
          _favoriteArticleIds.add(article.id);
        } else {
          _favoriteArticleIds.remove(article.id);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status favorit'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE d, yyyy').format(now);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen(userId: _userId)),
              );
            },
          ),
        ],
      ),
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
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator())
                  : _newsArticles.isEmpty
                      ? Center(child: Text('Tidak ada berita yang ditemukan'))
                      : _buildNewsList(),
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _fetchNewsArticles();
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final List<String> categories = [
      'Semua Kategori',
      'Dasar Energi',
      'Energi Terbarukan',
      'Tips Hemat Energi',
      'Kebijakan Energi Terbarukan',
    ];

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  onTap: () {
                    setState(() {
                      _selectedCategory = categories[index];
                    });
                    _fetchNewsArticles();
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
      child: Container(
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
            return GestureDetector(
              onTap: () {
                if (tag == 'Energi Terbarukan' || tag == 'Tips Hemat Energi' || tag == 'Kebijakan Energi Terbarukan') {
                  setState(() {
                    _selectedCategory = tag;
                  });
                  _fetchNewsArticles();
                }
              },
              child: Container(
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildNewsList() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _newsArticles.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final article = _newsArticles[index];
        
        if (article.type == 'small') {
          return _buildSmallArticleCard(
            article: article,
          );
        } else if (article.type == 'full') {
          return _buildFullWidthArticleCard(
            article: article,
          );
        } else {
          // Default to standard article layout
          return _buildArticleCard(
            article: article,
            imageAlignment: index % 2 == 0 ? ImageAlignment.right : ImageAlignment.left,
          );
        }
      },
    );
  }

  Widget _buildArticleCard({
    required NewsArticle article,
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
              if (imageAlignment == ImageAlignment.left && article.imageUrl != null)
                _buildImageContainer(article.imageUrl),
              SizedBox(width: imageAlignment == ImageAlignment.left && article.imageUrl != null ? 12 : 0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            article.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: article.isFavorite ? Color(0xFF0057A3) : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(article),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      article.content,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: imageAlignment == ImageAlignment.right && article.imageUrl != null ? 12 : 0),
              if (imageAlignment == ImageAlignment.right && article.imageUrl != null)
                _buildImageContainer(article.imageUrl),
            ],
          ),
          if (article.subtitle != null && article.subtitleContent != null) ...[
            SizedBox(height: 8),
            Text(
              article.subtitle!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              article.subtitleContent!,
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
    required NewsArticle article,
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
                        article.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        article.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: article.isFavorite ? Color(0xFF0057A3) : Colors.grey,
                        size: 18,
                      ),
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _toggleFavorite(article),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  article.content,
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
                image: article.imageUrl != null
                    ? DecorationImage(
                        image: article.imageUrl!.startsWith('http')
                            ? NetworkImage(article.imageUrl!)
                            : AssetImage(article.imageUrl!) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: article.imageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthArticleCard({
    required NewsArticle article,
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
                  article.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  article.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: article.isFavorite ? Color(0xFF0057A3) : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(article),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            article.content,
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
                image: imagePath.startsWith('http')
                    ? NetworkImage(imagePath)
                    : AssetImage(imagePath) as ImageProvider,
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

// Add a new FavoritesScreen to display favorite articles
class FavoritesScreen extends StatefulWidget {
  final String userId;
  
  const FavoritesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<NewsArticle> _favoriteArticles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteArticles();
  }

  Future<void> _fetchFavoriteArticles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('favorites')
          .get();

      List<NewsArticle> articles = [];
      for (var doc in favoritesSnapshot.docs) {
        // Create NewsArticle from the favorite document
        Map<String, dynamic> data = doc.data();
        
        articles.add(NewsArticle(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          subtitle: data['subtitle'],
          subtitleContent: data['subtitleContent'],
          imageUrl: data['imageUrl'],
          category: data['category'] ?? 'Uncategorized',
          type: data['type'] ?? 'standard',
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.now(),
          isFavorite: true,
        ));
      }

      setState(() {
        _favoriteArticles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching favorite articles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(NewsArticle article) async {
    try {
      await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('favorites')
          .doc(article.id)
          .delete();

      setState(() {
        _favoriteArticles.removeWhere((a) => a.id == article.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Artikel dihapus dari favorit'))
      );
    } catch (e) {
      print('Error removing article from favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus artikel dari favorit'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Berita Favorit'),
        backgroundColor: Color(0xFF0057A3),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _favoriteArticles.isEmpty
            ? Center(child: Text('Belum ada artikel favorit'))
            : ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: _favoriteArticles.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final article = _favoriteArticles[index];
                  return _buildFavoriteArticleCard(article);
                },
              ),
    );
  }

  Widget _buildFavoriteArticleCard(NewsArticle article) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: article.imageUrl!.startsWith('http')
                      ? NetworkImage(article.imageUrl!)
                      : AssetImage(article.imageUrl!) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          SizedBox(width: article.imageUrl != null ? 12 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.bookmark,
                        color: Color(0xFF0057A3),
                      ),
                      onPressed: () => _removeFromFavorites(article),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  article.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Kategori: ${article.category}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ImageAlignment {
  left,
  right,
}


