import 'package:flutter/material.dart';
import 'auth_service.dart';

class StudentDoubtItem {
  final String id;
  final String studentName;
  final String doubtText;
  final String timeAgo;
  bool isAnswered;
  String? teacherAnswer;
  String? aiSuggestedAnswer;

  StudentDoubtItem({
    required this.id,
    required this.studentName,
    required this.doubtText,
    required this.timeAgo,
    this.isAnswered = false,
    this.teacherAnswer,
    this.aiSuggestedAnswer,
  });
}

class LivePollItem {
  final String id;
  final String question;
  final List<String> options;
  final List<int> votes;
  bool isActive;

  LivePollItem({
    required this.id,
    required this.question,
    required this.options,
    required this.votes,
    this.isActive = true,
  });

  int get totalVotes => votes.fold(0, (sum, count) => sum + count);

  double getPercentage(int index) {
    if (totalVotes == 0) return 0.0;
    return (votes[index] / totalVotes) * 100;
  }
}

class OnlineClassSession {
  final String id;
  final String title;
  final String subject;
  final String targetStandard;
  final String hostTeacherName;
  final String scheduledTime;
  String status; // 'live', 'scheduled', 'completed'
  final String roomCode;
  final String meetingLink;
  final String platform; // 'EduSpark Live Stage', 'Google Meet', 'Zoom'
  int activeStudentCount;
  final int totalEnrolledCount;
  bool isWhiteboardActive;
  bool isScreenSharing;
  bool isRecording;
  bool isAiAssistantActive;
  final List<String> aiNotesSummary;
  final List<StudentDoubtItem> doubtsQueue;
  LivePollItem? activePoll;
  final List<Map<String, dynamic>> connectedStudents;

  OnlineClassSession({
    required this.id,
    required this.title,
    required this.subject,
    required this.targetStandard,
    required this.hostTeacherName,
    required this.scheduledTime,
    required this.status,
    required this.roomCode,
    required this.meetingLink,
    this.platform = 'EduSpark Live Stage',
    this.activeStudentCount = 0,
    required this.totalEnrolledCount,
    this.isWhiteboardActive = false,
    this.isScreenSharing = false,
    this.isRecording = false,
    this.isAiAssistantActive = true,
    required this.aiNotesSummary,
    required this.doubtsQueue,
    this.activePoll,
    required this.connectedStudents,
  });
}

class OnlineClassService extends ChangeNotifier {
  OnlineClassService._() {
    _initDefaultSessions();
  }

  static final OnlineClassService instance = OnlineClassService._();

  final List<OnlineClassSession> _sessions = [];

  List<OnlineClassSession> get sessions => List.unmodifiable(_sessions);

  List<OnlineClassSession> get liveSessions =>
      _sessions.where((s) => s.status == 'live').toList();

  List<OnlineClassSession> get upcomingSessions =>
      _sessions.where((s) => s.status == 'scheduled').toList();

  List<OnlineClassSession> get completedSessions =>
      _sessions.where((s) => s.status == 'completed').toList();

  OnlineClassSession? get currentLiveSession {
    final live = liveSessions;
    return live.isNotEmpty ? live.first : null;
  }

  void _initDefaultSessions() {
    _sessions.addAll([
      // Active Live Session
      OnlineClassSession(
        id: 'cls_live_optics',
        title: 'Wave Optics & Snell’s Law Calculations',
        subject: 'Physics',
        targetStandard: 'Class 10-A (High School)',
        hostTeacherName: AuthService.instance.currentUser?.name ?? 'Course Faculty',
        scheduledTime: '10:30 AM - 11:30 AM',
        status: 'live',
        roomCode: 'OPTICS-10A',
        meetingLink: 'https://eduspark.live/stage/optics-10a',
        activeStudentCount: 34,
        totalEnrolledCount: 38,
        isWhiteboardActive: true,
        isScreenSharing: false,
        isRecording: true,
        isAiAssistantActive: true,
        aiNotesSummary: [
          'Snell’s Law Definition: n1 · sin(θ1) = n2 · sin(θ2)',
          'Refractive index of glass = 1.5, water = 1.33, air ≈ 1.0',
          'Light bends towards normal when transitioning from rarer to denser medium',
          'Frequency of wave remains constant during refraction; wavelength and speed change',
        ],
        doubtsQueue: const [],
        activePoll: LivePollItem(
          id: 'poll_1',
          question:
              'When green light (532 nm) enters flint glass from air, what happens to its wavelength?',
          options: [
            'Decreases proportionally (λ / n)',
            'Increases proportionally (λ · n)',
            'Remains constant (532 nm)',
            'Changes into violet light',
          ],
          votes: [25, 4, 3, 2],
          isActive: true,
        ),
        connectedStudents: const [],
      ),

      // Upcoming Scheduled Class 1
      OnlineClassSession(
        id: 'cls_sch_dijkstra',
        title: 'Dijkstra & Bellman-Ford Shortest Path Coding',
        subject: 'Computer Science',
        targetStandard: 'B.Tech CSE (Semester 3)',
        hostTeacherName: AuthService.instance.currentUser?.name ?? 'Course Faculty',
        scheduledTime: 'Today, 01:30 PM - 02:45 PM',
        status: 'scheduled',
        roomCode: 'CSE-ALGO-3',
        meetingLink: 'https://eduspark.live/stage/cse-algo-3',
        activeStudentCount: 0,
        totalEnrolledCount: 46,
        isRecording: true,
        isAiAssistantActive: true,
        aiNotesSummary: [
          'Pre-reading: Priority Queue implementation using Min-Heap',
          'Graph representation: Adjacency List with edge weights',
          'Live coding exercise in Python/C++',
        ],
        doubtsQueue: [],
        connectedStudents: [],
      ),

      // Upcoming Scheduled Class 2
      OnlineClassSession(
        id: 'cls_sch_phd',
        title: 'Colloquium: Self-Attention & Transformer Convergence',
        subject: 'AI Research',
        targetStandard: 'PhD Scholars Cohort',
        hostTeacherName: AuthService.instance.currentUser?.name ?? 'Research Advisor',
        scheduledTime: 'Today, 03:30 PM - 04:30 PM',
        status: 'scheduled',
        roomCode: 'PHD-AI-RESEARCH',
        meetingLink: 'https://eduspark.live/stage/phd-ai-research',
        activeStudentCount: 0,
        totalEnrolledCount: 12,
        isRecording: true,
        isAiAssistantActive: true,
        aiNotesSummary: [],
        doubtsQueue: [],
        connectedStudents: [],
      ),

      // Completed Session
      OnlineClassSession(
        id: 'cls_comp_shapes',
        title: 'Interactive 2D/3D Geometric Shapes & Counting',
        subject: 'Mathematics',
        targetStandard: '1st Standard (Bluebells)',
        hostTeacherName: AuthService.instance.currentUser?.name ?? 'Primary Faculty',
        scheduledTime: 'Completed Today at 10:00 AM',
        status: 'completed',
        roomCode: 'MATHS-1ST-STD',
        meetingLink: 'https://eduspark.live/stage/maths-1st-std',
        activeStudentCount: 0,
        totalEnrolledCount: 24,
        isRecording: true,
        isAiAssistantActive: true,
        aiNotesSummary: [
          'Learned Cube, Sphere, Cylinder and Cone using 3D visual blocks',
          'Counting items: 12 students completed the fruit counter challenge',
          'Homework: Draw 3 circular and 3 rectangular objects from home',
        ],
        doubtsQueue: [],
        connectedStudents: [],
      ),
    ]);
  }

