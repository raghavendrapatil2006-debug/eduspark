import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eduspark/core/services/teacher_curriculum_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TeacherCurriculumService Tests', () {
    test('Initializes with default Engineering CSE focus', () async {
      final srv = TeacherCurriculumService.instance;
      await srv.init();

      expect(srv.activeCategory, contains('Engineering'));
      expect(srv.activeBranch, contains('Computer Science'));
      expect(srv.activeSubject, equals('Data Structures & Algorithms'));

      final schedule = srv.getAdaptiveSchedule();
      expect(schedule.isNotEmpty, isTrue);
      expect(schedule.first.subject, contains('Data Structures & Algorithms'));

      final atRisk = srv.getAdaptiveAtRiskStudents();
      expect(atRisk.isNotEmpty, isTrue);
      expect(atRisk.first.subject, contains('Data Structures & Algorithms'));
    });

    test('Switches to High School 10th Standard Physics dynamically', () async {
      final srv = TeacherCurriculumService.instance;
      await srv.setActiveTeachingFocus(
        category: 'High School (Classes 9 & 10)',
        branch: '10th Standard (Board Exam Prep)',
        subject: 'Physics • Optics, Electricity & Magnetism',
      );

      expect(srv.activeCategory, equals('High School (Classes 9 & 10)'));
      expect(srv.activeBranch, equals('10th Standard (Board Exam Prep)'));
      expect(
        srv.activeSubject,
        equals('Physics • Optics, Electricity & Magnetism'),
      );

      final schedule = srv.getAdaptiveSchedule();
      expect(schedule.first.className, equals('Class 10-A'));
      expect(
        schedule.first.subject,
        contains('Physics • Optics, Electricity & Magnetism'),
      );

      final atRisk = srv.getAdaptiveAtRiskStudents();
      expect(atRisk.first.name, equals('Rohan Sharma'));
      expect(
        atRisk.first.subject,
        equals('Physics • Optics, Electricity & Magnetism'),
      );

      final homework = srv.getAdaptiveHomeworkList();
      expect(
        homework.first['subject'],
        equals('Physics • Optics, Electricity & Magnetism'),
      );
    });

    test('Switches to Primary School Kindergarten dynamically', () async {
      final srv = TeacherCurriculumService.instance;
      await srv.setActiveTeachingFocus(
        category: 'Primary School (Classes 1 - 5)',
        branch: '1st Standard (Bluebells)',
        subject: 'Mathematics • 2D/3D Shapes & Fun Counting',
      );

      expect(srv.activeBranch, equals('1st Standard (Bluebells)'));

      final schedule = srv.getAdaptiveSchedule();
      expect(schedule.first.standardBadge, equals('Primary Level'));
      expect(
        schedule.first.subject,
        contains('Mathematics • 2D/3D Shapes & Fun Counting'),
      );

      final atRisk = srv.getAdaptiveAtRiskStudents();
      expect(atRisk.first.name, equals('Ananya Verma'));
    });

    test('Curriculum tree contains requested Engineering branches and subjects', () {
      final tree = TeacherCurriculumService.curriculumTree;
      expect(tree.containsKey('Undergraduate Degrees (Engineering)'), isTrue);

      final engBranches = tree['Undergraduate Degrees (Engineering)']!;
      expect(engBranches.containsKey('B.Tech Computer Science & Engineering (CSE)'), isTrue);
      expect(engBranches.containsKey('B.Tech Mechanical Engineering'), isTrue);
      expect(engBranches.containsKey('B.Tech Electrical & Electronics (EEE/ECE)'), isTrue);
      expect(engBranches.containsKey('B.Tech Civil Engineering'), isTrue);
      expect(engBranches.containsKey('B.Tech AI & Data Science'), isTrue);

      final cseSubjects = engBranches['B.Tech Computer Science & Engineering (CSE)']!;
      expect(cseSubjects, contains('Data Structures & Algorithms'));
      expect(cseSubjects, contains('Operating Systems & Kernel Arch'));
      expect(cseSubjects, contains('Database Management Systems (DBMS)'));
      expect(cseSubjects, contains('Computer Networks & Protocols'));
    });
  });
}
