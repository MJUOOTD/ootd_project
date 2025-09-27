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
                  _buildFilterChip('All', _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Casual', _selectedFilter == 'Casual'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Work', _selectedFilter == 'Work'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Formal', _selectedFilter == 'Formal'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Party', _selectedFilter == 'Party'),
                ],
              ),
            ),
          ),
          
          // Search Results
          Expanded(
            child: _buildSearchResults(),
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
        setState(() {
          _selectedFilter = label;
          _performSearch();
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color.fromARGB(239, 107, 141, 252),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildOutfitCard(_searchResults[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Color(0xFF999999),
          ),
          SizedBox(height: 16),
          Text(
            'Search for outfits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Find your perfect style',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Color(0xFF999999),
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitCard(String outfit) {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  Icons.checkroom,
                  size: 48,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outfit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Perfect for $outfit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    // Mock search results
    List<String> mockResults = [
      'Casual Summer Outfit',
      'Business Professional Look',
      'Evening Party Dress',
      'Weekend Casual Style',
      'Formal Meeting Attire',
      'Date Night Outfit',
      'Gym Workout Clothes',
      'Travel Comfort Look',
    ];

    String searchTerm = _searchQuery.toLowerCase();
    List<String> filteredResults = mockResults.where((outfit) {
      bool matchesSearch = outfit.toLowerCase().contains(searchTerm);
      bool matchesFilter = _selectedFilter == 'All' || 
          outfit.toLowerCase().contains(_selectedFilter.toLowerCase());
      return matchesSearch && matchesFilter;
    }).toList();

    setState(() {
      _searchResults = filteredResults;
    });
  }
}