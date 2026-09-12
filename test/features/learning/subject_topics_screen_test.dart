import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eduspark/features/learning/presentation/screens/subject_topics_screen.dart';

void main() {
  group('SubjectTopicsScreen Curriculum Tests', () {
    testWidgets(
      'Operating Systems & Kernel shows OS modules and never History/Civics',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: SubjectTopicsScreen(
              subject: 'Operating Systems & Kernel',
              icon: Icons.developer_board_rounded,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must display actual OS topics
        expect(find.text('Operating Systems & Kernel'), findsNWidgets(2));
        expect(find.text('Process Management & Lifecycle'), findsOneWidget);
        expect(find.text('CPU Scheduling Algorithms'), findsOneWidget);
        expect(find.text('Process Synchronization & Concurrency'), findsOneWidget);
        expect(find.text('Deadlocks & Banker\'s Algorithm'), findsOneWidget);

        // Must NEVER display unrelated social studies topics
        expect(find.text('History'), findsNothing);
        expect(find.text('Geography'), findsNothing);
        expect(find.text('Civics'), findsNothing);
        expect(find.text('Economics'), findsNothing);
      },
    );

    testWidgets(
      'Data Structures & Algorithms shows DSA topics without Social Science',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: SubjectTopicsScreen(
              subject: 'Data Structures & Algorithms',
              icon: Icons.account_tree_rounded,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Arrays & Dynamic Sizing'), findsOneWidget);
        expect(find.text('Linked Lists & Pointer Manipulation'), findsOneWidget);
        expect(find.text('Stacks & Queues'), findsOneWidget);

        // Must NEVER display social science
        expect(find.text('History'), findsNothing);
        expect(find.text('Civics'), findsNothing);
      },
    );

    testWidgets(
      'Database Management (DBMS) shows Relational and SQL topics',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: SubjectTopicsScreen(
              subject: 'Database Management (DBMS)',
              icon: Icons.storage_rounded,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Relational Model & ER Diagrams'), findsOneWidget);
        expect(find.text('Relational Algebra & Tuple Calculus'), findsOneWidget);
        expect(find.text('Advanced SQL & Aggregations'), findsOneWidget);

        expect(find.text('History'), findsNothing);
        expect(find.text('Civics'), findsNothing);
      },
    );

    testWidgets(
      'Unknown custom subject produces dynamic domain-aware topics instead of History/Civics',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: SubjectTopicsScreen(
              subject: 'Quantum Computing',
              icon: Icons.hub_rounded,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Quantum Computing: Core Principles & Definitions'), findsOneWidget);
        expect(find.text('History'), findsNothing);
        expect(find.text('Civics'), findsNothing);
      },
    );
  });
}
