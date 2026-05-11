import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final fb.FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _auth = fb.FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
  }

  // Get current user
  User? get currentUser {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    return User(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? 'User',
      role: UserRole.viewer,
      permissions: [],
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      lastLogin: fbUser.metadata.lastSignInTime,
    );
  }

  // Auth state stream
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  // Sign up
  Future<User?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      // Define admin emails here
      final adminEmails = ['sowzz@example.com', 'admin@sefrou.com', 'mamzouka.info@gmail.com'];
      final role = adminEmails.contains(email) ? UserRole.admin : UserRole.viewer;

      final user = User(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        permissions: UserPermission.rolePermissions[role] ?? [],
        createdAt: DateTime.now(),
      );

      // Save user to Firestore
      await _firestore.collection('users').doc(user.uid).set(user.toJson());

      return user;
    } on fb.FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      rethrow;
    }
  }

  // Sign in
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }

      return currentUser;
    } on fb.FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      rethrow;
    }
  }

  // Get user by ID
  Future<User?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  // Update user role
  Future<void> updateUserRole(String uid, String role) async {
    try {
      final permissions = UserPermission.rolePermissions[role] ?? [];
      await _firestore.collection('users').doc(uid).update({
        'role': role,
        'permissions': permissions,
      });
    } catch (e) {
      print('Update role error: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      // Delete from Firestore
      await _firestore.collection('users').doc(uid).delete();
      // Note: Deleting from Firebase Auth requires the user to be signed in
      // This should be handled separately if needed
    } catch (e) {
      print('Delete user error: $e');
      rethrow;
    }
  }

  // List all users
  Future<List<User>> listUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => User.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('List users error: $e');
      return [];
    }
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Update last login error: $e');
    }
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('Check user exists error: $e');
      return false;
    }
  }
}
