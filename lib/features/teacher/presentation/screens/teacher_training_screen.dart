import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/training_module_detail_sheet.dart';
import '../widgets/mock_classroom_simulator_sheet.dart';
import '../widgets/teacher_certificate_sheet.dart';

class TeacherTrainingScreen extends StatefulWidget {
  const TeacherTrainingScreen({super.key});

  @override
  State<TeacherTrainingScreen> createState() => _TeacherTrainingScreenState();
}

class _TeacherTrainingScreenState extends State<TeacherTrainingScreen> {
  final String _teacherName = 'Prof. Raghavendra';

  late List<TrainingModule> _modules;

  @override
  void initState() {
    super.initState();
    _modules = [
      TrainingModule(
        id: 'mod-1',
        title: 'Mastering EduSpark: AI-Powered Classroom Hub',
        category: 'FOUNDATIONAL ONBOARDING',
        duration: '15 mins',
        xpReward: 50,
        isCompleted: true,
        description:
            'Learn how to leverage the EduSpark educator suite to manage student rosters, schedule daily periods, monitor attendance, and review homework submissions effortlessly.',
        keyTakeaways: [
          'Switch seamlessly between Teacher Dashboard and Student View to preview learning materials.',
          'Synchronize class rosters with your school or university curriculum management system.',
          'Access quick-action shortcuts to assign homework, generate tests, and broadcast announcements.',
        ],
        questions: const [
          TrainingQuizQuestion(
            question:
                'What is the quickest way for a teacher to preview how a lesson appears to their students?',
            options: [
              'Log out and create a fake student email',
              'Use the 1-tap "Switch to Student View" button on the dashboard header',
              'Ask a student to take a photo of their phone screen',
              'Wait until the end of the semester',
            ],
            correctIndex: 1,
            explanation:
                'The Teacher Dashboard features an instant "Switch to Student View" toggle that allows educators to preview all study materials from the student perspective.',
          ),
          TrainingQuizQuestion(
            question:
                'Where can teachers record student roll call and mark Present, Late, or Absent?',
            options: [
              'Only on physical paper sheets',
              'Inside the Class Roster & Attendance bottom sheet for any scheduled session',
              'In the user profile settings menu',
              'Via the public noticeboard',
            ],
            correctIndex: 1,
            explanation:
                'Teachers can open any scheduled class session on their dashboard and tap "Take Attendance" to mark P/L/A in seconds.',
          ),
        ],
      ),
      TrainingModule(
        id: 'mod-2',
        title: 'Standard-Adaptive Pedagogy from KG to PhD',
        category: 'PEDAGOGY & DIFFERENTIATION',
        duration: '20 mins',
        xpReward: 75,
        isCompleted: true,
        description:
            'Understand how EduSpark dynamically adjusts AI vocabulary, conceptual depth, analogy styles, and mathematical rigor based on the student’s declared standard—from Kindergarten fun storytelling to B.Tech algorithms and PhD research.',
        keyTakeaways: [
          'Kindergarten to 2nd Standard receives playful storytelling with emojis, counting items, and very short sentences.',
          'High School students (9th-10th) receive rigorous board-aligned definitions and exam problem-solving steps.',
          'College & Graduate students (B.Tech, MBBS, PhD) receive university-grade proofs, algorithmic complexity, and academic literature context.',
          'Teachers can generate lesson plans and exam papers tailored to any specific standard with one tap.',
        ],
        questions: const [
          TrainingQuizQuestion(
            question:
                'How does EduSpark explain a concept like "Gravity" to a 1st Standard student compared to a B.Tech student?',
            options: [
              'It gives the exact same tensor calculus equation to both',
              'It uses playful analogies (like dropping an apple or toy) for 1st Std, and mathematical derivations/gravitational field equations for B.Tech',
              'It refuses to explain science to young children',
              'It only provides audio clips for college students',
            ],
            correctIndex: 1,
            explanation:
                'EduSpark is standard-adaptive: it utilizes storytelling and tangible toys for early childhood, while delivering full mathematical rigor and field mechanics for university students.',
          ),
          TrainingQuizQuestion(
            question:
                'What happens when a student updates their education standard in their profile?',
            options: [
              'Nothing changes until next year',
              'The AI Tutor instantly recalibrates all subsequent answers, quizzes, and notes to match the new grade level',
              'All previous points are reset to zero',
              'The app locks the account',
            ],
            correctIndex: 1,
            explanation:
                'UserProfileService instantly notifies GeminiService, ensuring all future prompts dynamically use the pedagogical instructions tailored to that exact grade level.',
          ),
        ],
      ),
      TrainingModule(
        id: 'mod-3',
        title: 'Curriculum & 45-Minute Lesson Design with Gemini',
        category: 'LESSON PLANNING',
        duration: '25 mins',
        xpReward: 75,
        isCompleted: true,
        description:
            'Master the art of generating high-engagement lesson plans using the AI Lesson Planner. Discover how to create captivating 5-minute hooks, whiteboard illustration prompts, collaborative student drills, and exit tickets.',
        keyTakeaways: [
          'Every AI-generated lesson plan begins with 3 clear, measurable learning outcomes.',
          'Use the "Hook & Real-World Connection" to overcome initial student apathy in the first 5 minutes.',
          'Follow the Whiteboard Drawing Prompts to give students visual anchors during direct instruction.',
          'Execute the 3-question rapid-fire exit check before dismissing the class.',
        ],
        questions: const [
          TrainingQuizQuestion(
            question:
                'What is the purpose of the 5-minute "Hook" in the AI Lesson Planner?',
            options: [
              'To test students with a surprise exam',
              'To spark immediate curiosity and emotional connection with real-world relevance',
              'To take silent attendance without talking',
              'To give students time to sleep',
            ],
            correctIndex: 1,
            explanation:
                'The Hook is designed to break passivity and connect the abstract topic to students daily reality in the first 5 to 7 minutes.',
          ),
          TrainingQuizQuestion(
            question:
                'How can teachers transfer an AI lesson plan into their teaching notes?',
            options: [
              'By retyping every sentence by hand',
              'Using the 1-tap "Copy All" or "Export" buttons directly from the plan preview',
              'Taking a screenshot and emailing it to themselves',
              'Lesson plans cannot be copied',
            ],
            correctIndex: 1,
            explanation:
                'The AI Lesson Planner includes a convenient "Copy All" button that instantly copies the entire formatted markdown plan to the system clipboard.',
          ),
        ],
      ),
      TrainingModule(
        id: 'mod-4',
        title: 'Balanced Exam Design & AI Formative Assessment',
        category: 'ASSESSMENT & EVALUATION',
        duration: '20 mins',
        xpReward: 75,
        isCompleted: false,
        description:
            'Learn how to create balanced test papers featuring Section A (MCQs), Section B (Short Conceptual), Section C (Derivations & Problems), along with complete marking schemes and teacher answer keys.',
        keyTakeaways: [
          'Design differentiated tests ranging from Foundational to Competitive Olympiad difficulty.',
          'Leverage Gemini AI pre-evaluation on student homework to speed up grading by 3x.',
          'Provide encouraging, constructive feedback alongside numerical scores to promote growth mindset.',
        ],
        questions: const [
          TrainingQuizQuestion(
            question:
                'Why does the AI Exam Maker generate a Teacher Answer Key and Marking Scheme?',
            options: [
              'Only for students to copy the answers',
              'To provide teachers with step-by-step marking rubrics and expected core keywords for consistent grading',
              'It is generated by accident',
              'To fill extra space on the paper',
            ],
            correctIndex: 1,
            explanation:
                'The marking scheme provides explicit point allocations for each step, ensuring transparent, reliable, and uniform assessment.',
          ),
          TrainingQuizQuestion(
            question:
                'What does the AI Pre-evaluation feature do in the Teacher Grading Queue?',
            options: [
              'It deletes student homework automatically',
              'It inspects student work, checks formulas/test cases, and suggests an initial score and feedback for teacher verification',
              'It assigns random marks without checking',
              'It sends an email to the principal',
            ],
            correctIndex: 1,
            explanation:
                'Gemini pre-checks student homework and provides an estimated score and error detection, which the teacher reviews and approves.',
          ),
        ],
      ),
      TrainingModule(
        id: 'mod-5',
        title: 'Student Attention Radar & Proactive Interventions',
        category: 'LEARNER SUPPORT',
        duration: '15 mins',
        xpReward: 50,
        isCompleted: false,
        description:
            'Discover how EduSpark detects when a student’s comprehension drops below threshold, and how to execute targeted 1-tap remedial drills and encouragement notes before they fall behind.',
        keyTakeaways: [
          'The AI Attention Radar highlights students whose quiz scores dropped or who struggle with specific concepts.',
          'Assign tailored practice drills directly from the alert card without searching for worksheets.',
          'Send personalized positive reinforcement to boost learner confidence and engagement.',
        ],
        questions: const [
          TrainingQuizQuestion(
            question:
                'When does the AI Student Attention Radar flag a student on the Teacher Dashboard?',
            options: [
              'When the student logs in to the app',
              'When a student scores below comprehension threshold or misses consecutive homework milestones',
              'Only at the end of the academic year',
              'When a student earns too many XP points',
            ],
            correctIndex: 1,
            explanation:
                'The radar proactively flags struggling learners early so teachers can intervene before exams.',
          ),
          TrainingQuizQuestion(
            question:
                'What is the recommended action when a student is flagged on the Attention Radar?',
            options: [
              'Punish the student publicly',
              'Use 1-tap "Assign Practice" to send targeted micro-drills and send a supportive encouragement note',
              'Ignore the alert and continue with the syllabus',
              'Remove the student from the class roster',
            ],
            correctIndex: 1,
            explanation:
                'EduSpark empowers teachers to provide immediate, supportive, targeted practice drills to close learning gaps quickly.',
          ),
        ],
      ),
    ];
  }

