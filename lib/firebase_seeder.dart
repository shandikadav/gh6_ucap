import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/scenario_service.dart';

class FirebaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ScenarioService _scenarioService = ScenarioService();

  /// Seed all initial data to Firestore
  static Future<void> seedAllData() async {
    try {
      print('🌱 Starting Firebase seeding...');
      
      await seedScenarios();
      
      print('✅ Firebase seeding completed successfully!');
    } catch (e) {
      print('❌ Error seeding Firebase: $e');
    }
  }

  /// Seed scenario data
  static Future<void> seedScenarios() async {
    try {
      print('📚 Seeding scenarios...');
      await _scenarioService.seedScenarios();
      print('✅ Scenarios seeded successfully');
    } catch (e) {
      print('❌ Error seeding scenarios: $e');
    }
  }

  /// Clear all seeded data (for testing)
  static Future<void> clearAllData() async {
    try {
      print('🗑️ Clearing all seeded data...');
      
      // Clear scenarios
      final scenariosSnapshot = await _firestore.collection('scenarios').get();
      for (final doc in scenariosSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Clear sample users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('email', whereIn: ['beginner@test.com', 'intermediate@test.com', 'advanced@test.com'])
          .get();
      for (final doc in usersSnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('✅ All seeded data cleared successfully');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}