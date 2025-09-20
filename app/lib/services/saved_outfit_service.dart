import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/outfit_model.dart';

class SavedOutfitService {
  static const String _savedOutfitsKey = 'saved_outfits';

  // Save outfit to favorites
  static Future<bool> saveOutfit(OutfitModel outfit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOutfits = await getSavedOutfits();
      
      // Check if outfit is already saved
      if (savedOutfits.any((saved) => saved.id == outfit.id)) {
        return true; // Already saved
      }
      
      savedOutfits.add(outfit);
      final jsonList = savedOutfits.map((outfit) => outfit.toJson()).toList();
      await prefs.setString(_savedOutfitsKey, jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error saving outfit: $e');
      return false;
    }
  }

  // Remove outfit from favorites
  static Future<bool> removeOutfit(String outfitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedOutfits = await getSavedOutfits();
      
      savedOutfits.removeWhere((outfit) => outfit.id == outfitId);
      final jsonList = savedOutfits.map((outfit) => outfit.toJson()).toList();
      await prefs.setString(_savedOutfitsKey, jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error removing outfit: $e');
      return false;
    }
  }

  // Get all saved outfits
  static Future<List<OutfitModel>> getSavedOutfits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedOutfitsKey);
      
      if (jsonString == null) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => OutfitModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading saved outfits: $e');
      return [];
    }
  }

  // Check if outfit is saved
  static Future<bool> isOutfitSaved(String outfitId) async {
    try {
      final savedOutfits = await getSavedOutfits();
      return savedOutfits.any((outfit) => outfit.id == outfitId);
    } catch (e) {
      print('Error checking if outfit is saved: $e');
      return false;
    }
  }

  // Toggle outfit save status
  static Future<bool> toggleOutfitSave(OutfitModel outfit) async {
    try {
      final isSaved = await isOutfitSaved(outfit.id);
      
      if (isSaved) {
        return await removeOutfit(outfit.id);
      } else {
        return await saveOutfit(outfit);
      }
    } catch (e) {
      print('Error toggling outfit save: $e');
      return false;
    }
  }

  // Clear all saved outfits
  static Future<bool> clearAllSavedOutfits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedOutfitsKey);
      return true;
    } catch (e) {
      print('Error clearing saved outfits: $e');
      return false;
    }
  }
}
