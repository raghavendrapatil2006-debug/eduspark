import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/online_class_service.dart';

class LiveClassroomStageScreen extends StatefulWidget {
  final OnlineClassSession session;

  const LiveClassroomStageScreen({super.key, required this.session});

  @override
  State<LiveClassroomStageScreen> createState() =>
      _LiveClassroomStageScreenState();
}

class _LiveClassroomStageScreenState extends State<LiveClassroomStageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OnlineClassSession _session;

  // Educator hardware toggles
  bool _isMicMuted = false;
  bool _isVideoOff = false;
  bool _isWhiteboardMode = false;
  bool _isRecording = true;

  // Whiteboard drawing points
  final List<List<Offset?>> _whiteboardStrokes = [];
  Color _selectedPenColor = AppColors.primary;
  final double _penStrokeWidth = 3.0;

  // Session duration timer
  int _elapsedSeconds = 1458; // 24m 18s initial
  Timer? _classTimer;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _isWhiteboardMode = _session.isWhiteboardActive;
    _isRecording = _session.isRecording;
    _tabController = TabController(length: 4, vsync: this);

    _classTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });

    // Populate initial whiteboard optics sketch if empty
    _initSampleWhiteboardDrawing();
  }

  @override
  void dispose() {
    _classTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _initSampleWhiteboardDrawing() {
    // Initial educational sketch points for Snell's law illustration
    _whiteboardStrokes.add([
      const Offset(60, 80),
      const Offset(300, 80),
    ]); // Normal line
    _whiteboardStrokes.add([
      const Offset(180, 20),
      const Offset(180, 140),
    ]); // Interface
    _whiteboardStrokes.add([
      const Offset(80, 30),
      const Offset(180, 80),
    ]); // Incident ray
    _whiteboardStrokes.add([
      const Offset(180, 80),
      const Offset(260, 130),
    ]); // Refracted ray
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _confirmEndClass() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.call_end_rounded, color: AppColors.danger),
            SizedBox(width: 10),
            Text(
              'End Live Class?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will conclude the live broadcast for all 34 connected students. The AI lecture notes and attendance ledger will be saved automatically.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Keep Teaching'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              OnlineClassService.instance.endLiveClass(_session.id);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Class ended successfully! AI Lecture Notes published to students.',
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Class for All'),
          ),
        ],
      ),
    );
  }

  void _openLaunchPollDialog() {
    final questionCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController(text: 'Option A');
    final opt2Ctrl = TextEditingController(text: 'Option B');
    final opt3Ctrl = TextEditingController(text: 'Option C');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.quiz_rounded, color: AppColors.secondary),
            SizedBox(width: 10),
            Text(
              'Launch In-Class Pop Quiz',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionCtrl,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Question for Students',
                  hintText: 'e.g. What happens to wavelength in water?',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: opt1Ctrl,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Option 1'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: opt2Ctrl,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Option 2'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: opt3Ctrl,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Option 3'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final q = questionCtrl.text.trim();
              if (q.isNotEmpty) {
                OnlineClassService.instance.launchLivePoll(
                  _session.id,
                  q,
                  [
                    opt1Ctrl.text.trim(),
                    opt2Ctrl.text.trim(),
                    opt3Ctrl.text.trim(),
                  ],
                );
                Navigator.of(dialogCtx).pop();
                _tabController.animateTo(1); // Switch to Poll tab
              }
            },
            child: const Text('Broadcast Poll'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // 1. TOP BROADCAST HUD
            // ============================================================
            _buildTopBroadcastHUD(),

            // ============================================================
            // 2. MAIN STAGE / DIGITAL WHITEBOARD CANVAS
            // ============================================================
            Expanded(
              flex: 5,
              child: _isWhiteboardMode
                  ? _buildWhiteboardStage()
                  : _buildPresentationStage(),
            ),

            // ============================================================
            // 3. EDUCATOR HARDWARE CONTROL DOCK
            // ============================================================
            _buildHardwareControlDock(),

            // ============================================================
            // 4. INTERACTIVE ENGAGEMENT DOCK (DOUBTS, POLLS, AI NOTES)
            // ============================================================
            Expanded(
              flex: 4,
              child: _buildEngagementDock(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BROADCAST HUD
  // ============================================================
  Widget _buildTopBroadcastHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Live Pulse Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE ${_formatTimer(_elapsedSeconds)}',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Title & Standard
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _session.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_session.targetStandard} • ${_session.subject}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Active Learners Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  '${_session.activeStudentCount}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // End Class Button
          IconButton(
            onPressed: _confirmEndClass,
            icon: const Icon(Icons.call_end_rounded, color: AppColors.danger),
            tooltip: 'End Class',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRESENTATION / VIDEO STAGE
  // ============================================================
  Widget _buildPresentationStage() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Simulated Video / Slide Canvas
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'PR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Prof. Raghavendra (You)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic_rounded, size: 14, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'Presenting: Snell’s Law & Refraction of Light',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Right: Gemini AI Co-Teacher Indicator
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: Color(0xFF818CF8),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'AI Co-Teacher Listening',
                    style: TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Left: Active Recording Pill
          if (_isRecording)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record, size: 10, color: Colors.red),
                    SizedBox(width: 5),
                    Text(
                      'REC Cloud HD',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DIGITAL WHITEBOARD STAGE
  // ============================================================
  Widget _buildWhiteboardStage() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          // Whiteboard Drawing Canvas
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _whiteboardStrokes.add([details.localPosition]);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _whiteboardStrokes.last.add(details.localPosition);
              });
            },
            child: CustomPaint(
              painter: _WhiteboardPainter(
                strokes: _whiteboardStrokes,
                color: _selectedPenColor,
                strokeWidth: _penStrokeWidth,
              ),
              size: Size.infinite,
            ),
          ),

          // Whiteboard Watermark / Formula Tag
          Positioned(
            top: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Interactive Whiteboard: n₁ · sin(θ₁) = n₂ · sin(θ₂)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Whiteboard Palette Controls
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorDot(AppColors.primary),
                  _colorDot(Colors.white),
                  _colorDot(AppColors.secondary),
                  _colorDot(AppColors.success),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(
                      Icons.cleaning_services_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _whiteboardStrokes.clear());
                    },
                    tooltip: 'Clear Board',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    final isSelected = _selectedPenColor == color;

    return GestureDetector(
      onTap: () => setState(() => _selectedPenColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EDUCATOR HARDWARE CONTROL DOCK
  // ============================================================
  Widget _buildHardwareControlDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Mic Toggle
          _dockButton(
            icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: _isMicMuted ? 'Muted' : 'Mic On',
            isActive: !_isMicMuted,
            color: _isMicMuted ? AppColors.danger : AppColors.success,
            onTap: () => setState(() => _isMicMuted = !_isMicMuted),
          ),

          // Video Toggle
          _dockButton(
            icon: _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
            label: _isVideoOff ? 'Cam Off' : 'Cam On',
            isActive: !_isVideoOff,
            color: _isVideoOff ? AppColors.danger : AppColors.primary,
            onTap: () => setState(() => _isVideoOff = !_isVideoOff),
          ),

          // Digital Whiteboard Toggle
          _dockButton(
            icon: Icons.draw_rounded,
            label: 'Whiteboard',
            isActive: _isWhiteboardMode,
            color: AppColors.primary,
            onTap: () => setState(() => _isWhiteboardMode = !_isWhiteboardMode),
          ),

          // Launch Poll / Pop Quiz
          _dockButton(
            icon: Icons.poll_rounded,
            label: 'Pop Quiz',
            isActive: false,
            color: AppColors.secondary,
            onTap: _openLaunchPollDialog,
          ),

          // Screen Share
          _dockButton(
            icon: Icons.screen_share_rounded,
            label: 'Share',
            isActive: _session.isScreenSharing,
            color: const Color(0xFF818CF8),
            onTap: () {
              OnlineClassService.instance.toggleScreenShare(_session.id);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _dockButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.18)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? color : AppColors.border,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? color : AppColors.textMuted,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INTERACTIVE ENGAGEMENT DOCK
  // ============================================================
  Widget _buildEngagementDock() {
    return Column(
      children: [
        // Tab Bar
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Doubts (${_session.doubtsQueue.length})'),
            const Tab(text: 'Live Poll'),
            const Tab(text: 'AI Notes'),
            Tab(text: 'Roster (${_session.activeStudentCount})'),
          ],
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDoubtsTab(),
              _buildPollTab(),
              _buildAiNotesTab(),
              _buildRosterTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TAB 1: STUDENT DOUBTS QUEUE
  // ------------------------------------------------------------
  Widget _buildDoubtsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _session.doubtsQueue.length,
      itemBuilder: (context, idx) {
        final doubt = _session.doubtsQueue[idx];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: doubt.isAnswered
                  ? AppColors.border
                  : AppColors.secondary.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                    child: Text(
                      doubt.studentName.isNotEmpty ? doubt.studentName[0] : 'S',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    doubt.studentName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    doubt.timeAgo,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (doubt.isAnswered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Answered ✓',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                doubt.doubtText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              // AI Suggested Answer if available
              if (!doubt.isAnswered && doubt.aiSuggestedAnswer != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF818CF8).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: Color(0xFF818CF8),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'AI Co-Teacher Draft Answer:',
                            style: TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doubt.aiSuggestedAnswer!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          doubt.isAnswered = true;
                          doubt.teacherAnswer = doubt.aiSuggestedAnswer;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Answer broadcasted to student!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 14),
                      label: const Text(
                        'Broadcast AI Answer',
                        style: TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // TAB 2: IN-CLASS LIVE POLL / POP QUIZ
  // ------------------------------------------------------------
  Widget _buildPollTab() {
    final poll = _session.activePoll;

    if (poll == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.poll_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            const Text(
              'No Active Pop Quiz',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openLaunchPollDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Launch Pop Quiz'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'POP QUIZ • LIVE VOTING',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${poll.totalVotes} responses',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            poll.question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),

          // Options with live percentage bars
          ...List.generate(poll.options.length, (idx) {
            final opt = poll.options[idx];
            final pct = poll.getPercentage(idx);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TAB 3: AI LECTURE NOTES SUMMARY
  // ------------------------------------------------------------
  Widget _buildAiNotesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: const [
            Icon(Icons.auto_awesome, size: 16, color: Color(0xFF818CF8)),
            SizedBox(width: 6),
            Text(
              'Gemini AI Live Lecture Notes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._session.aiNotesSummary.map((note) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ------------------------------------------------------------
  // TAB 4: CONNECTED STUDENTS ROSTER
  // ------------------------------------------------------------
  Widget _buildRosterTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _session.connectedStudents.length,
      itemBuilder: (context, idx) {
        final st = _session.connectedStudents[idx];
        final bool handRaised = st['handRaised'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: handRaised
                  ? AppColors.secondary.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  st['name'].isNotEmpty ? st['name'][0] : 'S',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  st['name'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (handRaised)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('✋', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text(
                        'Hand Raised',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  'Connected',
                  style: TextStyle(color: AppColors.success, fontSize: 11),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// DIGITAL WHITEBOARD CUSTOM PAINTER
// ============================================================
class _WhiteboardPainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final Color color;
  final double strokeWidth;

  _WhiteboardPainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (stroke[i] != null && stroke[i + 1] != null) {
          canvas.drawLine(stroke[i]!, stroke[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) => true;
}
