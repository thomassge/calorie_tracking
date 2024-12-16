import 'package:cloud_firestore/cloud_firestore.dart';
//import 'fatsecret_api.dart'; // Füge die FatSecret API-Anbindung ein

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;

  // Benutzerdaten laden und zwischenspeichern
  Future<void> loadUserData(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('Benutzer nicht gefunden');
    }

    _userData = userDoc.data();
    print('Benutzerdaten geladen: $_userData');
  }

  // Berechnung der verbleibenden Kalorien und Makros
  Future<Map<String, dynamic>> calculateRemainingMacros(String userId) async {
    if (_userData == null) {
      await loadUserData(userId);
    }

    final dietType = _userData?['dietType'];
    final calorieGoal = _userData?['calories'];
    final consumedMacros = _userData?['consumedMacros'] ?? {'Protein': 0, 'Carbs': 0, 'Fats': 0};

    final remainingCalories = calorieGoal - (consumedMacros['Protein'] * 4 + consumedMacros['Carbs'] * 4 + consumedMacros['Fats'] * 9);
    final macroDistribution = _calculateMacros(dietType, calorieGoal);

    return {
      'remainingCalories': remainingCalories,
      'remainingMacros': {
        'Protein': macroDistribution['Protein']! - consumedMacros['Protein'],
        'Carbs': macroDistribution['Carbs']! - consumedMacros['Carbs'],
        'Fats': macroDistribution['Fats']! - consumedMacros['Fats'],
      },
    };
  }

  /*
  Erst implementieren, wenn FatSecret API-Anbindung vorhanden




  // Suche nach personalisierten Rezepten
  Future<List<Map<String, dynamic>>> getPersonalizedRecipes(String userId) async {
    if (_userData == null) {
      await loadUserData(userId);
    }

    final remainingData = await calculateRemainingMacros(userId);
    final remainingCalories = remainingData['remainingCalories'];
    final remainingMacros = remainingData['remainingMacros'];

    final inventorySnapshot = await _firestore.collection('users').doc(userId).collection('inventory').get();
    final availableIngredients = inventorySnapshot.docs.map((doc) => doc.id).toList();

    final recipes = await FatSecretAPI.searchRecipes(
      maxCalories: remainingCalories,
      requiredIngredients: availableIngredients,
      dietType: _userData?['dietType'],
    );

    return recipes;
  }




  */


  // Beispiel für eine interne Methode zur Makroverteilung
  Map<String, int> _calculateMacros(String dietType, int calories) {
    switch (dietType) {
      case 'Low-Carb':
        return {'Protein': 30, 'Carbs': 20, 'Fats': 50};
      case 'Keto':
        return {'Protein': 20, 'Carbs': 5, 'Fats': 75};
      case 'High-Protein':
        return {'Protein': 40, 'Carbs': 30, 'Fats': 30};
      default:
        return {'Protein': 30, 'Carbs': 40, 'Fats': 30};
    }
  }
}