  int get _completedCount => _modules.where((m) => m.isCompleted).length;
  double get _progress => _completedCount / _modules.length;

  void _openModuleDetail(TrainingModule mod) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TrainingModuleDetailSheet(
        module: mod,
        onCompleted: () {
          setState(() {});
        },
      ),
    );
  }

  void _openClassroomSimulator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MockClassroomSimulatorSheet(),
    );
  }

  void _openCertificate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TeacherCertificateSheet(
        teacherName: _teacherName,
        completedModules: _completedCount,
        totalModules: _modules.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFullyCertified = _completedCount >= _modules.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Teacher Training & Induction',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'View Professional Certificate',
            onPressed: _openCertificate,
            icon: Icon(
              Icons.workspace_premium_rounded,
              color: isFullyCertified ? AppColors.secondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // Certification Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  const Color(0xFF818CF8).withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FACULTY INDUCTION TRACK',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}% Completed',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isFullyCertified
                      ? 'Certified EduSpark AI Educator 🎉'
                      : 'Professional Induction in Progress',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_completedCount of ${_modules.length} Modules completed • +${_completedCount * 75} Teacher XP earned',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFullyCertified ? AppColors.success : AppColors.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _openCertificate,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 16,
                        color: isFullyCertified
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isFullyCertified
                            ? 'View Official Certificate'
                            : 'Preview Certificate Requirements',
                        style: TextStyle(
                          color: isFullyCertified
                              ? AppColors.secondary
                              : AppColors.primary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: isFullyCertified
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Interactive Practice Banner: AI Teaching Simulator
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.record_voice_over_rounded,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Classroom Teaching Simulator',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Practice teaching virtual students and receive instant pedagogical coaching.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _openClassroomSimulator,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Launch Teaching Lab',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Title
          const Text(
            'Professional Training Curriculum',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete all 5 modules and quizzes to earn your certified educator credential.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          // Module Cards
          ...List.generate(_modules.length, (idx) {
            final mod = _modules[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => _openModuleDetail(mod),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: mod.isCompleted
                            ? AppColors.success.withValues(alpha: 0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: mod.isCompleted
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'MODULE ${idx + 1}',
                                style: TextStyle(
                                  color: mod.isCompleted
                                      ? AppColors.success
                                      : AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mod.duration,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11.5,
                              ),
                            ),
                            const Spacer(),
                            if (mod.isCompleted)
                              const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Certified',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${mod.xpReward} XP',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          mod.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mod.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              mod.isCompleted
                                  ? 'Review Module Takeaways'
                                  : 'Start Lesson & Knowledge Check',
                              style: TextStyle(
                                color: mod.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: mod.isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
