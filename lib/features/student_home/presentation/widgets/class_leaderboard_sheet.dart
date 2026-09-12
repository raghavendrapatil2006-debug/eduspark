import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_profile_service.dart';

class ClassLeaderboardSheet extends StatelessWidget {
  const ClassLeaderboardSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final studentName = UserProfileService.instance.studentName;
    final learners = [
      _LearnerRank(1, 'Priya S.', '1,450 XP', '🔥 9 days', 'CSE Sec-A', false),
      _LearnerRank(2, '$studentName (You)', '1,240 XP', '🔥 7 days', 'CSE Sec-A', true),
      _LearnerRank(3, 'Rohan M.', '1,180 XP', '🔥 6 days', 'CSE Sec-B', false),
      _LearnerRank(4, 'Ananya K.', '1,050 XP', '🔥 5 days', 'CSE Sec-A', false),
      _LearnerRank(5, 'Kabir T.', '980 XP', '🔥 4 days', 'CSE Sec-C', false),
      _LearnerRank(6, 'Sneha R.', '920 XP', '🔥 5 days', 'CSE Sec-B', false),
      _LearnerRank(7, 'Dev P.', '870 XP', '🔥 3 days', 'CSE Sec-A', false),
      _LearnerRank(8, 'Isha G.', '810 XP', '🔥 3 days', 'CSE Sec-C', false),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Class Leaderboard',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC084FC).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🥈 Silver League',
                      style: TextStyle(
                        color: Color(0xFFC084FC),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
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
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  // Top 3 Podium
                  _buildPodium(),

                  const SizedBox(height: 20),

                  // Promotion zone banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_circle_up_rounded,
                          color: AppColors.success,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You are in the Gold Promotion Zone!',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Season ends in 2 days • Top 10 advance to Gold',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Full Class Standings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ...learners.map((l) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: l.isCurrentUser
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: l.isCurrentUser
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: l.rank <= 3
                                    ? AppColors.secondary.withValues(alpha: 0.15)
                                    : AppColors.surfaceLight,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${l.rank}',
                                style: TextStyle(
                                  color: l.rank <= 3
                                      ? AppColors.secondary
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: l.isCurrentUser
                                          ? FontWeight.w800
                                          : FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${l.classroom} • ${l.streak}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              l.xp,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final studentName = UserProfileService.instance.studentName;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Current User)
          _podiumColumn(
            rank: '2nd 🥈',
            name: '$studentName (You)',
            xp: '1,240 XP',
            height: 90,
            avatarBg: AppColors.primary,
            isCurrentUser: true,
          ),
          // 1st Place (Priya)
          _podiumColumn(
            rank: '1st 👑',
            name: 'Priya S.',
            xp: '1,450 XP',
            height: 115,
            avatarBg: AppColors.secondary,
            isCurrentUser: false,
          ),
          // 3rd Place (Rohan)
          _podiumColumn(
            rank: '3rd 🥉',
            name: 'Rohan M.',
            xp: '1,180 XP',
            height: 75,
            avatarBg: const Color(0xFFC084FC),
            isCurrentUser: false,
          ),
        ],
      ),
    );
  }

  Widget _podiumColumn({
    required String rank,
    required String name,
    required String xp,
    required double height,
    required Color avatarBg,
    required bool isCurrentUser,
  }) {
    return Column(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: avatarBg.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: avatarBg, width: 2),
          ),
          child: Center(
            child: Text(
              name[0],
              style: TextStyle(
                color: avatarBg,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          xp,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 75,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                avatarBg.withValues(alpha: 0.35),
                AppColors.surfaceLight,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LearnerRank {
  final int rank;
  final String name;
  final String xp;
  final String streak;
  final String classroom;
  final bool isCurrentUser;

  const _LearnerRank(
    this.rank,
    this.name,
    this.xp,
    this.streak,
    this.classroom,
    this.isCurrentUser,
  );
}
