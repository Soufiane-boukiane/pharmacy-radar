import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/duty_schedule.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  late final FirebaseFirestore _firestore;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal() {
    _firestore = FirebaseFirestore.instance;
  }

  // Collections
  static const String dutySchedulesCollection = 'duty_schedules';
  static const String pharmaciesCollection = 'pharmacies';
  static const String servicesCollection = 'services';
  static const String settingsCollection = 'pharmacies';
  static const String settingsDocId = '_app_config';

  // Settings
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final doc = await _firestore.collection(settingsCollection).doc(settingsDocId).get();
      if (!doc.exists) {
        // Default settings
        final defaultSettings = {
          'autoMode': false,
          'autoModeStartTime': '22:00',
          'autoModeEndTime': '08:00',
          'timezoneOffset': 1, // GMT+1
        };
        await _firestore.collection(settingsCollection).doc(settingsDocId).set(defaultSettings);
        return defaultSettings;
      }
      return doc.data()!;
    } catch (e) {
      return {
        'autoMode': false,
        'autoModeStartTime': '22:00',
        'autoModeEndTime': '08:00',
        'timezoneOffset': 1,
      };
    }
  }

  Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    await _firestore.collection(settingsCollection).doc(settingsDocId).set(settings, SetOptions(merge: true));
  }

  // Duty Schedules
  Future<List<DutySchedule>> getDutySchedules() async {
    try {
      final snapshot = await _firestore
          .collection(dutySchedulesCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final schedules = snapshot.docs
          .map((doc) => DutySchedule.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in memory to avoid index requirement
      schedules.sort((a, b) => a.startDate.compareTo(b.startDate));
      
      return schedules;
    } catch (e) {
      print('Error fetching duty schedules: $e');
      return [];
    }
  }

  Future<DutySchedule?> getCurrentDutyPharmacy() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(dutySchedulesCollection)
          .where('isActive', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThan: now)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return DutySchedule.fromJson(
            {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      print('Error fetching current duty pharmacy: $e');
      return null;
    }
  }

  Future<void> addDutySchedule(DutySchedule schedule) async {
    try {
      await _firestore
          .collection(dutySchedulesCollection)
          .add(schedule.toJson());
    } catch (e) {
      print('Error adding duty schedule: $e');
      rethrow;
    }
  }

  Future<void> updateDutySchedule(DutySchedule schedule) async {
    try {
      await _firestore
          .collection(dutySchedulesCollection)
          .doc(schedule.id)
          .update(schedule.toJson());
    } catch (e) {
      print('Error updating duty schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteDutySchedule(String scheduleId) async {
    try {
      await _firestore
          .collection(dutySchedulesCollection)
          .doc(scheduleId)
          .delete();
    } catch (e) {
      print('Error deleting duty schedule: $e');
      rethrow;
    }
  }

  // Real-time Duty Schedule Stream
  Stream<List<DutySchedule>> getDutySchedulesStream() {
    return _firestore
        .collection(dutySchedulesCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final schedules = snapshot.docs
          .map((doc) => DutySchedule.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      // Sort in memory
      schedules.sort((a, b) => a.startDate.compareTo(b.startDate));
      return schedules;
    });
  }

  Stream<DutySchedule?> getCurrentDutyPharmacyStream() {
    return _firestore
        .collection(dutySchedulesCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      try {
        final doc = snapshot.docs.firstWhere((doc) {
          final data = doc.data();
          final startDate = DateTime.parse(data['startDate']);
          final endDate = DateTime.parse(data['endDate']);
          return now.isAfter(startDate) && now.isBefore(endDate);
        });
        return DutySchedule.fromJson({...doc.data(), 'id': doc.id});
      } catch (e) {
        return null;
      }
    });
  }

  // Generic Methods
  Future<void> setData(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      print('Error setting data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getData(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.data();
    } catch (e) {
      print('Error getting data: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      print('Error getting collection: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }
}
