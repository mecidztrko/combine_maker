import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/image_library.dart';
import 'wardrobe_page.dart';
import 'suggest_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import '../services/ai_service.dart';
import '../services/user_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleCard {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String tag;

  const ArticleCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.tag,
  });
}

class HomePage extends StatefulWidget {
  final AppState appState;
  final ImageLibraryState imageLibraryState;
  final VoidCallback onLogout;
  const HomePage({
    super.key,
    required this.appState,
    required this.imageLibraryState,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final AiAdapter _ai = MockAiAdapter();
  String _userName = '';
  final List<ArticleCard> _articles = const [
    ArticleCard(
      title: 'Minimal İş Kombinleri',
      description: 'Ofiste rahat, şık ve sade görünüm için 5 öneri.',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518',
      url: 'https://www.vogue.com/article/how-to-build-work-wardrobe',
      tag: 'Office',
    ),
    ArticleCard(
      title: 'Hafta Sonu Street Style',
      description: 'Sneaker ve oversize hoodie ile sokak stili ipuçları.',
      imageUrl: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c',
      url: 'https://www.gq.com/story/mens-street-style-looks',
      tag: 'Casual',
    ),
    ArticleCard(
      title: 'Akşam Daveti Şıklığı',
      description: 'Davetler için zamansız kombin önerileri.',
      imageUrl: 'https://images.unsplash.com/photo-1509631179647-0177331693ae',
      url: 'https://www.harpersbazaar.com/fashion/trends/g27447140/evening-outfits/',
      tag: 'Evening',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final profile = await UserPreferences.loadProfile();
    if (mounted) {
      setState(() {
        _userName = profile['firstName'] ?? '';
      });
    }
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Welcome Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    '👋',
                                    style: TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(bounds),
                                      child: Text(
                                        _userName.isNotEmpty 
                                            ? 'Merhaba, $_userName!'
                                            : 'Merhaba!',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Bugün nasıl bir kombin denemek istersin?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.checkroom_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search Styles',
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.tune, color: Colors.grey.shade600),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Quick CTA: Kombin Önerisi Al
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Create tab (index 2)
                    setState(() => _currentIndex = 2);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text('Kombin Önerisi Al'),
                ),
              ),
            ),
            // Latest Styles Section
            _buildArticlesSection(),
            _buildSection('Latest Styles', _getLatestOutfits()),
            // Formal Styles Section
            _buildSection('Formal Styles', _getFormalOutfits()),
            // Classic Styles Section
            _buildSection('Classic Styles', _getClassicOutfits()),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesSection() {
    if (_articles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İlham / Blog', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final article = _articles[index];
                return GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(article.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: Image.network(
                            article.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.image, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      article.tag,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.open_in_new, size: 16, color: Colors.black54),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                article.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<OutfitSuggestion> outfits) {
    if (outfits.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: outfits.length,
              itemBuilder: (context, index) {
                final outfit = outfits[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            color: Colors.grey.shade100,
                          ),
                          child: outfit.items.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    outfit.items.first.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Icon(Icons.image, color: Colors.grey.shade400),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(Icons.image, color: Colors.grey.shade400),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          outfit.purpose,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<OutfitSuggestion> _getLatestOutfits() {
    final outfits = widget.appState.value;
    return outfits.length > 3 ? outfits.sublist(0, 3) : outfits;
  }

  List<OutfitSuggestion> _getFormalOutfits() {
    return widget.appState.value.where((o) => o.purpose.toLowerCase().contains('formal') || 
        o.purpose.toLowerCase().contains('takım')).toList();
  }

  List<OutfitSuggestion> _getClassicOutfits() {
    return widget.appState.value.where((o) => o.purpose.toLowerCase().contains('klasik') || 
        o.purpose.toLowerCase().contains('classic')).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeScreen(),
      WardrobePage(imageLibraryState: widget.imageLibraryState, ai: _ai),
      const SuggestPage(),  // Create tab - Gemini kombin önerisi
      const FavoritesPage(), // Favorites tab - Kaydedilmiş kombinler
      ProfilePage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checkroom_outlined), label: 'Wardrobe'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text('Giriş yaptınız. Çıkış yapmak için aşağıdaki butonu kullanın.',
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