  /// Start a scheduled class or launch an instant class
  void startLiveClass(String sessionId) {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _sessions[idx].status = 'live';
      if (_sessions[idx].activeStudentCount == 0) {
        _sessions[idx].activeStudentCount = 28;
      }
      notifyListeners();
    }
  }

  /// End the live session
  void endLiveClass(String sessionId) {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _sessions[idx].status = 'completed';
      _sessions[idx].activeStudentCount = 0;
      notifyListeners();
    }
  }

  /// Create and schedule a new online class
  OnlineClassSession scheduleNewClass({
    required String title,
    required String subject,
    required String targetStandard,
    required String scheduledTime,
    String platform = 'EduSpark Live Stage',
    String? meetingLink,
    bool startImmediately = false,
  }) {
    final code = '${subject.toUpperCase().replaceAll(' ', '')}-${DateTime.now().millisecond}';
    final newSession = OnlineClassSession(
      id: 'cls_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subject: subject,
      targetStandard: targetStandard,
      hostTeacherName: AuthService.instance.currentUser?.name ?? 'Course Faculty',
      scheduledTime: scheduledTime,
      status: startImmediately ? 'live' : 'scheduled',
      roomCode: code,
      meetingLink: meetingLink ?? 'https://eduspark.live/stage/$code',
      platform: platform,
      activeStudentCount: startImmediately ? 18 : 0,
      totalEnrolledCount: 35,
      isRecording: true,
      isAiAssistantActive: true,
      aiNotesSummary: [
        'Class initiated on EduSpark Virtual Stage',
        'Subject focus: $subject',
        'Target standard: $targetStandard',
      ],
      doubtsQueue: [],
      connectedStudents: [
        {'name': 'Arjun M.', 'status': 'Listening', 'handRaised': false},
        {'name': 'Priya S.', 'status': 'Listening', 'handRaised': false},
      ],
    );

    _sessions.insert(0, newSession);
    notifyListeners();
    return newSession;
  }

  /// Resolve a student doubt with an educator answer
  void resolveDoubt(String sessionId, String doubtId, String answer) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    final doubt = session.doubtsQueue.firstWhere((d) => d.id == doubtId);
    doubt.teacherAnswer = answer;
    doubt.isAnswered = true;
    notifyListeners();
  }

  /// Launch an in-class quick pop quiz/poll
  void launchLivePoll(String sessionId, String question, List<String> options) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.activePoll = LivePollItem(
      id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
      question: question,
      options: options,
      votes: List.filled(options.length, 0),
      isActive: true,
    );
    notifyListeners();
  }

  /// Cast vote on poll
  void voteLivePoll(String sessionId, int optionIndex) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    if (session.activePoll != null && session.activePoll!.isActive) {
      session.activePoll!.votes[optionIndex]++;
      notifyListeners();
    }
  }

  /// Toggle Whiteboard
  void toggleWhiteboard(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.isWhiteboardActive = !session.isWhiteboardActive;
    notifyListeners();
  }

  /// Toggle Screen Share
  void toggleScreenShare(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.isScreenSharing = !session.isScreenSharing;
    notifyListeners();
  }

  /// Toggle Cloud Recording
  void toggleRecording(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.isRecording = !session.isRecording;
    notifyListeners();
  }

  /// Toggle AI Scribe / Co-Teacher
  void toggleAiAssistant(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.isAiAssistantActive = !session.isAiAssistantActive;
    notifyListeners();
  }

  /// Add real-time AI lecture summary note
  void addAiLectureNote(String sessionId, String note) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.aiNotesSummary.add(note);
    notifyListeners();
  }
}
