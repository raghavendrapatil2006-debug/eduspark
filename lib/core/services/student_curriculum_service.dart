import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import 'teacher_curriculum_service.dart';

class StudentSubject {
  final String title;
  final String topicCountText;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> keyTopics;

  const StudentSubject({
    required this.title,
    required this.topicCountText,
    required this.icon,
    this.color = AppColors.primary,
    required this.description,
    this.keyTopics = const [],
  });
}

class StudentContinueLearning {
  final String topic;
  final String subject;
  final String standardSubtitle;
  final double progress;
  final IconData icon;

  const StudentContinueLearning({
    required this.topic,
    required this.subject,
    required this.standardSubtitle,
    required this.progress,
    required this.icon,
  });
}

class StudentConceptOfDay {
  final String tag;
  final String subjectSubtitle;
  final String title;
  final String formulaEquation;
  final String description;
  final List<String> variableBreakdown;
  final String realWorldExample;

  const StudentConceptOfDay({
    required this.tag,
    required this.subjectSubtitle,
    required this.title,
    required this.formulaEquation,
    required this.description,
    required this.variableBreakdown,
    required this.realWorldExample,
  });
}

class StudentStudyTask {
  final String title;
  final int xp;
  bool isCompleted;

  StudentStudyTask(this.title, this.xp, [this.isCompleted = false]);
}

class StudentCatalogTopic {
  final String title;
  final String subject;
  final String description;
  final double progress;

  const StudentCatalogTopic(
    this.title,
    this.subject,
    this.description,
    this.progress,
  );
}

class StudentAssignment {
  final String id;
  final String title;
  final String subject;
  final String teacher;
  final String dueDate;
  final int problemsCount;
  final String status; // 'Due Soon', 'In Progress', 'Completed'
  final Color badgeColor;
  final String description;
  final List<String> tasks;
  bool isSubmitted;

  StudentAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacher,
    required this.dueDate,
    required this.problemsCount,
    required this.status,
    required this.badgeColor,
    required this.description,
    required this.tasks,
    this.isSubmitted = false,
  });
}

class StudentCurriculumService extends ChangeNotifier {
  StudentCurriculumService._();

  static final StudentCurriculumService instance = StudentCurriculumService._();

  static const String _prefKeyCategory = 'student_active_category';
  static const String _prefKeyStandard = 'student_active_standard';

  String _activeCategory = 'Undergraduate Degrees (Engineering)';
  String _activeStandard = 'B.Tech Computer Science & Engineering (CSE)';
  bool _isInitialized = false;

  String get activeCategory => _activeCategory;
  String get activeStandard => _activeStandard;
  bool get isInitialized => _isInitialized;

  /// Map of category to list of branches/standards
  Map<String, List<String>> get availableStandardsMap {
    final Map<String, List<String>> map = {};
    for (final entry in TeacherCurriculumService.curriculumTree.entries) {
      map[entry.key] = entry.value.keys.toList();
    }
    return map;
  }

  /// Initialize and load stored student curriculum
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cat = prefs.getString(_prefKeyCategory);
      final std = prefs.getString(_prefKeyStandard);

