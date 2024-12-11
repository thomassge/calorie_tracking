import 'package:cloud_firestore/cloud_firestore.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Speicherung des Hauptziels in Firestore
  Future<void> saveMainGoal(
      String userId,
      String goalType,
      double startWeight,
      double targetWeight,
      String dietType,
      DateTime startDate,
      ) async {
    final goalsCollection = _firestore.collection('users').doc(userId).collection('goals');

    await goalsCollection.doc('mainGoal').set({
      'goalType': goalType,
      'startWeight': startWeight,
      'targetWeight': targetWeight,
      'dietType': dietType,
      'startDate': startDate.toIso8601String(),
    });
  }

  //Speicherung der Wochenziele
  Future<void> saveWeeklyGoals(
      String userId,
      double startWeight,
      double targetWeight,
      int totalWeeks,
      ) async {
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

      await weekDocRef.update({
        'currentWeight': currentWeight,
        'progress': progress,
      });
    }
  }
}