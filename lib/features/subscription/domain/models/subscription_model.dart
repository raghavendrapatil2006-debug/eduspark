import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum SubscriptionTier {
  free,
  studentVerified,
  premium,
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free with Ads';
      case SubscriptionTier.studentVerified:
        return 'Student Verified Plan';
      case SubscriptionTier.premium:
        return 'EduSpark Pro';
    }
  }

  String get shortName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.studentVerified:
        return 'Student Pro';
      case SubscriptionTier.premium:
        return 'Pro Premium';
    }
  }

  String get badgeLabel {
    switch (this) {
      case SubscriptionTier.free:
        return 'FREE';
      case SubscriptionTier.studentVerified:
        return 'STUDENT PRO • ₹99';
      case SubscriptionTier.premium:
        return 'PRO • ₹199';
    }
  }

  int get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.studentVerified:
        return 99;
      case SubscriptionTier.premium:
        return 199;
    }
  }

  int get annualPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.studentVerified:
        return 999;
      case SubscriptionTier.premium:
        return 1799;
    }
  }

  Color get color {
    switch (this) {
      case SubscriptionTier.free:
        return AppColors.textSecondary;
      case SubscriptionTier.studentVerified:
        return AppColors.secondary;
      case SubscriptionTier.premium:
        return const Color(0xFFF59E0B); // Amber / Gold
    }
  }
}

enum StudentVerificationStatus {
  none,
  pending,
  verified,
  rejected,
}

class StudentIdVerificationData {
  final String institutionName;
  final String studentName;
  final String rollNumber;
  final String? idCardImagePath;
  final DateTime submissionDate;
  final StudentVerificationStatus status;

  const StudentIdVerificationData({
    required this.institutionName,
    required this.studentName,
    required this.rollNumber,
    this.idCardImagePath,
    required this.submissionDate,
    this.status = StudentVerificationStatus.verified,
  });

  Map<String, dynamic> toJson() => {
        'institutionName': institutionName,
        'studentName': studentName,
        'rollNumber': rollNumber,
        'idCardImagePath': idCardImagePath,
        'submissionDate': submissionDate.toIso8601String(),
        'status': status.name,
      };

  factory StudentIdVerificationData.fromJson(Map<String, dynamic> json) {
    return StudentIdVerificationData(
      institutionName: json['institutionName'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      rollNumber: json['rollNumber'] as String? ?? '',
      idCardImagePath: json['idCardImagePath'] as String?,
      submissionDate: json['submissionDate'] != null
          ? DateTime.parse(json['submissionDate'] as String)
          : DateTime.now(),
      status: StudentVerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StudentVerificationStatus.none,
      ),
    );
  }
}

class SubscriptionPlanFeature {
  final String title;
  final bool isIncluded;
  final String? highlight;

  const SubscriptionPlanFeature({
    required this.title,
    this.isIncluded = true,
    this.highlight,
  });
}

class SubscriptionPlan {
  final String id;
  final SubscriptionTier tier;
  final String name;
  final String tagline;
  final int monthlyPrice;
  final int annualPrice;
  final String originalPriceNote;
  final bool isPopular;
  final Color accentColor;
  final List<SubscriptionPlanFeature> features;

  const SubscriptionPlan({
    required this.id,
    required this.tier,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.originalPriceNote,
    this.isPopular = false,
    required this.accentColor,
    required this.features,
  });
}