      if (cat != null && TeacherCurriculumService.curriculumTree.containsKey(cat)) {
        _activeCategory = cat;
        final branches = TeacherCurriculumService.curriculumTree[cat]!;
        if (std != null && branches.containsKey(std)) {
          _activeStandard = std;
        } else {
          _activeStandard = branches.keys.first;
        }
      }
    } catch (e) {
      debugPrint('StudentCurriculumService init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Set the active academic standard / degree
  Future<void> setActiveStandard({
    required String category,
    required String standard,
  }) async {
    _activeCategory = category;
    _activeStandard = standard;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyCategory, category);
      await prefs.setString(_prefKeyStandard, standard);
    } catch (e) {
      debugPrint('Error saving student standard: $e');
    }

    notifyListeners();
  }

  /// Convenience shortcut to set category and standard
  Future<void> setCurriculum(String category, String standard) {
    return setActiveStandard(category: category, standard: standard);
  }

  // ============================================================
  // ADAPTIVE DATA GENERATORS
  // ============================================================

  /// Returns the enrolled subjects matching the active standard/branch
  List<StudentSubject> getAdaptiveSubjects() {
    final std = _activeStandard;

    // Engineering B.Tech CSE
    if (std.contains('Computer Science') || std.contains('CSE')) {
      return const [
        StudentSubject(
          title: 'Data Structures & Algorithms',
          topicCountText: '24 Modules',
          icon: Icons.account_tree_rounded,
          color: Color(0xFF6366F1),
          description: 'Arrays, Trees, Graphs, DP & Asymptotic Complexity',
          keyTopics: ['Binary Search Trees', 'Graph Traversal', 'Dynamic Programming'],
        ),
        StudentSubject(
          title: 'Operating Systems & Kernel',
          topicCountText: '18 Modules',
          icon: Icons.developer_board_rounded,
          color: Color(0xFF06B6D4),
          description: 'Virtual Memory, CPU Scheduling, Mutex & Deadlocks',
          keyTopics: ['Paging & Segmentation', 'Process Scheduling', 'Semaphores'],
        ),
        StudentSubject(
          title: 'Database Management (DBMS)',
          topicCountText: '16 Modules',
          icon: Icons.storage_rounded,
          color: Color(0xFF10B981),
          description: 'Relational Algebra, SQL, Normalization & ACID',
          keyTopics: ['B+ Trees', 'BCNF Normalization', 'Transaction Concurrency'],
        ),
        StudentSubject(
          title: 'Computer Networks',
          topicCountText: '20 Modules',
          icon: Icons.lan_rounded,
          color: Color(0xFFF59E0B),
          description: 'TCP/IP, Routing Protocols, DNS, HTTP/3 & Sockets',
          keyTopics: ['OSI Model', 'Dijkstra Routing', 'TCP Congestion Control'],
        ),
        StudentSubject(
          title: 'AI & Machine Learning',
          topicCountText: '22 Modules',
          icon: Icons.auto_awesome_rounded,
          color: Color(0xFF8B5CF6),
          description: 'Neural Networks, Gradient Descent & NLP',
          keyTopics: ['Backpropagation', 'CNNs', 'Attention Transformers'],
        ),
        StudentSubject(
          title: 'Software Eng & DevOps',
          topicCountText: '14 Modules',
          icon: Icons.cloud_done_rounded,
          color: Color(0xFFEC4899),
          description: 'CI/CD, Cloud Microservices, Docker & Testing',
          keyTopics: ['Design Patterns', 'Kubernetes', 'REST APIs'],
        ),
      ];
    }

    // Engineering Mechanical
    if (std.contains('Mechanical')) {
      return const [
        StudentSubject(
          title: 'Thermodynamics & Heat',
          topicCountText: '22 Modules',
          icon: Icons.whatshot_rounded,
          color: Color(0xFFEF4444),
          description: 'Carnot Cycle, Entropy, Heat Exchangers & Laws',
          keyTopics: ['First & Second Laws', 'Rankine Cycle', 'Conduction & Radiation'],
        ),
        StudentSubject(
          title: 'Fluid Mechanics',
          topicCountText: '18 Modules',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF06B6D4),
          description: 'Navier-Stokes, Bernoulli Equation, Turbo-Machinery',
          keyTopics: ['Laminar & Turbulent Flow', 'Boundary Layer', 'Pumps & Turbines'],
        ),
        StudentSubject(
          title: 'Strength of Materials',
          topicCountText: '20 Modules',
          icon: Icons.fitness_center_rounded,
          color: Color(0xFFF59E0B),
          description: 'Stress-Strain, Mohr Circle, Shear Force & Bending',
          keyTopics: ['Beam Deflection', 'Torsion of Shafts', 'Column Buckling'],
        ),
        StudentSubject(
          title: 'Kinematics & Robotics',
          topicCountText: '16 Modules',
          icon: Icons.precision_manufacturing_rounded,
          color: Color(0xFF6366F1),
          description: 'Gear Trains, Linkages, Actuators & Automation',
          keyTopics: ['Degrees of Freedom', 'Robotic Kinematics', 'Cams & Followers'],
        ),
      ];
    }

    // High School (10th Standard)
    if (std.contains('10th')) {
      return const [
        StudentSubject(
          title: 'Physics',
          topicCountText: '16 Topics',
          icon: Icons.science_rounded,
          color: Color(0xFF6366F1),
          description: 'Light Optics, Electricity & Magnetic Effects',
          keyTopics: ['Ray Diagrams', 'Ohm\'s Law', 'Electromagnetic Induction'],
        ),
        StudentSubject(
          title: 'Chemistry',
          topicCountText: '14 Topics',
          icon: Icons.biotech_rounded,
          color: Color(0xFF10B981),
          description: 'Chemical Reactions, Acids & Carbon Compounds',
          keyTopics: ['Balancing Equations', 'pH Scale', 'Organic Hydrocarbons'],
        ),
        StudentSubject(
          title: 'Mathematics',
          topicCountText: '18 Topics',
          icon: Icons.calculate_rounded,
          color: Color(0xFFF59E0B),
          description: 'Quadratic Equations, Trigonometry & Coordinate Geometry',
          keyTopics: ['Trigonometric Ratios', 'Arithmetic Progressions', 'Circles'],
        ),
        StudentSubject(
          title: 'Biology',
          topicCountText: '12 Topics',
          icon: Icons.eco_rounded,
          color: Color(0xFF06B6D4),
          description: 'Life Processes, Control, Heredity & Environment',
          keyTopics: ['Human Circulatory System', 'Photosynthesis', 'Mendel Laws'],
        ),
        StudentSubject(
          title: 'English',
          topicCountText: '10 Topics',
          icon: Icons.menu_book_rounded,
          color: Color(0xFF8B5CF6),
          description: 'Literature, Reading Comprehension & Writing',
          keyTopics: ['Grammar Tenses', 'Formal Letter Writing', 'Poetry Analysis'],
        ),
        StudentSubject(
          title: 'Social Science',
          topicCountText: '15 Topics',
          icon: Icons.public_rounded,
          color: Color(0xFFEC4899),
          description: 'History, Geography, Democratic Politics & Economics',
          keyTopics: ['Nationalism in India', 'Resources & Water', 'Money & Credit'],
        ),
      ];
    }

    // Higher Secondary (12th Science PCM/PCB)
    if (std.contains('12th') || std.contains('Higher Secondary')) {
      return const [
        StudentSubject(
          title: 'Physics',
          topicCountText: '20 Modules',
          icon: Icons.science_rounded,
          color: Color(0xFF6366F1),
          description: 'Electrostatics, Wave Optics, Magnetism & Nuclei',
          keyTopics: ['Coulomb\'s Law', 'Young\'s Double Slit', 'Semiconductors'],
        ),
        StudentSubject(
          title: 'Chemistry',
          topicCountText: '18 Modules',
          icon: Icons.biotech_rounded,
          color: Color(0xFF10B981),
          description: 'Electrochemistry, Kinetics & Organic Synthesis',
          keyTopics: ['Aldehydes & Ketones', 'Nernst Equation', 'Coordination Compounds'],
        ),
        StudentSubject(
          title: 'Mathematics',
          topicCountText: '22 Modules',
          icon: Icons.calculate_rounded,
          color: Color(0xFFF59E0B),
          description: 'Calculus, Integrals, Vectors & 3D Geometry',
          keyTopics: ['Definite Integrals', 'Differential Equations', 'Vector Dot & Cross'],
        ),
        StudentSubject(
          title: 'Biology / CS',
          topicCountText: '16 Modules',
          icon: Icons.memory_rounded,
          color: Color(0xFF06B6D4),
          description: 'Molecular Genetics, Biotechnology & Python Programming',
          keyTopics: ['DNA Replication', 'Object-Oriented Python', 'SQL Queries'],
        ),
      ];
    }

    // Primary School (Classes 1 - 5)
    if (_activeCategory.contains('Primary') || std.contains('1st') || std.contains('2nd')) {
      return const [
        StudentSubject(
          title: 'Fun Mathematics',
          topicCountText: '12 Fun Games',
          icon: Icons.pin_rounded,
          color: Color(0xFFF59E0B),
          description: 'Numbers 1-100, Fun Addition & 2D/3D Shapes',
          keyTopics: ['Counting Animals', 'Shape Matching', 'Clock Time'],
        ),
        StudentSubject(
          title: 'Environmental Studies',
          topicCountText: '10 Explorations',
          icon: Icons.park_rounded,
          color: Color(0xFF10B981),
          description: 'Living World, Trees, Animals & Our Body',
          keyTopics: ['My Senses', 'Plants Around Us', 'Seasons & Weather'],
        ),
        StudentSubject(
          title: 'English & Phonics',
          topicCountText: '14 Rhymes & Words',
          icon: Icons.menu_book_rounded,
          color: Color(0xFF6366F1),
          description: 'Alphabet Sounds, Sight Words & Storytelling',
          keyTopics: ['Phonics Sounds', 'Short Sentences', 'Animal Stories'],
        ),
        StudentSubject(
          title: 'Art, Craft & Colors',
          topicCountText: '8 Activities',
          icon: Icons.palette_rounded,
          color: Color(0xFFEC4899),
          description: 'Coloring, Clay Modeling & Creative Play',
          keyTopics: ['Primary Colors', 'Origami Paper Boat', 'Free Drawing'],
        ),
      ];
    }

    // Medical (MBBS)
    if (std.contains('MBBS') || _activeCategory.contains('Medical')) {
      return const [
        StudentSubject(
          title: 'Human Anatomy',
          topicCountText: '26 Modules',
          icon: Icons.accessibility_new_rounded,
          color: Color(0xFFEF4444),
          description: 'Gross Anatomy, Neuroanatomy, Histology & Embryology',
          keyTopics: ['Cranial Nerves', 'Cardiovascular System', 'Brachial Plexus'],
        ),
        StudentSubject(
          title: 'Medical Physiology',
          topicCountText: '22 Modules',
          icon: Icons.monitor_heart_rounded,
          color: Color(0xFF06B6D4),
          description: 'Cardiac Cycle, Renal Function & Action Potentials',
          keyTopics: ['ECG Waveforms', 'Glomerular Filtration', 'Respiratory Gas Exchange'],
        ),
        StudentSubject(
          title: 'Biochemistry',
          topicCountText: '18 Modules',
          icon: Icons.science_rounded,
          color: Color(0xFFF59E0B),
          description: 'Enzyme Kinetics, Glycolysis, Krebs Cycle & Lipids',
          keyTopics: ['Metabolic Pathways', 'DNA Structure', 'Vitamins & Minerals'],
        ),
        StudentSubject(
          title: 'Pathology & Pharma',
          topicCountText: '24 Modules',
          icon: Icons.medication_rounded,
          color: Color(0xFF10B981),
          description: 'Cell Injury, Inflammation, Pharmacodynamics & Drugs',
          keyTopics: ['Hemodynamics', 'Antibiotics Mechanism', 'Receptor Pharmacology'],
        ),
      ];
    }

    // Default Fallback
    return const [
      StudentSubject(
        title: 'Core Science',
        topicCountText: '15 Topics',
        icon: Icons.science_rounded,
        color: Color(0xFF6366F1),
        description: 'Physics, Chemistry & Foundational Life Sciences',
        keyTopics: ['Matter & Energy', 'Forces', 'Living Organisms'],
      ),
      StudentSubject(
        title: 'Mathematics',
        topicCountText: '18 Topics',
        icon: Icons.calculate_rounded,
        color: Color(0xFFF59E0B),
        description: 'Arithmetic, Algebra, Geometry & Logic',
        keyTopics: ['Equations', 'Fractions', 'Mensuration'],
      ),
      StudentSubject(
        title: 'English Language',
        topicCountText: '12 Topics',
        icon: Icons.menu_book_rounded,
        color: Color(0xFF10B981),
        description: 'Reading, Grammar, Composition & Vocabulary',
        keyTopics: ['Tenses', 'Comprehension', 'Essay Writing'],
      ),
    ];
  }

  /// Returns the tailored in-progress Continue Learning card
  StudentContinueLearning getAdaptiveContinueLearning() {
    final std = _activeStandard;

    if (std.contains('Computer Science') || std.contains('CSE')) {
      return const StudentContinueLearning(
        topic: 'Graph Traversal: BFS, DFS & Dijkstra',
        subject: 'Data Structures & Algorithms',
        standardSubtitle: 'B.Tech CSE • Semester 3',
        progress: 0.75,
        icon: Icons.account_tree_rounded,
      );
    }

    if (std.contains('Mechanical')) {
      return const StudentContinueLearning(
        topic: 'Rankine & Carnot Power Cycles',
        subject: 'Applied Thermodynamics',
        standardSubtitle: 'B.Tech Mechanical • Semester 3',
        progress: 0.68,
        icon: Icons.whatshot_rounded,
      );
    }

    if (std.contains('10th')) {
      return const StudentContinueLearning(
        topic: 'Light: Reflection, Refraction & Optical Lenses',
        subject: 'Physics • Ray Optics',
        standardSubtitle: '10th Standard • Board Exam Prep',
        progress: 0.72,
        icon: Icons.science_rounded,
      );
    }

    if (std.contains('12th')) {
      return const StudentContinueLearning(
        topic: 'Electrostatic Potential, Gauss Law & Capacitors',
        subject: 'Physics • Electromagnetism',
        standardSubtitle: '12th Standard Science (PCM)',
        progress: 0.65,
        icon: Icons.bolt_rounded,
      );
    }

    if (_activeCategory.contains('Primary') || std.contains('1st')) {
      return const StudentContinueLearning(
        topic: 'Animal Counting & 3D Shapes Safari',
        subject: 'Fun Mathematics',
        standardSubtitle: '1st Standard • Bluebells',
        progress: 0.82,
        icon: Icons.category_rounded,
      );
    }

    if (std.contains('MBBS') || _activeCategory.contains('Medical')) {
      return const StudentContinueLearning(
        topic: 'Cardiac Electrophysiology & 12-Lead ECG',
        subject: 'Medical Physiology',
        standardSubtitle: 'MBBS • Year 1 Foundation',
        progress: 0.70,
        icon: Icons.monitor_heart_rounded,
      );
    }

    return const StudentContinueLearning(
      topic: 'Photosynthesis & Cellular Energy',
      subject: 'Science • Living World',
      standardSubtitle: 'Secondary Standard Foundation',
      progress: 0.70,
      icon: Icons.science_rounded,
    );
  }

  /// Returns the tailored Formula / Concept of the Day card
  StudentConceptOfDay getAdaptiveConceptOfDay() {
    final std = _activeStandard;

    if (std.contains('Computer Science') || std.contains('CSE')) {
      return const StudentConceptOfDay(
        tag: 'Algorithm Complexity',
        subjectSubtitle: 'Computer Science • B.Tech CSE',
        title: 'Master Theorem for Divide & Conquer',
        formulaEquation: r'T(n) = a T(n/b) + \Theta(n^k \log^p n)',
        description:
            'A direct closed-form formula to quickly determine the Big-O asymptotic time complexity of recursive algorithms like Merge Sort, Binary Search, and Strassen Matrix Multiplication.',
        variableBreakdown: [
          r'a \ge 1: Number of recursive sub-problems spawned at each step',
          r'b > 1: Factor by which the problem size is divided',
          r'f(n) = \Theta(n^k): Cost of work performed outside the recursive calls (divide & merge)',
        ],
        realWorldExample:
            'Used by compiler optimizers and database query engines to evaluate tree traversal vs parallel divide-and-conquer processing efficiency.',
      );
    }

    if (std.contains('Mechanical')) {
      return const StudentConceptOfDay(
        tag: 'Fluid Dynamics',
        subjectSubtitle: 'Mechanical Engineering',
        title: 'Bernoulli\'s Equation of Incompressible Flow',
        formulaEquation: r'P + \frac{1}{2} \rho v^2 + \rho g h = \text{Constant}',
        description:
            'Expresses the conservation of mechanical energy for flowing fluids: as fluid velocity increases, static pressure decreases simultaneously.',
        variableBreakdown: [
          'P: Static fluid pressure at the section',
          r'\rho: Fluid mass density',
          'v: Velocity of flow',
          'h: Elevation head above datum',
        ],
        realWorldExample:
            'Explains aerodynamic lift on airplane wings, carburetor fuel injection, and venturi flowmeter pipe measurements.',
      );
    }

    if (std.contains('10th')) {
      return const StudentConceptOfDay(
        tag: 'Optics & Wave Physics',
        subjectSubtitle: 'Physics • 10th Standard',
        title: 'Snell\'s Law of Optical Refraction',
        formulaEquation: r'n_1 \sin\theta_1 = n_2 \sin\theta_2',
        description:
            'Governs how light rays bend when passing between media of different optical densities (e.g. from air into water or crown glass).',
        variableBreakdown: [
          'n_1: Refractive index of initial incident medium',
          r'\theta_1: Angle of incidence with the normal line',
          'n_2: Refractive index of refracting medium',
          r'\theta_2: Angle of refraction',
        ],
        realWorldExample:
            'Calculates prescription focal curves in eyeglass lenses, camera zoom elements, and total internal reflection in high-speed optical fiber cables.',
      );
    }

    if (std.contains('12th')) {
      return const StudentConceptOfDay(
        tag: 'Calculus & Analysis',
        subjectSubtitle: 'Mathematics • Class 12 PCM',
        title: 'Fundamental Theorem of Calculus',
        formulaEquation: r'\int_{a}^{b} f(x)\,dx = F(b) - F(a)',
        description:
            'Connects differentiation and integration: the definite integral of a function equals the net change of its anti-derivative.',
        variableBreakdown: [
          'f(x): Continuous integrand function on [a, b]',
          'F(x): Anti-derivative function where F\'(x) = f(x)',
          'a, b: Lower and upper limits of integration',
        ],
        realWorldExample:
            'Computes total electrical work done charging a capacitor, total kinetic energy transferred, and exact orbital areas in satellite mechanics.',
      );
    }

    if (_activeCategory.contains('Primary') || std.contains('1st')) {
      return const StudentConceptOfDay(
        tag: 'Fun Geometry & Shapes',
        subjectSubtitle: 'Primary Mathematics • 1st Standard',
        title: 'Shapes Around Us: Triangles & Circles',
        formulaEquation: '🔺 Triangle = 3 Sides & 3 Corners | ⚪ Circle = Round & 0 Corners',
        description:
            'Look around your room! A slice of pizza is shaped like a triangle, and a clock on the wall is shaped like a circle.',
        variableBreakdown: [
          '🔺 Triangle: 3 straight lines and 3 pointy corners',
          '🟦 Square: 4 equal sides and 4 square corners',
          '⚪ Circle: Perfectly smooth and round with zero corners',
        ],
        realWorldExample:
            'Bicycle wheels are round circles so they roll smoothly, and traffic road signs use bright triangles so drivers notice them easily!',
      );
    }

    // Default Fallback: Ohm's Law
    return const StudentConceptOfDay(
      tag: 'Electric Circuits',
      subjectSubtitle: 'Physics & General Science',
      title: 'Ohm\'s Law: Voltage & Resistance',
      formulaEquation: 'V  =  I  ×  R',
      description:
          'States that the current flowing through a conductor between two points is directly proportional to the voltage applied across the two points.',
      variableBreakdown: [
        'V: Potential Difference (measured in Volts)',
        'I: Electric Current (measured in Amperes)',
        'R: Resistance (measured in Ohms)',
      ],
      realWorldExample:
          'Controls phone charger circuits, dimmer switches for living room lights, and safe fuses in electrical home appliances.',
    );
  }

  /// Returns grade-appropriate daily routine study tasks
  List<StudentStudyTask> getAdaptiveDailyTasks() {
    final std = _activeStandard;

    if (std.contains('Computer Science') || std.contains('CSE')) {
      return [
        StudentStudyTask('Daily Streak Check-in (+10 XP)', 10, true),
        StudentStudyTask('Implement Graph BFS / DFS in Python (+30 XP)', 30, true),
        StudentStudyTask('Review Virtual Memory Paging & TLB Hit Ratio', 25, false),
        StudentStudyTask('Solve 5 DBMS BCNF Normalization MCQs', 20, false),
      ];
    }

    if (std.contains('Mechanical')) {
      return [
        StudentStudyTask('Daily Streak Check-in (+10 XP)', 10, true),
        StudentStudyTask('Derive Bernoulli Equation from Euler Equation (+30 XP)', 30, true),
        StudentStudyTask('Draw Shear Force & Bending Moment Diagram for Cantilever', 25, false),
        StudentStudyTask('Review Carnot Cycle P-V & T-S Diagrams', 20, false),
      ];
    }

    if (std.contains('10th')) {
      return [
        StudentStudyTask('Daily Streak Check-in (+10 XP)', 10, true),
        StudentStudyTask('Draw Ray Diagrams for Convex Lens & Concave Mirror (+25 XP)', 25, true),
        StudentStudyTask('Practice 5 Trigonometric Identity Proofs', 30, false),
        StudentStudyTask('Solve Daily Science AI Quiz Challenge', 20, false),
      ];
    }

    if (_activeCategory.contains('Primary') || std.contains('1st')) {
      return [
        StudentStudyTask('Daily Streak Check-in (+10 XP)', 10, true),
        StudentStudyTask('Count 1 to 50 with colorful balloons game (+20 XP)', 20, true),
        StudentStudyTask('Draw 3 Triangles and 3 Squares with your favorite crayons', 15, false),
        StudentStudyTask('Listen to Phonics Alphabet Rhyme with AI Voice Tutor', 15, false),
      ];
    }

    return [
      StudentStudyTask('Daily Streak Check-in (+10 XP)', 10, true),
      StudentStudyTask('Review Today\'s Subject Lesson (+25 XP)', 25, true),
      StudentStudyTask('Practice 5 Practice Problems', 20, false),
      StudentStudyTask('Complete Daily AI Quiz Challenge', 15, false),
    ];
  }

  /// Returns searchable catalog topics for the Learn tab
  List<StudentCatalogTopic> getAdaptiveCatalogTopics() {
    final std = _activeStandard;

    if (std.contains('Computer Science') || std.contains('CSE')) {
      return const [
        StudentCatalogTopic('Binary Search Trees', 'Data Structures', 'Balanced AVL & Red-Black trees.', 0.80),
        StudentCatalogTopic('Graph Traversal', 'Data Structures', 'Breadth-First and Depth-First searches.', 0.75),
        StudentCatalogTopic('Dynamic Programming', 'Data Structures', 'Memoization and optimal sub-structure.', 0.40),
        StudentCatalogTopic('CPU Scheduling', 'Operating Systems', 'Round Robin, Priority & Multilevel queues.', 0.65),
        StudentCatalogTopic('Virtual Memory', 'Operating Systems', 'Paging, TLB, and page replacement algorithms.', 0.50),
        StudentCatalogTopic('Deadlocks & Mutex', 'Operating Systems', 'Banker algorithm and resource allocation graph.', 0.30),
        StudentCatalogTopic('Relational Algebra & SQL', 'DBMS', 'Joins, aggregate functions, and subqueries.', 0.85),
        StudentCatalogTopic('Database Normalization', 'DBMS', '1NF, 2NF, 3NF and BCNF functional dependencies.', 0.55),
        StudentCatalogTopic('TCP/IP Stack', 'Computer Networks', 'Handshake, windowing, and congestion control.', 0.70),
        StudentCatalogTopic('Routing Algorithms', 'Computer Networks', 'Dijkstra link-state and distance vector.', 0.45),
        StudentCatalogTopic('Neural Networks', 'Machine Learning', 'Perceptrons, activation functions and backpropagation.', 0.60),
      ];
    }

    if (std.contains('10th')) {
      return const [
        StudentCatalogTopic('Light Reflection', 'Physics', 'Spherical mirrors, focal length & magnification.', 0.75),
        StudentCatalogTopic('Light Refraction', 'Physics', 'Lenses, Snell\'s law & power of lens.', 0.70),
        StudentCatalogTopic('Electricity', 'Physics', 'Electric current, potential difference & Ohm\'s law.', 0.60),
        StudentCatalogTopic('Chemical Reactions', 'Chemistry', 'Balancing equations, redox & decomposition.', 0.80),
        StudentCatalogTopic('Acids, Bases & Salts', 'Chemistry', 'Indicators, pH scale & neutralization.', 0.50),
        StudentCatalogTopic('Carbon Compounds', 'Chemistry', 'Covalent bonding, homologous series & functional groups.', 0.35),
        StudentCatalogTopic('Quadratic Equations', 'Mathematics', 'Factorization, formula method & nature of roots.', 0.65),
        StudentCatalogTopic('Trigonometry', 'Mathematics', 'Trigonometric ratios, values table & identities.', 0.40),
        StudentCatalogTopic('Life Processes', 'Biology', 'Nutrition, respiration, transportation & excretion.', 0.85),
        StudentCatalogTopic('Heredity & Evolution', 'Biology', 'Mendelian inheritance and monohybrid crosses.', 0.45),
      ];
    }

    if (_activeCategory.contains('Primary') || std.contains('1st')) {
      return const [
        StudentCatalogTopic('Counting 1 to 100', 'Mathematics', 'Count fun items, fruits and toys.', 0.90),
        StudentCatalogTopic('2D & 3D Shapes', 'Mathematics', 'Circles, squares, triangles, cones & spheres.', 0.80),
        StudentCatalogTopic('Fun Addition', 'Mathematics', 'Add with apples, fingers and dots.', 0.60),
        StudentCatalogTopic('My Family & Home', 'EVS', 'Learn about parents, siblings and our lovely home.', 0.85),
        StudentCatalogTopic('Animals & Birds', 'EVS', 'Domestic pets, wild jungle animals and flying birds.', 0.75),
        StudentCatalogTopic('Plants & Flowers', 'EVS', 'Green leaves, colorful flowers and big trees.', 0.60),
        StudentCatalogTopic('Alphabet Phonics', 'English', 'Letters A to Z with happy songs and sounds.', 0.95),
        StudentCatalogTopic('Sight Words', 'English', 'Common words: the, and, is, are, you, my.', 0.70),
      ];
    }

    // Default Fallback
    return const [
      StudentCatalogTopic('Numbers & Operations', 'Maths', 'Learn numbers and operation properties.', 0.85),
      StudentCatalogTopic('Fractions & Decimals', 'Maths', 'Understand fractions step by step.', 0.65),
      StudentCatalogTopic('Algebra Foundations', 'Maths', 'Learn variables and algebraic expressions.', 0.30),
      StudentCatalogTopic('Photosynthesis', 'Science', 'Plants converting sunlight into energy & oxygen.', 0.72),
      StudentCatalogTopic('Force and Motion', 'Science', 'Understand force, speed, friction and motion.', 0.55),
      StudentCatalogTopic('Light & Vision', 'Science', 'Explore reflection, refraction and optical lenses.', 0.40),
      StudentCatalogTopic('Grammar & Tenses', 'English', 'Master nouns, verbs, present and past tenses.', 0.80),
      StudentCatalogTopic('History of Civilizations', 'Social Science', 'Key events and historical movements.', 0.45),
    ];
  }

  /// Returns grade-appropriate homework & assignments
  List<StudentAssignment> getAdaptiveAssignments() {
    final std = _activeStandard;

    // Engineering B.Tech CSE
    if (std.contains('Computer Science') || std.contains('CSE')) {
      return [
        StudentAssignment(
          id: 'cse-1',
          title: 'Implement Red-Black Tree & AVL Rotations',
          subject: 'Data Structures',
          teacher: 'Prof. S. Sen',
          dueDate: 'Due Tomorrow, 11:59 PM',
          problemsCount: 4,
          status: 'Due Soon',
          badgeColor: AppColors.secondary,
          description:
              'Write C++/Python implementations of self-balancing Red-Black trees and AVL rotations with unit tests.',
          tasks: [
            'Implement Left and Right rotations in C++/Python',
            'Handle Double-Red conflict resolution rules',
            'Verify O(log n) worst-case search & insert performance',
            'Submit GitHub repository link with unit tests',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'cse-2',
          title: 'Kernel Process Synchronization & IPC Lab',
          subject: 'Operating Systems',
          teacher: 'Dr. A. Joshi',
          dueDate: 'Due in 2 days',
          problemsCount: 3,
          status: 'In Progress',
          badgeColor: AppColors.primary,
          description:
              'Simulate producer-consumer and dining philosophers problem using semaphores and mutex locks.',
          tasks: [
            'Implement POSIX semaphore locks in C',
            'Prevent circular wait deadlock with strict hierarchy',
            'Profile context-switching latency and thread overhead',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'cse-3',
          title: 'Relational Schema BCNF Decomposition & SQL DDL',
          subject: 'DBMS',
          teacher: 'Prof. R. Verma',
          dueDate: 'Submitted Yesterday',
          problemsCount: 3,
          status: 'Completed',
          badgeColor: AppColors.success,
          description:
              'Compute functional dependency closures, check for lossless joins, and decompose relations into BCNF.',
          tasks: [
            'Compute attribute closures for functional dependencies',
            'Decompose tables into Lossless Join BCNF schemas',
            'Write SQL schema creation DDL with foreign keys',
          ],
          isSubmitted: true,
        ),
      ];
    }

    // Engineering Mechanical
    if (std.contains('Mechanical')) {
      return [
        StudentAssignment(
          id: 'mech-1',
          title: 'Steam Turbine Rankine Cycle Simulation',
          subject: 'Thermodynamics',
          teacher: 'Prof. K. Patel',
          dueDate: 'Due Tomorrow, 5:00 PM',
          problemsCount: 4,
          status: 'Due Soon',
          badgeColor: AppColors.secondary,
          description:
              'Calculate thermal efficiency, reheat cycle work output, and boiler heat supply parameters.',
          tasks: [
            'Plot Rankine T-s diagram with superheat state',
            'Compute steam enthalpy from Mollier charts',
            'Calculate overall thermal cycle efficiency',
            'Submit MATLAB / Excel calculation report',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'mech-2',
          title: 'FEA Stress Simulation of Cantilever Beam',
          subject: 'Strength of Materials',
          teacher: 'Dr. M. Nair',
          dueDate: 'Due in 3 days',
          problemsCount: 3,
          status: 'In Progress',
          badgeColor: AppColors.primary,
          description:
              'Perform static structural deflection and von Mises stress distribution analysis on an I-beam section.',
          tasks: [
            'Model standard I-beam cross-section geometry',
            'Apply fixed constraints and point loads',
            'Evaluate maximum shear stress and deflection contour',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'mech-3',
          title: 'Kinematic Synthesis of Robotic Gripper Mechanism',
          subject: 'Dynamics of Machines',
          teacher: 'Prof. V. Mehta',
          dueDate: 'Submitted Yesterday',
          problemsCount: 3,
          status: 'Completed',
          badgeColor: AppColors.success,
          description:
              'Synthesize four-bar linkage for angular displacement of pick-and-place robotic end-effector.',
          tasks: [
            'Determine link lengths using Freudenstein equation',
            'Plot coupler curve trajectory in GeoGebra / CAD',
            'Verify minimum transmission angle > 45 degrees',
          ],
          isSubmitted: true,
        ),
      ];
    }

    // High School (10th Standard)
    if (std.contains('10th')) {
      return [
        StudentAssignment(
          id: '10-1',
          title: 'Quadratic Equations Practice Set',
          subject: 'Maths',
          teacher: 'Mr. Sharma',
          dueDate: 'Due Tomorrow, 5:00 PM',
          problemsCount: 5,
          status: 'Due Soon',
          badgeColor: AppColors.secondary,
          description:
              'Solve 5 quadratic equations using the factorization method and write down step-by-step solutions.',
          tasks: [
            'Solve: x² - 5x + 6 = 0',
            'Solve: 2x² + 7x + 3 = 0',
            'Find roots: x² - 9 = 0',
            'Word problem: The sum of two numbers is 15...',
            'Verify discriminant b² - 4ac for real roots',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: '10-2',
          title: 'Photosynthesis Lab Diagram & Notes',
          subject: 'Science',
          teacher: 'Dr. Rao',
          dueDate: 'Due in 3 days',
          problemsCount: 3,
          status: 'In Progress',
          badgeColor: AppColors.primary,
          description:
              'Draw the cross-section of a leaf showing stomata and chloroplasts, and write the balanced chemical equation.',
          tasks: [
            'Draw chloroplast structure diagram',
            'State function of chlorophyll pigment',
            'Write complete balanced equation',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: '10-3',
          title: 'Formal Letter to Municipal Commissioner',
          subject: 'English',
          teacher: 'Mrs. Kapoor',
          dueDate: 'Submitted Yesterday',
          problemsCount: 1,
          status: 'Completed',
          badgeColor: AppColors.success,
          description:
              'Draft a 150-word letter highlighting the need for a public study library in the neighborhood.',
          tasks: [
            'Sender and Receiver address formatting',
            'Clear subject line',
            '3 body paragraphs with formal tone',
          ],
          isSubmitted: true,
        ),
      ];
    }

    // Higher Secondary (12th Standard Science)
    if (std.contains('12th') || std.contains('Higher Secondary')) {
      return [
        StudentAssignment(
          id: '12-1',
          title: 'Gauss\'s Law & Capacitance Network Proofs',
          subject: 'Physics',
          teacher: 'Dr. Sengupta',
          dueDate: 'Due Tomorrow, 6:00 PM',
          problemsCount: 4,
          status: 'Due Soon',
          badgeColor: AppColors.secondary,
          description:
              'Derive electric field using cylindrical Gaussian surfaces and compute equivalent capacitance.',
          tasks: [
            'Electric field of infinite line charge',
            'Parallel plate capacitor with dielectric slab',
            'Energy stored in electrostatic field',
            'Kirchhoff circuit loop analysis',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: '12-2',
          title: 'Definite Integrals by Substitution & Partial Fractions',
          subject: 'Mathematics',
          teacher: 'Prof. Ramanujan',
          dueDate: 'Due in 2 days',
          problemsCount: 4,
          status: 'In Progress',
          badgeColor: AppColors.primary,
          description:
              'Solve standard definite integral properties and evaluate bounded area under curves.',
          tasks: [
            'Evaluate integral with symmetry properties',
            'Area between parabola and line',
            'Partial fraction decomposition',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: '12-3',
          title: 'Chemical Kinetics Rate Law & Arrhenius Activation Energy',
          subject: 'Chemistry',
          teacher: 'Dr. Mukherjee',
          dueDate: 'Submitted Yesterday',
          problemsCount: 3,
          status: 'Completed',
          badgeColor: AppColors.success,
          description:
              'Determine reaction orders from experimental concentration data and plot ln(k) vs 1/T.',
          tasks: [
            'Calculate initial reaction rate order',
            'Plot Arrhenius slope for Ea activation energy',
            'Half-life calculation for 1st order decomposition',
          ],
          isSubmitted: true,
        ),
      ];
    }

    // Primary School (1st Standard)
    if (_activeCategory.contains('Primary') || std.contains('1st')) {
      return [
        StudentAssignment(
          id: 'pri-1',
          title: 'Count 20 Cute Jungle Animals & Match 3D Shapes',
          subject: 'Fun Maths',
          teacher: 'Miss Daisy',
          dueDate: 'Due Tomorrow, 4:00 PM',
          problemsCount: 3,
          status: 'Due Soon',
          badgeColor: AppColors.secondary,
          description:
              'Count the friendly tigers and monkeys in the picture and draw circles around triangles.',
          tasks: [
            'Count 10 striped tigers',
            'Count 10 playful monkeys',
            'Color 3 big round circles blue',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'pri-2',
          title: 'Draw Living Plants & Color the 5 Senses Explorer Sheet',
          subject: 'EVS',
          teacher: 'Miss Sunita',
          dueDate: 'Due in 2 days',
          problemsCount: 2,
          status: 'In Progress',
          badgeColor: AppColors.primary,
          description:
              'Color the parts of a little flower plant (roots, stem, leaves, petals) using bright crayons.',
          tasks: [
            'Color the green leaves',
            'Draw the yellow sun shining on the flower',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'pri-3',
          title: 'Alphabet Phonics Rhyme Recording with AI Voice Tutor',
          subject: 'English Phonics',
          teacher: 'Miss Lily',
          dueDate: 'Submitted Yesterday',
          problemsCount: 1,
          status: 'Completed',
          badgeColor: AppColors.success,
          description:
              'Sing along to the Alphabet Phonics Song with the friendly EduSpark Voice Mascot.',
          tasks: [
            'Practice letters A to Z sounds',
            'Record 30-second audio reading',
          ],
          isSubmitted: true,
        ),
      ];
    }

    // Medical (MBBS)
    if (std.contains('MBBS') || _activeCategory.contains('Medical')) {
      return [
        StudentAssignment(
          id: 'mbbs-1',
          title: 'Cardiovascular Electrophysiology & 12-Lead ECG Analysis',
          subject: 'Medical Physiology',
          teacher: 'Dr. K. Bhargava',
          dueDate: 'Due Tomorrow, 5:00 PM',
          problemsCount: 4,
          status: 'Due Soon',
          badgeColor: AppColors.secondary,
          description:
              'Analyze cardiac action potential phases, PR interval prolongation, and axis deviation on standard 12-lead ECG strips.',
          tasks: [
            'Explain ventricular depolarization QRS wave',
            'Calculate heart rate from R-R intervals',
            'Identify STEMI anterior wall elevation signs',
            'Submit annotated ECG diagnostic report',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'mbbs-2',
          title: 'Brachial Plexus Nerve Injury Case Study & Dissection',
          subject: 'Human Anatomy',
          teacher: 'Dr. Roy',
          dueDate: 'Due in 3 days',
          problemsCount: 3,
          status: 'In Progress',
          badgeColor: AppColors.primary,
          description:
              'Map roots, trunks, divisions, and terminal branches of brachial plexus with clinical correlation to Erb-Duchenne palsy.',
          tasks: [
            'Trace roots C5-T1 cords and terminal nerves',
            'Differentiate upper vs lower trunk injury symptoms',
            'Identify motor deficit in deltoid/biceps',
          ],
          isSubmitted: false,
        ),
        StudentAssignment(
          id: 'mbbs-3',
          title: 'Krebs TCA Cycle Enzymatic Regulation & ATP Yield',
          subject: 'Medical Biochemistry',
          teacher: 'Dr. Deshmukh',
          dueDate: 'Submitted Yesterday',
          problemsCount: 3,
          status: 'Completed',
          badgeColor: AppColors.success,
          description:
              'Detail pyruvate dehydrogenase complex regulation, rate-limiting isocitrate dehydrogenase step, and total ATP stoichiometry.',
          tasks: [
            'Write net aerobic ATP calculation equation',
            'Map allosteric inhibition by ATP/NADH',
            'Clinical impact of thiamine deficiency in lactic acidosis',
          ],
          isSubmitted: true,
        ),
      ];
    }

    // General Fallback
    return [
      StudentAssignment(
        id: 'gen-1',
        title: 'Weekly Subject Practice Worksheet',
        subject: 'Core Subject',
        teacher: 'Lead Instructor',
        dueDate: 'Due Tomorrow, 5:00 PM',
        problemsCount: 5,
        status: 'Due Soon',
        badgeColor: AppColors.secondary,
        description:
            'Complete standard practice problems and summarize key formulas and definitions.',
        tasks: [
          'Solve Chapter review questions 1 to 5',
          'Summarize key principles in 100 words',
          'Upload handwritten or digital solution',
        ],
        isSubmitted: false,
      ),
      StudentAssignment(
        id: 'gen-2',
        title: 'Interactive Conceptual Study Notes',
        subject: 'Applied Learning',
        teacher: 'Academic Mentor',
        dueDate: 'Due in 3 days',
        problemsCount: 3,
        status: 'In Progress',
        badgeColor: AppColors.primary,
        description:
            'Review interactive study notes and answer self-assessment questions.',
        tasks: [
          'Review active topic notes',
          'Complete 5 practice MCQs with AI tutor feedback',
        ],
        isSubmitted: false,
      ),
      StudentAssignment(
        id: 'gen-3',
        title: 'Unit Assessment Submission',
        subject: 'General Assessment',
        teacher: 'Class Faculty',
        dueDate: 'Submitted Yesterday',
        problemsCount: 1,
        status: 'Completed',
        badgeColor: AppColors.success,
        description:
            'Comprehensive unit review and practice assignment submission.',
        tasks: [
          'Verify all questions answered',
          'Review tutor feedback and corrections',
        ],
        isSubmitted: true,
      ),
    ];
  }
}
