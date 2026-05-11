class AdminLog {
  final String id;
  final String userId;
  final String action;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final String? ipAddress;

  AdminLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.details,
    required this.timestamp,
    this.ipAddress,
  });

  factory AdminLog.fromJson(Map<String, dynamic> json) {
    return AdminLog(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      action: json['action'] ?? '',
      details: json['details'] ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      ipAddress: json['ipAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'action': action,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
    };
  }
}

// Action types
class AdminAction {
  static const String createDuty = 'CREATE_DUTY_SCHEDULE';
  static const String updateDuty = 'UPDATE_DUTY_SCHEDULE';
  static const String deleteDuty = 'DELETE_DUTY_SCHEDULE';
  static const String createPharmacy = 'CREATE_PHARMACY';
  static const String updatePharmacy = 'UPDATE_PHARMACY';
  static const String deletePharmacy = 'DELETE_PHARMACY';
  static const String createUser = 'CREATE_USER';
  static const String updateUserRole = 'UPDATE_USER_ROLE';
  static const String deleteUser = 'DELETE_USER';
  static const String adminLogin = 'ADMIN_LOGIN';
  static const String adminLogout = 'ADMIN_LOGOUT';
}
