class User {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.permissions,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: (json['role'] as String?)?.toUpperCase() ?? 'VIEWER',
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isManager => role.toUpperCase() == 'MANAGER';
  bool get isViewer => role.toUpperCase() == 'VIEWER';
}

// Role definitions
class UserRole {
  static const String admin = 'ADMIN';
  static const String manager = 'MANAGER';
  static const String viewer = 'VIEWER';

  static const List<String> all = [admin, manager, viewer];
}

// Permission definitions
class UserPermission {
  static const String manageDuty = 'manage_duty';
  static const String managePharmacy = 'manage_pharmacy';
  static const String manageUsers = 'manage_users';
  static const String viewAnalytics = 'view_analytics';

  static const Map<String, List<String>> rolePermissions = {
    UserRole.admin: [
      manageDuty,
      managePharmacy,
      manageUsers,
      viewAnalytics,
    ],
    UserRole.manager: [
      manageDuty,
      managePharmacy,
      viewAnalytics,
    ],
    UserRole.viewer: [
      viewAnalytics,
    ],
  };
}
