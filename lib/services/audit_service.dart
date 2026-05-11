import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_log.dart';

class AuditService {
  static final AuditService _instance = AuditService._internal();
  late final FirebaseFirestore _firestore;

  factory AuditService() {
    return _instance;
  }

  AuditService._internal() {
    _firestore = FirebaseFirestore.instance;
  }

  static const String auditLogsCollection = 'audit_logs';

  // Log admin action
  Future<void> logAction({
    required String userId,
    required String action,
    required Map<String, dynamic> details,
    String? ipAddress,
  }) async {
    try {
      final log = AdminLog(
        id: _firestore.collection(auditLogsCollection).doc().id,
        userId: userId,
        action: action,
        details: details,
        timestamp: DateTime.now(),
        ipAddress: ipAddress,
      );

      await _firestore
          .collection(auditLogsCollection)
          .doc(log.id)
          .set(log.toJson());
    } catch (e) {
      print('Error logging action: $e');
    }
  }

  // Get audit logs
  Future<List<AdminLog>> getAuditLogs({
    int limit = 100,
    String? userId,
    String? action,
  }) async {
    try {
      Query query = _firestore
          .collection(auditLogsCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (action != null) {
        query = query.where('action', isEqualTo: action);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => AdminLog.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting audit logs: $e');
      return [];
    }
  }

  // Get audit logs stream
  Stream<List<AdminLog>> getAuditLogsStream({int limit = 100}) {
    return _firestore
        .collection(auditLogsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                AdminLog.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Delete old audit logs (older than 90 days)
  Future<void> deleteOldLogs({int daysOld = 90}) async {
    try {
      final cutoffDate =
          DateTime.now().subtract(Duration(days: daysOld));

      final snapshot = await _firestore
          .collection(auditLogsCollection)
          .where('timestamp', isLessThan: cutoffDate.toIso8601String())
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting old logs: $e');
    }
  }
}
