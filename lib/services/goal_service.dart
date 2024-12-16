import 'package:cloud_firestore/cloud_firestore.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Speicherung des Hauptziels in Firestore
  Future<void> saveMainGoal(
      String userId,
      String goalType,
      double startWeight,
      double targetWeightInput,
      String dietType,
      DateTime startDate, {
        int? customCalorieLimit, // Optional für Benutzerdefinierte Diät
        Map<String, int>? customMacros, // Optional für Benutzerdefinierte Diät
      }) async {
    final goalsCollection = _firestore.collection('users').doc(userId).collection('goals');

    // Zielgewicht berechnen: Wenn "Gewicht halten", dann startWeight = targetWeight
    final targetWeight = goalType == 'Gewicht halten' ? startWeight : targetWeightInput;

    // Kalorien- und Makroberechnung
    int calories;
    Map<String, int> macros;

    if (dietType == 'Benutzerdefiniert') {
      // Benutzerdefinierte Diät: Kalorienlimit und Makronährstoffe übernehmen
      if (customCalorieLimit == null || customMacros == null) {
        throw ArgumentError('Für Benutzerdefinierte Diät sind Kalorienlimit und Makronährstoffe erforderlich.');
      }

      // Makronährstoffverteilung prüfen
      final totalPercentage = customMacros.values.reduce((a, b) => a + b);
      if (totalPercentage != 100) {
        throw ArgumentError('Die Makronährstoffverteilung muss insgesamt 100% ergeben.');
      }

      calories = customCalorieLimit;
      macros = customMacros;
    } else {
      // Standarddiät: Kalorien und Makros berechnen
      calories = _calculateCalories(goalType, startWeight, targetWeight);
      macros = _calculateMacros(dietType, calories);
    }

    // Ziel in Firestore speichern
    await goalsCollection.doc('mainGoal').set({
      'goalType': goalType,
      'startWeight': startWeight,
      'targetWeight': targetWeight,
      'dietType': dietType,
      'calories': calories,
      'macros': macros,
      'startDate': startDate.toIso8601String(),
    });

    print('Main Goal gespeichert: $goalType, $targetWeight, $dietType');
  }

// Standard Kalorienberechnung
  int _calculateCalories(String goalType, double startWeight, double targetWeight) {
    const maintenanceCalories = 2000; // Beispielwert
    switch (goalType) {
      case 'Abnehmen':
        return maintenanceCalories - 500;
      case 'Zunehmen':
        return maintenanceCalories + 500;
      case 'Gewicht halten':
      default:
        return maintenanceCalories;
    }
  }

// Standard Makronährstoffberechnung
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

  //Speicherung der Wochenziele
  Future<void> saveWeeklyGoals(
      String userId,
      double startWeight,
      double targetWeight,
      int totalWeeks,
      ) async {

    if (totalWeeks <= 0 || startWeight <= 0 || targetWeight <= 0) {
      throw ArgumentError('Ungültige Eingabewerte für Wochenziele.');
    }

    final goalsCollection = _firestore.collection('users').doc(userId).collection('goals');
    final double weightStep = (startWeight - targetWeight) / totalWeeks;

    for(int i = 1; i <= totalWeeks; i++) {
      double goalWeight = startWeight - (i * weightStep);

      await goalsCollection.doc('week$i').set({
        'week': i,
        'goalWeight': goalWeight,
        'currentWeight': null,
        'progress': null,
      });
      print('Woche $i Zielgewicht gespeichert: $goalWeight kg');
    }
  }

  //Aktualisierung des aktuellen Gewichts und des Fortschritts
  Future<void> updateWeeklyProgress(String userId, int week, double currentWeight) async {
    final weekDocRef = _firestore.collection('users').doc(userId).collection('goals').doc('week$week');

    final docSnapshot = await weekDocRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      double goalWeight = data?['goalWeight'];
      double progress = currentWeight - goalWeight;

      // Zusätzliche Logik für Feedback
      String feedback = '';
      if (progress > 2) {
        feedback = 'Du bist weit über dem Zielgewicht dieser Woche.';
      } else if (progress < -2) {
        feedback = 'Du hast das Zielgewicht dieser Woche weit unterschritten.';
      } else {
        feedback = 'Du bist auf Kurs.';
      }

      await weekDocRef.update({
        'currentWeight': currentWeight,
        'progress': progress,
        'updatedAt': DateTime.now().toIso8601String(), // Zeitstempel hinzufügen
        'feedback': feedback, // Feedback speichern
      });

      print('Woche $week aktualisiert: Gewicht $currentWeight kg, Feedback: $feedback');
    } else {
      print('Keine Daten für Woche $week gefunden.');
    }
  }
}