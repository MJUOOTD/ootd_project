import 'package:flutter/material.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> _savedOutfits = [];

  @override
  void initState() {
    super.initState();
    _loadSavedOutfits();
  }

  void _loadSavedOutfits() {
    // Mock saved outfits data
    setState(() {
      _savedOutfits = [
        {
          'id': '1',
          'title': 'Casual Weekend Look',
          'description': 'Perfect for a relaxed weekend',
          'imageUrl': 'https://via.placeholder.com/300x400',
          'isFavorite': true,
          'date': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': '2',
          'title': 'Professional Work Attire',
          'description': 'Clean and professional look',
          'imageUrl': 'https://via.placeholder.com/300x400',
          'isFavorite': true,
          'date': DateTime.now().subtract(const Duration(days: 5)),
        },
        {
          'id': '3',
          'title': 'Date Night Outfit',
          'description': 'Elegant and stylish',
          'imageUrl': 'https://via.placeholder.com/300x400',
          'isFavorite': true,
          'date': DateTime.now().subtract(const Duration(days: 7)),
        },
      ];
    });
  }

  void _toggleFavorite(String outfitId) {
    setState(() {
      final outfit = _savedOutfits.firstWhere((outfit) => outfit['id'] == outfitId);
      outfit['isFavorite'] = !outfit['isFavorite'];
      
      if (!outfit['isFavorite']) {
        _savedOutfits.removeWhere((outfit) => outfit['id'] == outfitId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Saved Outfits',
          style: TextStyle(
            color: Color(0xFF030213),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: Color(0xFF030213)),
            onPressed: () {
              // Toggle between grid and list view
            },
          ),
        ],
      ),
      body: _savedOutfits.isEmpty
          ? _buildEmptyState()
          : _buildSavedOutfitsGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No saved outfits yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on outfits you like to save them here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home or search
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF030213),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Browse Outfits'),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedOutfitsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _savedOutfits.length,
      itemBuilder: (context, index) {
        final outfit = _savedOutfits[index];
        return _buildOutfitCard(outfit);
      },
    );
  }

  Widget _buildOutfitCard(Map<String, dynamic> outfit) {
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
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(outfit['id']),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        outfit['isFavorite'] ? Icons.favorite : Icons.favorite_outline,
                        color: outfit['isFavorite'] ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
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
                    outfit['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outfit['description'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
