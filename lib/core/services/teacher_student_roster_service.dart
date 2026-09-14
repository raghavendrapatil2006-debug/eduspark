import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/teacher/presentation/widgets/at_risk_students_card.dart';

class RosterStudentModel {
  final String id;
  final String name;
  final String rollNo;
  final String className;
  final String standardBadge;
  final String? email;
  final String? phone;
  final int totalSessions;
  final int presentDays;
  final int lateDays;
  final int absentDays;
  final double mastery;
  String todayStatus; // 'present', 'late', 'absent'
  final String lastUpdatedDate;

  RosterStudentModel({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.className,
    required this.standardBadge,
    this.email,
    this.phone,
    this.totalSessions = 20,
    this.presentDays = 19,
    this.lateDays = 1,
    this.absentDays = 0,
    this.mastery = 0.88,
    this.todayStatus = 'present',
    required this.lastUpdatedDate,
  });

  /// Present days attendance percentage calculated from conducted sessions
  double get attendancePercentage {
    if (totalSessions <= 0) {
      if (todayStatus == 'absent') return 0.0;
      if (todayStatus == 'late') return 75.0;
      return 100.0;
    }
    final effectivePresent = presentDays + (lateDays * 0.5);
    final pct = (effectivePresent / totalSessions) * 100.0;
    return pct.clamp(0.0, 100.0);
  }

  RosterStudentModel copyWith({
    String? id,
    String? name,
    String? rollNo,
    String? className,
    String? standardBadge,
    String? email,
    String? phone,
    int? totalSessions,
    int? presentDays,
    int? lateDays,
    int? absentDays,
    double? mastery,
    String? todayStatus,
    String? lastUpdatedDate,
  }) {
    return RosterStudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      className: className ?? this.className,
      standardBadge: standardBadge ?? this.standardBadge,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      totalSessions: totalSessions ?? this.totalSessions,
      presentDays: presentDays ?? this.presentDays,
      lateDays: lateDays ?? this.lateDays,
      absentDays: absentDays ?? this.absentDays,
      mastery: mastery ?? this.mastery,
      todayStatus: todayStatus ?? this.todayStatus,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rollNo': rollNo,
      'className': className,
      'standardBadge': standardBadge,
      'email': email,
      'phone': phone,
      'totalSessions': totalSessions,
      'presentDays': presentDays,
      'lateDays': lateDays,
      'absentDays': absentDays,
      'mastery': mastery,
      'todayStatus': todayStatus,
      'lastUpdatedDate': lastUpdatedDate,
    };
  }

  factory RosterStudentModel.fromJson(Map<String, dynamic> map) {
    return RosterStudentModel(
      id: map['id'] as String? ?? 'std_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] as String? ?? 'Student',
      rollNo: map['rollNo'] as String? ?? '#000',
      className: map['className'] as String? ?? 'Class',
      standardBadge: map['standardBadge'] as String? ?? 'General',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      totalSessions: (map['totalSessions'] as num?)?.toInt() ?? 20,
      presentDays: (map['presentDays'] as num?)?.toInt() ?? 18,
      lateDays: (map['lateDays'] as num?)?.toInt() ?? 1,
      absentDays: (map['absentDays'] as num?)?.toInt() ?? 1,
      mastery: (map['mastery'] as num?)?.toDouble() ?? 0.85,
      todayStatus: map['todayStatus'] as String? ?? 'present',
      lastUpdatedDate: map['lastUpdatedDate'] as String? ??
          DateTime.now().toIso8601String().split('T').first,
    );
  }
}

class TeacherStudentRosterService extends ChangeNotifier {
  TeacherStudentRosterService._();

  static final TeacherStudentRosterService instance =
      TeacherStudentRosterService._();

  static const String _storagePrefix = 'eduspark_teacher_roster_';

  String _cleanKey(String className) {
    return '$_storagePrefix${className.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
  }

  String _getTodayString() {
    return DateTime.now().toIso8601String().split('T').first;
  }

  /// Get students for a specific class from database (returns only registered/added students)
  Future<List<RosterStudentModel>> getStudentsForClass(
    String className, {
    String standardBadge = 'Grade',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cleanKey(className);
    final rawJson = prefs.getString(key);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        final nonSeedStudents = decoded
            .map((item) =>
                RosterStudentModel.fromJson(item as Map<String, dynamic>))
            .where((s) => !s.id.startsWith('std_seed_'))
            .toList();

        // If seed items were present in cache, purge them
        if (nonSeedStudents.length != decoded.length) {
          await _saveToStorage(className, nonSeedStudents);
        }

        return nonSeedStudents;
      } catch (e) {
        debugPrint('Error parsing roster database for $className: $e');
      }
    }

