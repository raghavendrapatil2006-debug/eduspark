import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/online_class_service.dart';

class ScheduleOnlineClassSheet extends StatefulWidget {
  const ScheduleOnlineClassSheet({super.key});

  @override
  State<ScheduleOnlineClassSheet> createState() =>
      _ScheduleOnlineClassSheetState();
}

class _ScheduleOnlineClassSheetState extends State<ScheduleOnlineClassSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(
    text: 'Organic Chemistry: Hydrocarbons & Reaction Mechanisms',
  );
  final _subjectController = TextEditingController(text: 'Chemistry');
  final _customLinkController = TextEditingController();

  String _selectedClass = 'Class 10-A';
  String _selectedTime = 'Today, 04:00 PM - 05:00 PM';
  String _selectedPlatform = 'EduSpark Live Stage';
  bool _enableAiScribe = true;
  bool _enableRecording = true;

  final List<String> _classes = [
    'Class 10-A (Science)',
    '1st Standard (Bluebells)',
    'B.Tech CSE (Sem 3)',
    'PhD Scholar Colloquium',
    'Class 12-B (PCM)',
  ];

  final List<String> _times = [
    'Right Now (Instant Live Room)',
    'Today, 02:00 PM - 03:00 PM',
    'Today, 04:00 PM - 05:00 PM',
    'Tomorrow, 09:30 AM - 10:30 AM',
    'Tomorrow, 11:00 AM - 12:00 PM',
  ];

  final List<String> _platforms = [
    'EduSpark Live Stage',
    'Google Meet',
    'Zoom Meeting',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _customLinkController.dispose();
    super.dispose();
  }

  void _submit({required bool startNow}) {
    if (!_formKey.currentState!.validate()) return;

    final session = OnlineClassService.instance.scheduleNewClass(
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      targetStandard: _selectedClass,
      scheduledTime: startNow ? 'Live Right Now' : _selectedTime,
      platform: _selectedPlatform,
      meetingLink: _customLinkController.text.isNotEmpty
          ? _customLinkController.text.trim()
          : null,
      startImmediately: startNow,
    );

    Navigator.pop(context);

    if (startNow) {
      context.push('/teacher/live-class', extra: session);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Online Class "${session.title}" scheduled! Invite code: ${session.roomCode}',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.video_call_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Schedule Online Class',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Lecture Title
                _label('Class / Lecture Topic'),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                  ),
                  decoration: _inputDecoration('e.g. Wave Optics & Ray Diagrams'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter a class topic'
                      : null,
                ),

                const SizedBox(height: 16),

                // Subject & Target Class Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Subject'),
                          TextFormField(
                            controller: _subjectController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                            ),
                            decoration: _inputDecoration('e.g. Physics'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Target Batch'),
                          _dropdown(
                            value: _selectedClass,
                            items: _classes,
                            onChanged: (v) => setState(() => _selectedClass = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Time Slot
                _label('Scheduled Session Time'),
                _dropdown(
                  value: _selectedTime,
                  items: _times,
                  onChanged: (v) => setState(() => _selectedTime = v!),
                ),

                const SizedBox(height: 16),

                // Platform Selector
                _label('Virtual Classroom Engine'),
                _dropdown(
                  value: _selectedPlatform,
                  items: _platforms,
                  onChanged: (v) => setState(() => _selectedPlatform = v!),
                ),

                if (_selectedPlatform != 'EduSpark Live Stage') ...[
                  const SizedBox(height: 12),
                  _label('Meeting Link (Google Meet / Zoom URL)'),
                  TextFormField(
                    controller: _customLinkController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: _inputDecoration('https://meet.google.com/xxx-xxxx-xxx'),
                  ),
                ],

                const SizedBox(height: 16),

                // Toggles
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF818CF8),
                        ),
                        title: const Text(
                          'AI Co-Teacher Live Notes',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: const Text(
                          'Gemini transcribes key formulas & bullet takeaways',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        value: _enableAiScribe,
                        onChanged: (v) => setState(() => _enableAiScribe = v),
                      ),
                      const Divider(color: AppColors.border, height: 1),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Auto Cloud HD Recording',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: const Text(
                          'Provide video replay for absent students',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        value: _enableRecording,
                        onChanged: (v) => setState(() => _enableRecording = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _submit(startNow: false),
                        icon: const Icon(Icons.event_rounded, size: 16),
                        label: const Text(
                          'Schedule Class',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _submit(startNow: true),
                        icon: const Icon(Icons.videocam_rounded, size: 18),
                        label: const Text(
                          'Start Live Now',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
