import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService extends ChangeNotifier {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  static const String _keyName = 'user_name';
  static const String _keyStandard = 'user_standard';
  static const String _keyBoard = 'user_board';
  static const String _keySchool = 'user_school';

  String _studentName = 'Raghavendra';
  String _standard = 'B.Tech Computer Science & Engineering (CSE)';
  String _board = 'State Technological University';
  String _school = 'University Institute of Technology';
  bool _isInitialized = false;

  String get studentName => _studentName;
  String get standard => _standard;
  String get board => _board;
  String get school => _school;
  bool get isInitialized => _isInitialized;

  // Complete hierarchical standards covering Kindergarten to all Degrees & PhD
  static const Map<String, List<String>> standardsByCategory = {
    'Early Childhood & Kindergarten': [
      'Pre-KG / Nursery',
      'LKG (Lower Kindergarten)',
      'UKG (Upper Kindergarten)',
    ],
    'Primary School (Classes 1 - 5)': [
      '1st Standard',
      '2nd Standard',
      '3rd Standard',
      '4th Standard',
      '5th Standard',
    ],
    'Middle School (Classes 6 - 8)': [
      '6th Standard',
      '7th Standard',
      '8th Standard',
    ],
    'High School (Classes 9 & 10)': [
      '9th Standard',
      '10th Standard',
    ],
    'Higher Secondary (Classes 11 & 12)': [
      '11th Standard (Science - PCM/PCB)',
      '11th Standard (Commerce & Finance)',
      '11th Standard (Arts & Humanities)',
      '12th Standard (Science - PCM/PCB)',
      '12th Standard (Commerce & Finance)',
      '12th Standard (Arts & Humanities)',
    ],
    'Undergraduate / Bachelor Degrees': [
      'B.Tech Computer Science & Engineering (CSE)',
      'B.Tech Mechanical Engineering',
      'B.Tech Electrical & Electronics (EEE/ECE)',
      'B.Tech Civil Engineering',
      'B.Tech AI & Data Science',
      'B.Sc (Physics / Chemistry / Mathematics)',
      'B.Sc (Computer Science / IT / Data Science)',
      'B.Com (Accounting & Finance)',
      'BBA / BMS (Business Administration)',
      'BCA (Computer Applications)',
      'MBBS / BDS (Medicine & Surgery)',
      'B.Pharm (Pharmacy)',
      'BA (Economics / Psychology / English)',
      'B.Arch (Architecture)',
      'LLB (Bachelor of Laws)',
    ],
    'Postgraduate / Master Degrees': [
      'M.Tech / M.E. (Engineering & Tech)',
      'M.Sc (Advanced Sciences & Mathematics)',
      'MBA (Finance / Marketing / Operations)',
      'MCA (Master of Computer Applications)',
      'M.Com (Commerce & Economics)',
      'MD / MS (Medical Specialization)',
      'MA (Humanities & Social Sciences)',
      'LLM (Master of Laws)',
    ],
    'Doctorate & Advanced Research': [
      'PhD / Doctorate Scholar (STEM)',
      'PhD Scholar (Humanities & Management)',
      'Post-Doctoral Fellow',
    ],
    'Competitive & Professional Examinations': [
      'JEE / NEET Aspirant',
      'UPSC / Civil Services Aspirant',
      'GATE / CAT / GRE Aspirant',
      'CA / CS / CFA Professional Prep',
    ],
  };

  static List<String> get allStandards {
    final list = <String>[];
    for (final group in standardsByCategory.values) {
      list.addAll(group);
    }
    return list;
  }

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _studentName = prefs.getString(_keyName) ?? 'Raghavendra';
    _standard = prefs.getString(_keyStandard) ??
        'B.Tech Computer Science & Engineering (CSE)';
    _board = prefs.getString(_keyBoard) ?? 'State Technological University';
    _school = prefs.getString(_keySchool) ?? 'University Institute of Technology';
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? standard,
    String? board,
    String? school,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null && name.trim().isNotEmpty) {
      _studentName = name.trim();
      await prefs.setString(_keyName, _studentName);
    }
    if (standard != null && standard.trim().isNotEmpty) {
      _standard = standard.trim();
      await prefs.setString(_keyStandard, _standard);
    }
    if (board != null && board.trim().isNotEmpty) {
      _board = board.trim();
      await prefs.setString(_keyBoard, _board);
    }
    if (school != null && school.trim().isNotEmpty) {
      _school = school.trim();
      await prefs.setString(_keySchool, _school);
    }

    notifyListeners();
  }
}
