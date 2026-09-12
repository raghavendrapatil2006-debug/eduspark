import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/student_curriculum_service.dart';
import '../../../../core/services/teacher_curriculum_service.dart';
import '../../../../core/services/user_profile_service.dart';

class StudentStandardPickerSheet extends StatefulWidget {
  const StudentStandardPickerSheet({super.key});

  @override
  State<StudentStandardPickerSheet> createState() =>
      _StudentStandardPickerSheetState();
}

class _StudentStandardPickerSheetState
    extends State<StudentStandardPickerSheet> {
  late String _selectedCategory;
  late String _selectedStandard;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final cur = StudentCurriculumService.instance;
    _selectedCategory = cur.activeCategory;
    _selectedStandard = cur.activeStandard;
  }

  Map<String, Map<String, List<String>>> get _tree =>
      TeacherCurriculumService.curriculumTree;

  List<String> get _categories => _tree.keys.toList();

  Map<String, List<String>> get _branchesForCategory =>
      _tree[_selectedCategory] ?? {};

  List<String> get _subjectsForSelectedStandard =>
      _branchesForCategory[_selectedStandard] ?? [];

  void _onCategoryChanged(String newCat) {
    setState(() {
      _selectedCategory = newCat;
      final branches = _tree[newCat] ?? {};
      _selectedStandard = branches.keys.isNotEmpty ? branches.keys.first : '';
    });
  }

  void _applySelection() {
    StudentCurriculumService.instance.setActiveStandard(
      category: _selectedCategory,
      standard: _selectedStandard,
    );

    // Sync with UserProfileService
    UserProfileService.instance.updateProfile(standard: _selectedStandard);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Enrolled standard updated: $_selectedStandard',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Sheet Notch
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Your Academic Level',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Kindergarten, High School, B.Tech Degrees & Medical',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 20),

            // Search Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search degrees, standards, branches (e.g. CSE, 10th)...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Horizontal Category Selector Pills
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSelected = cat == _selectedCategory;

                  String shortLabel = cat;
                  if (cat.contains('Engineering')) shortLabel = '⚙️ Engineering Degrees';
                  if (cat.contains('High School')) shortLabel = '🏫 High School (9th-10th)';
                  if (cat.contains('Higher Secondary')) shortLabel = '🔬 Higher Secondary (11th-12th)';
                  if (cat.contains('Primary')) shortLabel = '🎒 Primary (1st-5th)';
                  if (cat.contains('Kindergarten')) shortLabel = '🧸 Kindergarten (Pre-KG)';
                  if (cat.contains('Medical')) shortLabel = '🩺 Medical Sciences';
                  if (cat.contains('Postgraduate')) shortLabel = '🎓 Research & PhD';

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(shortLabel),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) _onCategoryChanged(cat);
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Standards list under active category
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const Text(
                    'Available Classes & Degree Branches',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ..._branchesForCategory.entries
                      .where((entry) =>
                          _searchQuery.isEmpty ||
                          entry.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          entry.value.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase())))
                      .map((entry) {
                    final branch = entry.key;
                    final subjects = entry.value;
                    final isSelected = branch == _selectedStandard;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedStandard = branch),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    branch,
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${subjects.length} Subjects: ${subjects.take(3).join(', ')}...',
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
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 14),

                  // Preview Box of Subjects in Selected Standard
                  if (_subjectsForSelectedStandard.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.checklist_rounded,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Curriculum Preview for $_selectedStandard',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _subjectsForSelectedStandard.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applySelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Set Level: $_selectedStandard',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
