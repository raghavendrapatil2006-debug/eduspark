import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RosterStudent {
  final String id;
  final String name;
  final String rollNo;
  final double mastery;
  String attendanceStatus; // 'present', 'late', 'absent'

  RosterStudent({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.mastery,
    this.attendanceStatus = 'present',
  });
}

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

  late List<RosterStudent> _students;

  @override
  void initState() {
    super.initState();
    _students = [
      RosterStudent(id: '1', name: 'Raghavendra K.', rollNo: '#101', mastery: 0.92, attendanceStatus: 'present'),
      RosterStudent(id: '2', name: 'Ananya Verma', rollNo: '#102', mastery: 0.94, attendanceStatus: 'present'),
      RosterStudent(id: '3', name: 'Rohan Sharma', rollNo: '#103', mastery: 0.62, attendanceStatus: 'late'),
      RosterStudent(id: '4', name: 'David Miller', rollNo: '#104', mastery: 0.82, attendanceStatus: 'present'),
      RosterStudent(id: '5', name: 'Priya Patel', rollNo: '#105', mastery: 0.91, attendanceStatus: 'present'),
      RosterStudent(id: '6', name: 'Kavya Nair', rollNo: '#106', mastery: 0.76, attendanceStatus: 'absent'),
      RosterStudent(id: '7', name: 'Marcus Chen', rollNo: '#107', mastery: 0.85, attendanceStatus: 'present'),
      RosterStudent(id: '8', name: 'Sneha Reddy', rollNo: '#108', mastery: 0.96, attendanceStatus: 'present'),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _presentCount =>
      _students.where((s) => s.attendanceStatus == 'present').length;
  int get _lateCount =>
      _students.where((s) => s.attendanceStatus == 'late').length;
  int get _absentCount =>
      _students.where((s) => s.attendanceStatus == 'absent').length;

  void _markAll(String status) {
    setState(() {
      for (final s in _students) {
        s.attendanceStatus = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _students.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.rollNo.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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

            // Header
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
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${_students.length} Enrolled Students • Roll Call',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
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
                  TextButton(
                    onPressed: () => _markAll('present'),
                    child: const Text(
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
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Search student name or roll number...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final s = filtered[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            s.name.isNotEmpty ? s.name[0] : 'S',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    s.rollNo,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(s.mastery * 100).toInt()}% Mastery',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Attendance saved for ${widget.className}! ($_presentCount Present, $_absentCount Absent)',
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text(
                    'Submit Attendance & Save',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryPill(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _attendanceBtn(
    RosterStudent student,
    String status,
    String label,
    Color activeColor,
  ) {
    final isSelected = student.attendanceStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          student.attendanceStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
