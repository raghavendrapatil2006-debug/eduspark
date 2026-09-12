import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/models/user_model.dart';
import 'user_profile_service.dart';

class AuthResponse {
  final bool success;
  final String message;
  final UserModel? user;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
  });
}

class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _userStorageKey = 'eduspark_auth_user';
  static const String _defaultStudentEmail = 'raghavendra@eduspark.ai';
  static const String _defaultTeacherEmail = 'faculty@eduspark.ai';

  UserModel? _currentUser;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isTeacher => _currentUser?.isTeacher ?? false;

  /// Initialize and restore user session from local storage.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userStorageKey);

      if (userJson != null && userJson.isNotEmpty) {
        _currentUser = UserModel.fromJson(userJson);
        _syncToUserProfileService(_currentUser!);
      }
    } catch (e) {
      debugPrint('AuthService init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Sign in with Email and Password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
    String role = 'student',
  }) async {
    // Artificial latency for realistic network feel
    await Future.delayed(const Duration(milliseconds: 700));

    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return const AuthResponse(
        success: false,
        message: 'Please enter a valid email address.',
      );
    }

    if (cleanPassword.length < 6) {
      return const AuthResponse(
        success: false,
        message: 'Password must be at least 6 characters long.',
      );
    }

    // Determine user name from email prefix or preset
    String name = cleanEmail.split('@').first;
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    // Assign role-specific defaults if not configured
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanEmail == _defaultTeacherEmail ? 'Prof. Raghavendra' : name,
      email: cleanEmail,
      role: role.toLowerCase(),
      standard: role.toLowerCase() == 'student'
          ? 'B.Tech Computer Science & Engineering (CSE)'
          : null,
      specialization: role.toLowerCase() == 'teacher'
          ? 'Computer Science & Engineering'
          : null,
      school: role.toLowerCase() == 'student'
          ? 'University Institute of Technology'
          : 'Institute of Technology & Advanced Studies',
      createdAt: DateTime.now(),
    );

    await _persistSession(user);
    return AuthResponse(
      success: true,
      message: 'Welcome back, ${user.name}!',
      user: user,
    );
  }

  /// Register a new account
  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? standard,
    String? board,
    String? school,
    String? specialization,
    String? phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      return const AuthResponse(
        success: false,
        message: 'Please enter your full name.',
      );
    }

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return const AuthResponse(
        success: false,
        message: 'Please provide a valid email address.',
      );
    }

    if (cleanPassword.length < 6) {
      return const AuthResponse(
        success: false,
        message: 'Password must be at least 6 characters.',
      );
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      email: cleanEmail,
      role: role.toLowerCase(),
      standard: standard ?? (role == 'student' ? '8th Standard' : null),
      board: board ?? (role == 'student' ? 'CBSE' : null),
      school: school ?? 'EduSpark Academy',
      specialization: specialization,
      phone: phone,
      createdAt: DateTime.now(),
    );

    await _persistSession(user);
    return AuthResponse(
      success: true,
      message: 'Account created successfully! Welcome to EduSpark.',
      user: user,
    );
  }

  /// Sign in with Phone Number and 6-Digit OTP
  Future<AuthResponse> signInWithPhoneOtp({
    required String phone,
    required String otp,
    String role = 'student',
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));

    final cleanPhone = phone.trim();
    final cleanOtp = otp.trim();

    if (cleanPhone.length < 10) {
      return const AuthResponse(
        success: false,
        message: 'Please enter a valid 10-digit mobile number.',
      );
    }

    if (cleanOtp.length != 6) {
      return const AuthResponse(
        success: false,
        message: 'Please enter the 6-digit OTP code sent to your phone.',
      );
    }

    final user = UserModel(
      id: 'usr_otp_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Scholar (+${cleanPhone.substring(cleanPhone.length - 4)})',
      email: 'mobile.$cleanPhone@eduspark.ai',
      phone: cleanPhone,
      role: role.toLowerCase(),
      standard: role.toLowerCase() == 'student'
          ? 'B.Tech Computer Science & Engineering (CSE)'
          : null,
      specialization: role.toLowerCase() == 'teacher' ? 'Computer Science & Engineering' : null,
      school: 'University Institute of Technology',
      createdAt: DateTime.now(),
    );

    await _persistSession(user);
    return AuthResponse(
      success: true,
      message: 'Mobile verification verified successfully!',
      user: user,
    );
  }

  /// Sign in with Google One-Tap
  Future<AuthResponse> signInWithGoogle({String role = 'student'}) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final user = UserModel(
      id: 'usr_g_${DateTime.now().millisecondsSinceEpoch}',
      name: role.toLowerCase() == 'teacher' ? 'Prof. Raghavendra' : 'Raghavendra',
      email: role.toLowerCase() == 'teacher'
          ? 'faculty@eduspark.ai'
          : 'raghavendra@eduspark.ai',
      role: role.toLowerCase(),
      standard: role.toLowerCase() == 'student'
          ? 'B.Tech Computer Science & Engineering (CSE)'
          : null,
      specialization:
          role.toLowerCase() == 'teacher' ? 'Computer Science & Engineering' : null,
      school: role.toLowerCase() == 'teacher'
          ? 'Institute of Technology & Advanced Studies'
          : 'University Institute of Technology',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      createdAt: DateTime.now(),
    );

    await _persistSession(user);
    return AuthResponse(
      success: true,
      message: 'Google Sign-In authenticated successfully.',
      user: user,
    );
  }

  /// Quick Access Sign-In
  Future<AuthResponse> signInDemo({required String role}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final isTeacherRole = role.toLowerCase() == 'teacher';
    final user = UserModel(
      id: 'usr_${isTeacherRole ? "faculty" : "student"}_001',
      name: isTeacherRole ? 'Prof. Raghavendra' : 'Raghavendra',
      email: isTeacherRole ? _defaultTeacherEmail : _defaultStudentEmail,
      role: isTeacherRole ? 'teacher' : 'student',
      standard: isTeacherRole ? null : 'B.Tech Computer Science & Engineering (CSE)',
      board: isTeacherRole ? null : 'State Technological University',
      school: isTeacherRole
          ? 'Institute of Technology & Advanced Studies'
          : 'University Institute of Technology',
      specialization: isTeacherRole ? 'Computer Science & Engineering' : null,
      isDemo: false,
      createdAt: DateTime.now(),
    );

    await _persistSession(user);
    return AuthResponse(
      success: true,
      message: 'Signed in successfully!',
      user: user,
    );
  }

  /// Reset Password Request
  Future<AuthResponse> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final clean = email.trim();

    if (clean.isEmpty || !clean.contains('@')) {
      return const AuthResponse(
        success: false,
        message: 'Please enter a valid email address.',
      );
    }

    return AuthResponse(
      success: true,
      message: 'Password reset instructions have been emailed to $clean.',
    );
  }

  /// Update Profile attributes
  Future<void> updateProfile({
    String? name,
    String? standard,
    String? board,
    String? school,
    String? specialization,
    String? phone,
  }) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      name: name,
      standard: standard,
      board: board,
      school: school,
      specialization: specialization,
      phone: phone,
    );

    await _persistSession(_currentUser!);
  }

  /// Sign out and clear stored session
  Future<void> signOut() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userStorageKey);
    } catch (e) {
      debugPrint('AuthService signOut error: $e');
    }
    notifyListeners();
  }

  // ============================================================
  // INTERNAL HELPERS
  // ============================================================

  Future<void> _persistSession(UserModel user) async {
    _currentUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStorageKey, user.toJson());
    } catch (e) {
      debugPrint('Failed to persist user session: $e');
    }

    _syncToUserProfileService(user);
    notifyListeners();
  }

  void _syncToUserProfileService(UserModel user) {
    UserProfileService.instance.updateProfile(
      name: user.name,
      standard: user.standard ?? '8th Standard',
      board: user.board ?? 'CBSE',
      school: user.school ?? 'Greenwood High School',
    );
  }
}