    // Default to empty list: zero mock students until registered or added!
    return <RosterStudentModel>[];
  }

  /// Fetch all registered students across all classes
  Future<List<RosterStudentModel>> getAllStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final rosterKeys = allKeys.where((k) => k.startsWith(_storagePrefix));

    final List<RosterStudentModel> all = [];
    for (final k in rosterKeys) {
      final raw = prefs.getString(k);
      if (raw != null && raw.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
          for (final item in decoded) {
            final s = RosterStudentModel.fromJson(item as Map<String, dynamic>);
            if (!s.id.startsWith('std_seed_') &&
                !all.any((existing) => existing.id == s.id)) {
              all.add(s);
            }
          }
        } catch (_) {}
      }
    }
    return all;
  }

  /// Dynamically computes At-Risk students based on real registered students
  Future<List<AtRiskStudent>> getAtRiskStudents() async {
    final all = await getAllStudents();
    final List<AtRiskStudent> atRisk = [];

    for (final s in all) {
      final attPct = s.attendancePercentage;
      if (attPct < 75.0 || s.mastery < 0.65) {
        atRisk.add(
          AtRiskStudent(
            id: s.id,
            name: s.name,
            standard: s.className,
            subject: 'Attendance & Mastery',
            flaggedReason: attPct < 75.0
                ? 'Attendance alert (${attPct.toStringAsFixed(1)}%): Present ${s.presentDays} of ${s.totalSessions} sessions.'
                : 'Conceptual mastery at ${(s.mastery * 100).toInt()}%; periodic assessment review needed.',
            score: (attPct / 100.0).clamp(0.0, 1.0),
            suggestedAction: attPct < 75.0
                ? 'Send Attendance Notice'
                : 'Assign Remedial Practice Drill',
          ),
        );
      }
    }

    return atRisk;
  }

  /// Total count of registered students across all classes
  Future<int> getTotalStudentCount() async {
    final all = await getAllStudents();
    return all.length;
  }

  /// Average attendance across all registered students
  Future<double> getOverallAttendancePercentage() async {
    final all = await getAllStudents();
    if (all.isEmpty) return 100.0;
    final total =
        all.fold<double>(0.0, (acc, s) => acc + s.attendancePercentage);
    return total / all.length;
  }

  /// Add a new student to the class and persist to database
  Future<RosterStudentModel> addStudent({
    required String className,
    required String standardBadge,
    required String name,
    required String rollNo,
    String? email,
    String? phone,
    double mastery = 0.85,
  }) async {
    final currentStudents = await getStudentsForClass(
      className,
      standardBadge: standardBadge,
    );

    final today = _getTodayString();
    final newStudent = RosterStudentModel(
      id: 'std_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      rollNo: rollNo.trim(),
      className: className,
      standardBadge: standardBadge,
      email: email?.trim(),
      phone: phone?.trim(),
      totalSessions: 1,
      presentDays: 1,
      lateDays: 0,
      absentDays: 0,
      mastery: mastery,
      todayStatus: 'present',
      lastUpdatedDate: today,
    );

    currentStudents.add(newStudent);
    await _saveToStorage(className, currentStudents);
    notifyListeners();
    return newStudent;
  }

  /// Update attendance status for a student today and recalculate attendance percentage
  Future<void> updateTodayAttendance({
    required String className,
    required String studentId,
    required String newStatus, // 'present', 'late', 'absent'
  }) async {
    final currentStudents = await getStudentsForClass(className);
    final index = currentStudents.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    final student = currentStudents[index];
    final oldStatus = student.todayStatus;
    if (oldStatus == newStatus) return;

    int newPresent = student.presentDays;
    int newLate = student.lateDays;
    int newAbsent = student.absentDays;

    // Roll back old status count
    if (oldStatus == 'present') newPresent = (newPresent - 1).clamp(0, 9999);
    if (oldStatus == 'late') newLate = (newLate - 1).clamp(0, 9999);
    if (oldStatus == 'absent') newAbsent = (newAbsent - 1).clamp(0, 9999);

    // Apply new status count
    if (newStatus == 'present') newPresent++;
    if (newStatus == 'late') newLate++;
    if (newStatus == 'absent') newAbsent++;

    currentStudents[index] = student.copyWith(
      todayStatus: newStatus,
      presentDays: newPresent,
      lateDays: newLate,
      absentDays: newAbsent,
      lastUpdatedDate: _getTodayString(),
    );

    await _saveToStorage(className, currentStudents);
    notifyListeners();
  }

  /// Mark all students with a given status
  Future<void> markAll({
    required String className,
    required String status, // 'present', 'late', 'absent'
  }) async {
    final currentStudents = await getStudentsForClass(className);
    for (int i = 0; i < currentStudents.length; i++) {
      final s = currentStudents[i];
      if (s.todayStatus != status) {
        int newPresent = s.presentDays;
        int newLate = s.lateDays;
        int newAbsent = s.absentDays;

        if (s.todayStatus == 'present') newPresent = (newPresent - 1).clamp(0, 9999);
        if (s.todayStatus == 'late') newLate = (newLate - 1).clamp(0, 9999);
        if (s.todayStatus == 'absent') newAbsent = (newAbsent - 1).clamp(0, 9999);

        if (status == 'present') newPresent++;
        if (status == 'late') newLate++;
        if (status == 'absent') newAbsent++;

        currentStudents[i] = s.copyWith(
          todayStatus: status,
          presentDays: newPresent,
          lateDays: newLate,
          absentDays: newAbsent,
          lastUpdatedDate: _getTodayString(),
        );
      }
    }

    await _saveToStorage(className, currentStudents);
    notifyListeners();
  }

  /// Delete a student from the class roster
  Future<void> removeStudent({
    required String className,
    required String studentId,
  }) async {
    final currentStudents = await getStudentsForClass(className);
    currentStudents.removeWhere((s) => s.id == studentId);
    await _saveToStorage(className, currentStudents);
    notifyListeners();
  }

  Future<void> _saveToStorage(
    String className,
    List<RosterStudentModel> students,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cleanKey(className);
    final encoded = jsonEncode(students.map((s) => s.toJson()).toList());
    await prefs.setString(key, encoded);
  }
}
