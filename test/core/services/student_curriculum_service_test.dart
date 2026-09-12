import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduspark/core/services/student_curriculum_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StudentCurriculumService Tests', () {
    test('Initializes with default Engineering CSE curriculum', () async {
      final srv = StudentCurriculumService.instance;
      await srv.init();

      expect(srv.activeCategory, contains('Engineering'));
      expect(srv.activeStandard, contains('Computer Science'));

      final subjects = srv.getAdaptiveSubjects();
      expect(subjects.isNotEmpty, isTrue);
      expect(subjects.any((s) => s.title.contains('Data Structures')), isTrue);
      expect(subjects.any((s) => s.title.contains('Operating Systems')), isTrue);

      final continueLearning = srv.getAdaptiveContinueLearning();
      expect(continueLearning.topic, contains('Graph Traversal'));
      expect(continueLearning.subject, contains('Data Structures'));

      final concept = srv.getAdaptiveConceptOfDay();
      expect(concept.title, contains('Master Theorem'));
      expect(concept.formulaEquation, contains('T(n) = a T(n/b)'));

      final tasks = srv.getAdaptiveDailyTasks();
      expect(tasks.length, greaterThanOrEqualTo(3));
      expect(tasks.any((t) => t.title.contains('Graph BFS / DFS')), isTrue);

      final catalog = srv.getAdaptiveCatalogTopics();
      expect(catalog.any((t) => t.title.contains('Data Structures') || t.title.contains('Binary Search')), isTrue);
    });

    test('Switches to High School 10th Standard dynamically', () async {
      final srv = StudentCurriculumService.instance;
      await srv.setCurriculum(
        'High School (Classes 9 & 10)',
        '10th Standard (Board Exam Prep)',
      );

      expect(srv.activeCategory, equals('High School (Classes 9 & 10)'));
      expect(srv.activeStandard, equals('10th Standard (Board Exam Prep)'));

      final subjects = srv.getAdaptiveSubjects();
      expect(subjects.any((s) => s.title == 'Physics'), isTrue);
      expect(subjects.any((s) => s.title == 'Mathematics'), isTrue);
      expect(subjects.any((s) => s.title == 'Chemistry'), isTrue);

      final continueLearning = srv.getAdaptiveContinueLearning();
      expect(continueLearning.topic, contains('Light: Reflection'));
      expect(continueLearning.subject, contains('Physics'));

      final concept = srv.getAdaptiveConceptOfDay();
      expect(concept.title, contains("Snell's Law"));
      expect(concept.formulaEquation, contains('n_1 \\sin\\theta_1'));

      final tasks = srv.getAdaptiveDailyTasks();
      expect(tasks.any((t) => t.title.contains('Trigonometric')), isTrue);

      final catalog = srv.getAdaptiveCatalogTopics();
      expect(catalog.any((t) => t.title.contains('Ray Optics') || t.title.contains('Light')), isTrue);
    });

    test('Switches to Primary 1st Standard foundational curriculum', () async {
      final srv = StudentCurriculumService.instance;
      await srv.setCurriculum(
        'Primary School (Classes 1 - 5)',
        '1st Standard (Bluebells)',
      );

      expect(srv.activeCategory, equals('Primary School (Classes 1 - 5)'));
      expect(srv.activeStandard, equals('1st Standard (Bluebells)'));

      final subjects = srv.getAdaptiveSubjects();
      expect(subjects.any((s) => s.title.contains('Fun Mathematics')), isTrue);
      expect(subjects.any((s) => s.title.contains('Phonics')), isTrue);

      final continueLearning = srv.getAdaptiveContinueLearning();
      expect(continueLearning.topic, contains('Animal Counting'));
      expect(continueLearning.subject, contains('Fun Mathematics'));

      final concept = srv.getAdaptiveConceptOfDay();
      expect(concept.title, contains('Shapes Around Us'));

      final tasks = srv.getAdaptiveDailyTasks();
      expect(tasks.any((t) => t.title.contains('colorful balloons')), isTrue);
    });

    test('Switches to Medical MBBS degree curriculum', () async {
      final srv = StudentCurriculumService.instance;
      await srv.setCurriculum(
        'Medical & Health Sciences',
        'MBBS / Medical Specialization',
      );

      expect(srv.activeCategory, equals('Medical & Health Sciences'));
      expect(srv.activeStandard, equals('MBBS / Medical Specialization'));

      final subjects = srv.getAdaptiveSubjects();
      expect(subjects.any((s) => s.title.contains('Human Anatomy')), isTrue);
      expect(subjects.any((s) => s.title.contains('Medical Physiology')), isTrue);

      final continueLearning = srv.getAdaptiveContinueLearning();
      expect(continueLearning.topic, contains('Cardiac Electrophysiology'));
      expect(continueLearning.subject, contains('Medical Physiology'));
    });

    test('Available standards map reflects curriculum tree', () {
      final srv = StudentCurriculumService.instance;
      final map = srv.availableStandardsMap;

      expect(map.containsKey('Undergraduate Degrees (Engineering)'), isTrue);
      expect(map.containsKey('High School (Classes 9 & 10)'), isTrue);
      expect(map.containsKey('Primary School (Classes 1 - 5)'), isTrue);
      expect(map.containsKey('Medical & Health Sciences'), isTrue);

      final engBranches = map['Undergraduate Degrees (Engineering)']!;
      expect(engBranches.any((b) => b.contains('Computer Science')), isTrue);
      expect(engBranches.any((b) => b.contains('Mechanical')), isTrue);
    });

    test('Persists curriculum across reload', () async {
      final srv = StudentCurriculumService.instance;
      await srv.setCurriculum(
        'Higher Secondary (Classes 11 & 12)',
        '12th Standard (Science - PCM/PCB)',
      );

      // Verify in SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('student_active_category'), equals('Higher Secondary (Classes 11 & 12)'));
      expect(prefs.getString('student_active_standard'), equals('12th Standard (Science - PCM/PCB)'));

      // Re-initialize and ensure it retains
      await srv.init();
      expect(srv.activeCategory, equals('Higher Secondary (Classes 11 & 12)'));
      expect(srv.activeStandard, equals('12th Standard (Science - PCM/PCB)'));
    });

    test('Adaptive assignments change according to enrolled standard/degree', () async {
      final srv = StudentCurriculumService.instance;

      // Check CSE assignments
      await srv.setCurriculum(
        'Undergraduate Degrees (Engineering)',
        'B.Tech Computer Science & Engineering (CSE)',
      );
      final cseAssignments = srv.getAdaptiveAssignments();
      expect(cseAssignments.length, equals(3));
      expect(cseAssignments.first.title, contains('Red-Black Tree'));
      expect(cseAssignments.first.subject, equals('Data Structures'));
      expect(cseAssignments.any((a) => a.title.contains('Kernel Process Synchronization')), isTrue);
      expect(cseAssignments.any((a) => a.title.contains('Relational Schema BCNF')), isTrue);

      // Check 10th Standard assignments
      await srv.setCurriculum(
        'High School (Classes 9 & 10)',
        '10th Standard (Board Exam Prep)',
      );
      final hsAssignments = srv.getAdaptiveAssignments();
      expect(hsAssignments.first.title, contains('Quadratic Equations'));
      expect(hsAssignments.first.subject, equals('Maths'));
      expect(hsAssignments.any((a) => a.title.contains('Photosynthesis')), isTrue);
    });
  });
}
