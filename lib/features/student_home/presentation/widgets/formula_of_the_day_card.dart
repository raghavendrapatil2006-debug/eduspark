import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/student_curriculum_service.dart';

class FormulaOfTheDayCard extends StatefulWidget {
  final StudentConceptOfDay? concept;

  const FormulaOfTheDayCard({super.key, this.concept});

  @override
  State<FormulaOfTheDayCard> createState() => _FormulaOfTheDayCardState();
}

class _FormulaOfTheDayCardState extends State<FormulaOfTheDayCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final concept =
        widget.concept ?? StudentCurriculumService.instance.getAdaptiveConceptOfDay();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1B4B).withValues(alpha: 0.85),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF818CF8).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF818CF8).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: Color(0xFF818CF8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            concept.tag,
                            style: const TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        concept.subjectSubtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  concept.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                // Formula Highlight Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF818CF8).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      concept.formulaEquation,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  concept.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),

                if (_isExpanded) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Key Breakdown & Variables:',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...concept.variableBreakdown.map(
                          (v) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              '• $v',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '💡 ${concept.realWorldExample}',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom Action Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? 'Show Less' : 'Deep Explanation',
                        style: const TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF818CF8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/ai-tutor/type');
                  },
                  icon: const Icon(Icons.psychology_rounded, size: 16),
                  label: const Text(
                    'Practice with AI',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF818CF8),
                    side: const BorderSide(color: Color(0xFF818CF8)),
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
