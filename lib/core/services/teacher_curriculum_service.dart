import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../../features/teacher/presentation/widgets/today_classes_section.dart';
import '../../features/teacher/presentation/widgets/at_risk_students_card.dart';

class TeacherCurriculumService extends ChangeNotifier {
  TeacherCurriculumService._();

  static final TeacherCurriculumService instance =
      TeacherCurriculumService._();

  static const String _prefKeyCategory = 'teacher_active_category';
  static const String _prefKeyBranch = 'teacher_active_branch';
  static const String _prefKeySubject = 'teacher_active_subject';

  String _activeCategory = 'Undergraduate Degrees (Engineering)';
  String _activeBranch = 'B.Tech Computer Science & Engineering (CSE)';
  String _activeSubject = 'Data Structures & Algorithms';
  bool _isInitialized = false;

  String get activeCategory => _activeCategory;
  String get activeBranch => _activeBranch;
  String get activeSubject => _activeSubject;
  bool get isInitialized => _isInitialized;

  // ============================================================
  // COMPREHENSIVE ACADEMIC TREE
  // ============================================================
  static const Map<String, Map<String, List<String>>> curriculumTree = {
    'Undergraduate Degrees (Engineering)': {
      'B.Tech Computer Science & Engineering (CSE)': [
        'Data Structures & Algorithms',
        'Operating Systems & Kernel Arch',
        'Database Management Systems (DBMS)',
        'Computer Networks & Protocols',
        'Artificial Intelligence & Machine Learning',
        'Compiler Design & Theory of Computation',
        'Software Engineering & Cloud DevOps',
      ],
      'B.Tech Mechanical Engineering': [
        'Thermodynamics & Heat Transfer',
        'Fluid Mechanics & Turbo-Machinery',
        'Strength of Materials & Solid Mechanics',
        'Kinematics & Dynamics of Machines',
        'Advanced Manufacturing & Robotics',
      ],
      'B.Tech Electrical & Electronics (EEE/ECE)': [
        'Analog & Digital Circuits',
        'Signals, Systems & DSP',
        'Microcontrollers & Embedded IoT',
        'Control Systems & Automation',
        'Power Systems & Renewable Energy',
        'VLSI & Semiconductor Design',
      ],
      'B.Tech Civil Engineering': [
        'Structural Analysis & Design',
        'Surveying, Geomatics & GIS',
        'Geotechnical & Foundation Engineering',
        'Concrete & Construction Tech',
        'Environmental & Water Resources',
      ],
      'B.Tech AI & Data Science': [
        'Deep Learning & Neural Architectures',
        'Natural Language Processing (NLP)',
        'Big Data Analytics & Spark',
        'Computer Vision & Image Processing',
        'Reinforcement Learning',
      ],
    },

    'High School (Classes 9 & 10)': {
      '10th Standard (Board Exam Prep)': [
        'Physics • Optics, Electricity & Magnetism',
        'Chemistry • Chemical Reactions & Carbon Compounds',
        'Biology • Life Processes, Control & Heredity',
        'Mathematics • Quadratic Equations & Trigonometry',
        'English Literature & Language',
        'Social Science • History, Geography & Civics',
      ],
      '9th Standard (Secondary Foundation)': [
        'Physics • Motion, Force & Gravitation',
        'Chemistry • Matter, Atoms & Molecules',
        'Biology • Cell & Plant/Animal Tissues',
        'Mathematics • Polynomials & Geometry',
        'English Literature & Grammar',
        'Social Science • History & Civics',
      ],
    },

    'Higher Secondary (Classes 11 & 12)': {
      '12th Standard (Science - PCM/PCB)': [
        'Physics • Electrostatics, Wave Optics & Magnetism',
        'Chemistry • Electrochemistry, Kinetics & Organic Chemistry',
        'Mathematics • Integrals, Vectors & Differential Equations',
        'Biology • Genetics, Evolution & Biotechnology',
        'Computer Science • Python, SQL & Networks',
      ],
      '11th Standard (Science - PCM/PCB)': [
        'Physics • Kinematics, Laws of Motion & Thermodynamics',
        'Chemistry • Atomic Structure, Chemical Bonding & Equilibrium',
        'Mathematics • Sets, Trigonometry & Coordinate Geometry',
        'Biology • Cell Structure, Biomolecules & Plant Physiology',
        'Computer Science • Algorithms & Python Basics',
      ],
      '11th & 12th Commerce & Finance': [
        'Accountancy • Partnership & Financial Statements',
        'Business Studies • Principles & Functions of Management',
        'Economics • Microeconomics & Macroeconomics',
        'Applied Mathematics & Commercial Arithmetic',
      ],
      '11th & 12th Arts & Humanities': [
        'Political Science • Indian Constitution & Politics',
        'History • Themes in Indian & World History',
        'Psychology • Cognitive Processes & Human Behavior',
        'Sociology • Society & Social Institutions',
      ],
    },

    'Primary School (Classes 1 - 5)': {
      '1st Standard (Bluebells)': [
        'Mathematics • 2D/3D Shapes & Fun Counting',
        'Environmental Studies (EVS) • My Family & Nature',
        'English • Phonics, Sight Words & Storytelling',
        'Art, Rhymes & Creative Expression',
      ],
      '2nd Standard': [
        'Mathematics • Addition, Subtraction & Time',
        'EVS • Living World, Plants & Animals',
        'English • Sentences, Verbs & Reading',
      ],
      '3rd Standard': [
        'Mathematics • Multiplication, Division & Fractions',
        'General Science • Air, Water & Weather',
        'Social Studies • Our Community & Earth',
        'English • Reading Comprehension & Writing',
      ],
      '4th & 5th Standard': [
        'Mathematics • Decimals, Area & Volume',
        'General Science • Human Body, Solar System & Energy',
        'Social Studies • States, Continents & History',
        'English • Essay & Letter Composition',
      ],
    },

    'Early Childhood & Kindergarten': {
      'UKG (Upper Kindergarten)': [
        'Phonics, Rhymes & Sight Words',
        'Numbers & Fun Counting 1-100',
        'Colors, 3D Shapes & Patterns',
        'Sensory Play & Nature Discovery',
      ],
      'LKG & Nursery / Pre-KG': [
        'Alphabet Sounds & Fun Rhymes',
        'Counting 1-20 with Fruits & Animals',
        'Visual Recognition & Motor Skills',
      ],
    },

    'Medical & Health Sciences': {
      'MBBS / Medical Specialization': [
        'Human Anatomy & Neuroanatomy',
        'Human Physiology & Biophysics',
        'Medical Biochemistry & Genetics',
        'Pathology & Microbiology',
        'Pharmacology & Therapeutics',
      ],
    },

    'Postgraduate & Doctorate': {
      'PhD Scholar & Master Research': [
        'Deep Learning & Transformer Convergence',
        'Quantum Optics & Field Theory',
        'Advanced Econometrics & Stochastics',
        'Distributed Cloud Consensus Algorithms',
      ],
    },
  };

