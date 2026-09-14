import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/teacher_student_roster_service.dart';

class TeacherClassRosterSheet extends StatefulWidget {
  final String className;
  final String standardBadge;

  const TeacherClassRosterSheet({
    super.key,
    required this.className,
    required this.standardBadge,
  });

  @override
  State<TeacherClassRosterSheet> createState() => _TeacherClassRosterSheetState();
}

class _TeacherClassRosterSheetState extends State<TeacherClassRosterSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<RosterStudentModel> _students = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    TeacherStudentRosterService.instance.addListener(_onRosterServiceChanged);
  }

  @override
  void dispose() {
    TeacherStudentRosterService.instance.removeListener(_onRosterServiceChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRosterServiceChanged() {
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final list = await TeacherStudentRosterService.instance.getStudentsForClass(
      widget.className,
      standardBadge: widget.standardBadge,
    );
    if (!mounted) return;
    setState(() {
      _students = list;
      _isLoading = false;
    });
  }

  int get _presentCount =>
      _students.where((s) => s.todayStatus == 'present').length;
  int get _lateCount =>
      _students.where((s) => s.todayStatus == 'late').length;
  int get _absentCount =>
      _students.where((s) => s.todayStatus == 'absent').length;

  double get _classAverageAttendance {
    if (_students.isEmpty) return 100.0;
    final total = _students.fold<double>(
      0.0,
      (sum, s) => sum + s.attendancePercentage,
    );
    return total / _students.length;
  }

  Future<void> _markAll(String status) async {
    await TeacherStudentRosterService.instance.markAll(
      className: widget.className,
      status: status,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All ${_students.length} students marked as $status.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updateStudentStatus(RosterStudentModel student, String newStatus) async {
    await TeacherStudentRosterService.instance.updateTodayAttendance(
      className: widget.className,
      studentId: student.id,
      newStatus: newStatus,
    );
  }

  void _openAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final rollCtrl = TextEditingController(text: '#${_students.length + 101}');
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text(
                'Add Student to Class',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Class: ${widget.className} (${widget.standardBadge})',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Student Full Name *',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Enter student full name',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter student name' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Roll Number / Student ID *',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: rollCtrl,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. #109 or CSE-109',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter roll number' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Email or Mobile (Optional)',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailCtrl,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. student@school.edu',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final nav = Navigator.of(dialogCtx);
                final messenger = ScaffoldMessenger.of(context);

                final added = await TeacherStudentRosterService.instance.addStudent(
                  className: widget.className,
                  standardBadge: widget.standardBadge,
                  name: nameCtrl.text.trim(),
                  rollNo: rollCtrl.text.trim(),
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                );

                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added ${added.name} (${added.rollNo}) to roster and stored in database!',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add & Save to Database'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteStudent(RosterStudentModel student) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Student', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Text(
          'Are you sure you want to remove ${student.name} (${student.rollNo}) from this roster database?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(dCtx);
              final messenger = ScaffoldMessenger.of(context);
              await TeacherStudentRosterService.instance.removeStudent(
                className: widget.className,
                studentId: student.id,
              );
              nav.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Removed ${student.name} from class.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _students.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.rollNo.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header with Add Student Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.standardBadge,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.className,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_students.length} Enrolled • Avg: ${_classAverageAttendance.toStringAsFixed(1)}% Attendance',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddStudentDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    icon: const Icon(Icons.person_add_rounded, size: 14),
                    label: const Text(
                      'Add Student',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Attendance Summary Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _summaryPill('Present', '$_presentCount', AppColors.success),
                  const SizedBox(width: 8),
                  _summaryPill('Late', '$_lateCount', AppColors.secondary),
                  const SizedBox(width: 8),
                  _summaryPill('Absent', '$_absentCount', AppColors.danger),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _markAll('present'),
                    icon: const Icon(Icons.done_all_rounded, size: 14, color: AppColors.primary),
                    label: const Text(
                      'Mark All Present',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search student name or roll number...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Student List with Real Attendance Percentages
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.group_off_rounded, size: 40, color: AppColors.textMuted),
                              const SizedBox(height: 8),
                              const Text(
                                'No students found in this roster.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _openAddStudentDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add First Student'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final attPct = s.attendancePercentage;
                            final Color pctColor = attPct >= 85.0
                                ? AppColors.success
                                : (attPct >= 70.0 ? AppColors.secondary : AppColors.danger);

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                    child: Text(
                                      s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                s.name,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Attendance Percentage Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: pctColor.withValues(alpha: 0.14),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: pctColor.withValues(alpha: 0.25),
                                                ),
                                              ),
                                              child: Text(
                                                '${attPct.toStringAsFixed(1)}% Att.',
                                                style: TextStyle(
                                                  color: pctColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${s.rollNo} • Present: ${s.presentDays}/${s.totalSessions} Days',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Toggle Buttons P / L / A
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _attendanceBtn(s, 'present', 'P', AppColors.success),
                                      const SizedBox(width: 4),
                                      _attendanceBtn(s, 'late', 'L', AppColors.secondary),
                                      const SizedBox(width: 4),
                                      _attendanceBtn(s, 'absent', 'A', AppColors.danger),
                                    ],
                                  ),

                                  const SizedBox(width: 4),

                                  // Delete / Remove menu
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 17, color: AppColors.textMuted),
                                    tooltip: 'Remove Student',
                                    onPressed: () => _confirmDeleteStudent(s),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            // Bottom Done / Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Attendance & Roster saved in database for ${widget.className} (Avg: ${_classAverageAttendance.toStringAsFixed(1)}%)!',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: Text(
                    'Save Class Attendance & Roll Call (${_students.length} Students)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceBtn(
    RosterStudentModel student,
    String status,
    String letter,
    Color activeColor,
  ) {
    final isSelected = student.todayStatus == status;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _updateStudentStatus(student, status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
