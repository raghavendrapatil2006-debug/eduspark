# ⚡ EduSpark — Next-Gen AI Academic Ecosystem (KG to PhD)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)](https://dart.dev)
[![AI Engine](https://img.shields.io/badge/Powered%20By-Google%20Gemini%20AI-8E75B2.svg?logo=google)](https://deepmind.google/technologies/gemini/)
[![Tests](https://img.shields.io/badge/Tests-26%20Passing-success.svg)](#running-tests)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**EduSpark** is an AI-native personalized learning and virtual teaching ecosystem crafted for learners and educators across every standard — from Kindergarten and Primary School to Secondary Board Prep, Undergraduate Degrees (B.Tech Engineering, MBBS), and Doctoral / PhD research.

---

## 🌟 Key Features

### 🎓 1. Multi-Standard Adaptive Learning (KG to PhD)
- **Universal Curriculum Coverage**: Tailored learning paths spanning Kindergarten (Pre-KG, LKG, UKG), Primary (1st–5th), High School (9th & 10th Board Exam Prep), Higher Secondary (11th & 12th PCM/PCB, Commerce, Arts), Engineering (CSE, Mechanical, EEE/ECE, Civil, AI & Data Science), Medicine (MBBS), and Doctoral Research.
- **Cognitive Depth Adaptation**: The Gemini AI engine modulates explanation vocabulary, depth, and analogies to match the learner's grade level.

### 🎙️ 2. Gemini AI Tutor & Doubt Solver
- **Multi-Modal Inquiries**: Text typing, real-time voice conversations, and camera snapshot problem solving.
- **Step-by-Step Breakdown**: Generates conceptual summaries, prerequisite reviews, derivation formulas, and potential pitfalls.
- **Custom Notes & Flashcards**: Instant PDF-ready revision sheets and formula sheets generated on the fly.

### 🎥 3. Virtual Classroom & Live Broadcast Stage
- **Broadcast Control HUD**: Real-time timer (`🔴 LIVE`), active participant counter, and cloud recording badge.
- **Digital Interactive Whiteboard**: Pen palette (Cyan, Amber, Emerald, White), stroke eraser, formula notations, and canvas clearing.
- **Engagement Dock**: Live student doubt queue with 1-tap **"Broadcast AI Draft Answer"**, real-time student poll votes with percentage bars, and automated Gemini AI Co-Teacher lecture notes.

### 📊 4. Adaptive Educator Workspace (Teacher Studio)
- **Hierarchical Curriculum Focus**: Category $\rightarrow$ Branch / Class $\rightarrow$ Subject cascading selector.
- **Dynamic Diagnostics**: Today’s schedule, student at-risk diagnostic radar, homework tracker, and grading queues dynamically adapt to the active teaching discipline.
- **AI Teaching Suite**: Automated Question Paper Generator with answer keys and rubrics, pedagogical lesson planners, and mock classroom simulation.

### 💎 5. Subscription & Monetization System
- **Free with Ads (₹0)**: Standard 2D lessons, 5 daily AI questions, and non-intrusive educational sponsored banners.
- **Student Verified Plan (₹99/month)**: **50% Discount** unlocked with valid school/college Student ID verification. Zero ads, unlimited AI doubts, interactive 3D STEM models, and formula lab.
- **EduSpark Pro (₹199/month or ₹1,799/year)**: Full academic suite with live broadcast stage hosting, AI Co-Teacher notes, question paper generator, and multi-device sync.
- **Interactive Checkout**: Simulated UPI (Google Pay, PhonePe, Paytm), Cards, and Net Banking payment gateway.

### 🔐 6. Multi-Role Authentication Suite
- Dual-role sign-in (Students & Teachers).
- Email & password, Phone OTP, Google OAuth, and 1-tap instant guest access mode.
- Local session state and credentials persistence via `SharedPreferences`.

---

## 📂 Architecture & Folder Structure

```
lib/
├── core/
│   ├── constants/           # Color palettes, typography, theme styles
│   ├── routes/              # Declarative GoRouter definitions
│   └── services/            # Singleton state management services
│       ├── auth_service.dart
│       ├── gemini_service.dart
│       ├── online_class_service.dart
│       ├── student_curriculum_service.dart
│       ├── subscription_service.dart
│       ├── teacher_curriculum_service.dart
│       └── user_profile_service.dart
└── features/
    ├── ai_tutor/            # Chat tutor, voice tutor, camera scan
    ├── auth/                # Login, signup, OTP verification, forgot password
    ├── learning/            # Subject topics, 3D STEM simulations
    ├── onboarding/          # 3D intro, role selection, splash
    ├── quizzes/             # Gamified practice quizzes & leaderboards
    ├── student_home/        # Student dashboard, routine, streak, settings
    ├── subscription/        # Plan comparison, ID verification, checkout
    └── teacher/             # Teacher studio, broadcast stage, induction
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.3.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.3.0`)
- Android Studio / Xcode / VS Code

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/eduspark.git
   cd eduspark
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. (Optional) Configure Gemini API Key:
   Set your Google Gemini API key in `lib/core/services/gemini_service.dart` or via environment variables:
   ```dart
   static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY';
   ```

4. Run the app:
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests

EduSpark includes comprehensive unit tests verifying core services and academic logic:

```bash
# Run all unit tests
flutter test

# Run analyzer
dart analyze lib/
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
