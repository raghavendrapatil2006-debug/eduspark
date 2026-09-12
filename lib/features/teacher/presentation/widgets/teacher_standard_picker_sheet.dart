import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/teacher_curriculum_service.dart';

class TeacherStandardPickerSheet extends StatefulWidget {
  const TeacherStandardPickerSheet({super.key});

  @override
  State<TeacherStandardPickerSheet> createState() =>
      _TeacherStandardPickerSheetState();
}

class _TeacherStandardPickerSheetState
    extends State<TeacherStandardPickerSheet> {
  late String _selectedCategory;
  late String _selectedBranch;
  late String _selectedSubject;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final srv = TeacherCurriculumService.instance;
    _selectedCategory = srv.activeCategory;
    _selectedBranch = srv.activeBranch;
    _selectedSubject = srv.activeSubject;
  }

  Map<String, Map<String, List<String>>> get _tree =>
      TeacherCurriculumService.curriculumTree;

  List<String> get _categories => _tree.keys.toList();

  Map<String, List<String>> get _branchesForCategory =>
      _tree[_selectedCategory] ?? {};

  List<String> get _subjectsForBranch =>
      _branchesForCategory[_selectedBranch] ?? [];

  void _onCategoryChanged(String newCat) {
    setState(() {
      _selectedCategory = newCat;
      final branches = _tree[newCat] ?? {};
      _selectedBranch = branches.keys.isNotEmpty ? branches.keys.first : '';
      final subjects = branches[_selectedBranch] ?? [];
      _selectedSubject = subjects.isNotEmpty ? subjects.first : '';
    });
  }

  void _onBranchChanged(String newBranch) {
    setState(() {
      _selectedBranch = newBranch;
      final subjects = _branchesForCategory[newBranch] ?? [];
      _selectedSubject = subjects.isNotEmpty ? subjects.first : '';
    });
  }

  void _applySelection() {
    TeacherCurriculumService.instance.setActiveTeachingFocus(
      category: _selectedCategory,
      branch: _selectedBranch,
      subject: _selectedSubject,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Teaching focus updated: $_selectedBranch • $_selectedSubject',
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
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Teaching Focus',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Filter your classes, at-risk radar & grading by standard',
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

            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search branch or subject (e.g. CSE, Optics, Maths)...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                    border: InputBorder.none,
                    icon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                children: [
                  // Step 1: Category Selector
                  _sectionHeader('1. Education Level / Stage'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = cat == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => _onCategoryChanged(cat),
                            selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.textSecondary,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Step 2: Branch / Standard Cards
                  _sectionHeader('2. Branch or Standard (${_branchesForCategory.length})'),
                  ..._branchesForCategory.keys.map((branch) {
                    final isSelected = branch == _selectedBranch;

                    if (_searchQuery.isNotEmpty &&
                        !branch.toLowerCase().contains(_searchQuery)) {
                      // Also check if any of its subjects match
                      final subjects = _branchesForCategory[branch] ?? [];
                      final matchSub = subjects.any(
                          (s) => s.toLowerCase().contains(_searchQuery));
                      if (!matchSub) return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => _onBranchChanged(branch),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.background,
                          ),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.school_outlined,
                            size: 18,
                            color: isSelected ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                        title: Text(
                          branch,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          '${_branchesForCategory[branch]?.length ?? 0} Core Subjects available',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Step 3: Teaching Subject
                  _sectionHeader(
                    '3. Specific Teaching Subject (${_subjectsForBranch.length})',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _subjectsForBranch.map((sub) {
                      final isSelected = sub == _selectedSubject;

                      if (_searchQuery.isNotEmpty &&
                          !sub.toLowerCase().contains(_searchQuery) &&
                          !_selectedBranch.toLowerCase().contains(_searchQuery)) {
                        return const SizedBox.shrink();
                      }

                      return ChoiceChip(
                        label: Text(sub),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedSubject = sub),
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 26),

                  // Active Selection Summary Card
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
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Active Workspace Configuration:',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_selectedBranch • $_selectedSubject',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _applySelection,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text(
                        'Apply Teaching Focus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}