  /// Initialize and load saved teaching preferences
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cat = prefs.getString(_prefKeyCategory);
      final branch = prefs.getString(_prefKeyBranch);
      final sub = prefs.getString(_prefKeySubject);

      if (cat != null && curriculumTree.containsKey(cat)) {
        _activeCategory = cat;
        final branches = curriculumTree[cat]!;
        if (branch != null && branches.containsKey(branch)) {
          _activeBranch = branch;
          final subjects = branches[branch]!;
          if (sub != null && (subjects.contains(sub) || sub == 'All Subjects in Branch')) {
            _activeSubject = sub;
          } else {
            _activeSubject = subjects.first;
          }
        } else {
          _activeBranch = branches.keys.first;
          _activeSubject = branches.values.first.first;
        }
      }
    } catch (e) {
      debugPrint('TeacherCurriculumService init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Switch the active teaching focus
  Future<void> setActiveTeachingFocus({
    required String category,
    required String branch,
    required String subject,
  }) async {
    _activeCategory = category;
    _activeBranch = branch;
    _activeSubject = subject;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyCategory, category);
      await prefs.setString(_prefKeyBranch, branch);
      await prefs.setString(_prefKeySubject, subject);
    } catch (e) {
      debugPrint('Error saving teacher focus: $e');
    }

    notifyListeners();
  }

  // ============================================================
  // DYNAMIC ADAPTIVE DATA GENERATORS
  // ============================================================

  /// Generates Today's Schedule strictly matching the active standard & subject
  List<ClassScheduleItem> getAdaptiveSchedule() {
    final branchName = _activeBranch;
    final subjectName = _activeSubject;

    // Check if Kindergarten/Primary
    if (_activeCategory.contains('Kindergarten') || _activeCategory.contains('Primary')) {
      return [
        ClassScheduleItem(
          classId: 'p_1',
          className: branchName,
          standardBadge: 'Primary Level',
          subject: '$subjectName • Interactive Visual Activity & Practice',
          time: '09:30 - 10:15 AM',
          room: 'Activity Room 102',
          studentCount: 24,
          status: 'live',
          badgeColor: AppColors.secondary,
        ),
        ClassScheduleItem(
          classId: 'p_2',
          className: branchName,
          standardBadge: 'Primary Level',
          subject: '$subjectName • Fun Puzzle & Group Quiz',
          time: '11:00 - 11:45 AM',
          room: 'Learning Pod B',
          studentCount: 24,
          status: 'upcoming',
          badgeColor: AppColors.primary,
        ),
      ];
    }

    // Check if High School (9th/10th)
    if (_activeCategory.contains('High School')) {
      return [
        ClassScheduleItem(
          classId: 'hs_1',
          className: 'Class 10-A',
          standardBadge: branchName,
          subject: '$subjectName • Conceptual Lecture & Numerical Problems',
          time: '09:00 - 10:00 AM',
          room: 'Science Lab 1',
          studentCount: 38,
          status: 'live',
          badgeColor: AppColors.primary,
        ),
        ClassScheduleItem(
          classId: 'hs_2',
          className: 'Class 10-B',
          standardBadge: branchName,
          subject: '$subjectName • Board Exam Formula Derivation & Drill',
          time: '11:30 - 12:30 PM',
          room: 'Room 204',
          studentCount: 40,
          status: 'upcoming',
          badgeColor: const Color(0xFF818CF8),
        ),
        ClassScheduleItem(
          classId: 'hs_3',
          className: 'Class 9-A',
          standardBadge: '9th Standard',
          subject: '$subjectName • Foundational Diagnostics & Remedial',
          time: '02:00 - 03:00 PM',
          room: 'Room 108',
          studentCount: 36,
          status: 'upcoming',
          badgeColor: AppColors.success,
        ),
      ];
    }

    // Check if Higher Secondary (11th/12th)
    if (_activeCategory.contains('Higher Secondary')) {
      return [
        ClassScheduleItem(
          classId: 'hs2_1',
          className: 'Section 12-Science A',
          standardBadge: branchName,
          subject: '$subjectName • Advanced Theoretical Derivations & Board Prep',
          time: '08:30 - 09:45 AM',
          room: 'Lecture Hall 3',
          studentCount: 42,
          status: 'live',
          badgeColor: AppColors.primary,
        ),
        ClassScheduleItem(
          classId: 'hs2_2',
          className: 'Section 11-Science B',
          standardBadge: '11th Standard',
          subject: '$subjectName • Core Principles & Problem Set Discussion',
          time: '11:00 - 12:15 PM',
          room: 'Hall 4',
          studentCount: 44,
          status: 'upcoming',
          badgeColor: AppColors.secondary,
        ),
      ];
    }

    // Default: Undergraduate Engineering / B.Tech / Medical / Research
    return [
      ClassScheduleItem(
        classId: 'eng_1',
        className: 'Batch A (Sem 3)',
        standardBadge: branchName.split('(').first.trim(),
        subject: '$subjectName • Core Theory & Algorithmic Complexity',
        time: '10:00 - 11:15 AM',
        room: 'Computing Lab 3',
        studentCount: 46,
        status: 'live',
        badgeColor: AppColors.primary,
      ),
      ClassScheduleItem(
        classId: 'eng_2',
        className: 'Batch B (Sem 3)',
        standardBadge: branchName.split('(').first.trim(),
        subject: '$subjectName • Practical Lab & Implementation Benchmarks',
        time: '01:30 - 03:00 PM',
        room: 'Research Annex 201',
        studentCount: 44,
        status: 'upcoming',
        badgeColor: const Color(0xFF818CF8),
      ),
      ClassScheduleItem(
        classId: 'eng_3',
        className: 'Honors & Research Colloquium',
        standardBadge: 'Advanced Track',
        subject: '$subjectName • Industrial Applications & Paper Review',
        time: '04:00 - 05:00 PM',
        room: 'Seminar Hall A',
        studentCount: 18,
        status: 'upcoming',
        badgeColor: AppColors.success,
      ),
    ];
  }

  /// Generates At-Risk Students dynamically based on active subject
  /// Generates At-Risk Students (delegated to real dynamic database)
  List<AtRiskStudent> getAdaptiveAtRiskStudents() {
    return const [];
  }

  /// Generates Homework List for active standard & subject
  List<Map<String, dynamic>> getAdaptiveHomeworkList() {
    final sub = _activeSubject;
    final branch = _activeBranch;

    return [
      {
        'title': '$sub Practice Problem Set',
        'class': branch.split('(').first.trim(),
        'subject': sub,
        'due': 'Tomorrow, 05:00 PM',
        'submitted': 0,
        'total': 0,
        'status': 'Active',
        'points': 50,
      },
      {
        'title': '$sub Case Study & Concept Diagrams',
        'class': branch.split('(').first.trim(),
        'subject': sub,
        'due': 'Friday, 11:59 PM',
        'submitted': 0,
        'total': 0,
        'status': 'Active',
        'points': 100,
      },
    ];
  }

  /// Generates Pending Submissions queue (real registered submissions only)
  List<Map<String, dynamic>> getAdaptivePendingGrading() {
    return const [];
  }
}
