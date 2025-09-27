import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  List<String> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(
            color: Color.fromARGB(239, 107, 141, 252),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _performSearch();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search outfits, styles, brands...',
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF666666)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _searchResults.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
<<<<<<< HEAD
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Casual', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Work', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Formal', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Date', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Exercise', false),
=======
                  _buildFilterChip('All', _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Casual', _selectedFilter == 'Casual'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Work', _selectedFilter == 'Work'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Formal', _selectedFilter == 'Formal'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Date', _selectedFilter == 'Date'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Exercise', _selectedFilter == 'Exercise'),
>>>>>>> origin/moon
                ],
              ),
            ),
          ),
          
          // Search Results
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
<<<<<<< HEAD
        // Handle filter selection
      },
      backgroundColor: const Color(0xFFF8F9FA),
      selectedColor:const Color.fromARGB(239, 107, 141, 252),
=======
        setState(() {
          _selectedFilter = label;
          _performSearch();
        });
      },
      backgroundColor: const Color(0xFFF8F9FA),
      selectedColor: const Color.fromARGB(239, 107, 141, 252),
>>>>>>> origin/moon
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF666666),
        fontWeight: FontWeight.w500,
      ),
    );
  }

<<<<<<< HEAD
=======
  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // Mock search results based on query and filter
    List<String> mockResults = [];
    String searchTerm = _searchQuery.toLowerCase();
    
    // Generate mock outfit URLs based on search query and filter
    for (int i = 1; i <= 8; i++) {
      String outfitType = _selectedFilter.toLowerCase();
      if (outfitType == 'all') {
        outfitType = ['casual', 'work', 'formal', 'date', 'exercise'][i % 5];
      }
      
      // Mock Pexels-style URLs for different outfit types
      String imageUrl = _getMockImageUrl(outfitType, i);
      mockResults.add(imageUrl);
    }
    
    setState(() {
      _searchResults = mockResults;
    });
  }

  String _getMockImageUrl(String outfitType, int index) {
    // Mock URLs that simulate real outfit images
    Map<String, List<String>> outfitImages = {
      'casual': [
        'https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg',
        'https://images.pexels.com/photos/1040945/pexels-photo-1040945.jpeg',
        'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg',
        'https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg',
      ],
      'work': [
        'https://images.pexels.com/photos/1040882/pexels-photo-1040882.jpeg',
        'https://images.pexels.com/photos/1040883/pexels-photo-1040883.jpeg',
        'https://images.pexels.com/photos/1040884/pexels-photo-1040884.jpeg',
        'https://images.pexels.com/photos/1040885/pexels-photo-1040885.jpeg',
      ],
      'formal': [
        'https://images.pexels.com/photos/1040886/pexels-photo-1040886.jpeg',
        'https://images.pexels.com/photos/1040887/pexels-photo-1040887.jpeg',
        'https://images.pexels.com/photos/1040888/pexels-photo-1040888.jpeg',
        'https://images.pexels.com/photos/1040889/pexels-photo-1040889.jpeg',
      ],
      'date': [
        'https://images.pexels.com/photos/1040890/pexels-photo-1040890.jpeg',
        'https://images.pexels.com/photos/1040891/pexels-photo-1040891.jpeg',
        'https://images.pexels.com/photos/1040892/pexels-photo-1040892.jpeg',
        'https://images.pexels.com/photos/1040893/pexels-photo-1040893.jpeg',
      ],
      'exercise': [
        'https://images.pexels.com/photos/1040894/pexels-photo-1040894.jpeg',
        'https://images.pexels.com/photos/1040895/pexels-photo-1040895.jpeg',
        'https://images.pexels.com/photos/1040896/pexels-photo-1040896.jpeg',
        'https://images.pexels.com/photos/1040897/pexels-photo-1040897.jpeg',
      ],
    };
    
    List<String> images = outfitImages[outfitType] ?? outfitImages['casual']!;
    return images[index % images.length];
  }

>>>>>>> origin/moon
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for outfits and styles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find the perfect outfit for any occasion',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
<<<<<<< HEAD
    // Mock search results
=======
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFF666666),
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try different keywords or filters',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

>>>>>>> origin/moon
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
<<<<<<< HEAD
      itemCount: 10, // Mock count
=======
      itemCount: _searchResults.length,
>>>>>>> origin/moon
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
<<<<<<< HEAD
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color:  const Color.fromARGB(239, 107, 141, 252),
=======
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      _searchResults[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: Color(0xFF666666),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(239, 107, 141, 252),
                            ),
                          ),
                        );
                      },
>>>>>>> origin/moon
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
<<<<<<< HEAD
                        'Outfit ${index + 1}',
=======
                        '${_selectedFilter} Outfit ${index + 1}',
>>>>>>> origin/moon
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
<<<<<<< HEAD
                        'Casual Style',
=======
                        '${_selectedFilter} Style',
>>>>>>> origin/moon
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
