import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'user_profile_service.dart';

class GeminiQuizQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const GeminiQuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  factory GeminiQuizQuestion.fromJson(Map<String, dynamic> json) {
    final question = json['question'] as String?;
    final options = (json['options'] as List?)?.cast<String>();
    final answerIndex = json['answerIndex'] as int?;
    final explanation = json['explanation'] as String?;

    if (question == null || question.isEmpty) {
      throw FormatException('Quiz question missing "question" field: $json');
    }

    if (options == null || options.length != 4) {
      throw FormatException(
        'Quiz question needs exactly 4 options, got ${options?.length}: $json',
      );
    }

    if (answerIndex == null || answerIndex < 0 || answerIndex > 3) {
      throw FormatException(
        'Quiz question has invalid answerIndex $answerIndex: $json',
      );
    }

    if (explanation == null || explanation.isEmpty) {
      throw FormatException('Quiz question missing "explanation" field: $json');
    }

    return GeminiQuizQuestion(
      question: question,
      options: options,
      answerIndex: answerIndex,
      explanation: explanation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answerIndex': answerIndex,
      'explanation': explanation,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GeminiQuizQuestion) return false;
    if (question != other.question) return false;
    if (answerIndex != other.answerIndex) return false;
    if (explanation != other.explanation) return false;
    if (options.length != other.options.length) return false;

    for (var i = 0; i < options.length; i++) {
      if (options[i] != other.options[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode =>
      Object.hash(question, Object.hashAll(options), answerIndex, explanation);

  @override
  String toString() =>
      'GeminiQuizQuestion(question: $question, options: $options, answerIndex: $answerIndex, explanation: $explanation)';
}

class GeminiService {
  GeminiService._();

  static final GeminiService instance = GeminiService._();

  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.6-flash',
  );

  // ============================================================
  // STANDARD ADAPTIVE PEDAGOGICAL PROMPT BUILDER
  // Adapts depth, tone, complexity and vocabulary from KG to PhD
  // ============================================================

  static String _getStandardInstruction(String? standard) {
    final std = (standard != null && standard.trim().isNotEmpty)
        ? standard.trim()
        : UserProfileService.instance.standard;
    final lower = std.toLowerCase();

    // Kindergarten / Nursery / Early Childhood
    if (lower.contains('kg') ||
        lower.contains('nursery') ||
        lower.contains('early') ||
        lower.contains('kindergarten')) {
      return '''
TARGET AUDIENCE: Kindergarten / Early Childhood student (Age 3-5, Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Use extremely simple, gentle, playful words.
- Keep sentences short (max 5-8 words per sentence).
- Use lots of friendly emojis (🌟, 🐶, 🍎, 🎈, 🧸, 🚀).
- Relate everything to fun toys, colors, animals, games, or family.
- Avoid all technical jargon, formulas, or abstract definitions.
- Keep explanations very brief (2-3 short, cheerful sentences).
''';
    }

    // Primary School (1st to 2nd Standard)
    if (lower.contains('1st') || lower.contains('2nd')) {
      return '''
TARGET AUDIENCE: Primary School student in Grades 1-2 (Age 6-7, Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Explain like a kind, supportive story-teller.
- Simple, basic vocabulary only.
- Very short paragraphs.
- Use fun, relatable real-world analogies (chocolates, toys, playing in the park, pet animals).
- If numbers or math are involved, use counting objects (e.g., 3 apples + 2 apples).
- Zero complex jargon; define any new simple word warmly.
''';
    }

    // Primary School (3rd to 5th Standard)
    if (lower.contains('3rd') || lower.contains('4th') || lower.contains('5th')) {
      return '''
TARGET AUDIENCE: Upper Primary School student in Grades 3-5 (Age 8-10, Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Explain concepts clearly with structured, engaging explanations.
- Introduce foundational scientific and mathematical terms with simple definitions.
- Use clear everyday examples (bicycles, cooking in the kitchen, weather, playground games).
- Keep sentences accessible and paragraphs concise (2-4 sentences).
- Break multi-step problems down into numbered steps (Step 1, Step 2, Step 3).
''';
    }

    // Middle School (6th to 8th Standard)
    if (lower.contains('6th') || lower.contains('7th') || lower.contains('8th')) {
      return '''
TARGET AUDIENCE: Middle School student in Grades 6-8 (Age 11-13, Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Balance intuitive conceptual clarity with core curriculum terminology.
- Provide step-by-step problem-solving methods with clear logical flow.
- Explain "why" behind phenomena and formulas, not just "what".
- Use relatable real-world applications (sports, smartphones, natural phenomena).
''';
    }

    // High School (9th & 10th Standard)
    if (lower.contains('9th') || lower.contains('10th')) {
      return '''
TARGET AUDIENCE: High School student in Grades 9-10 (Board Exam preparation level, Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Deliver rigorous conceptual explanations adhering to standard school/board curricula.
- Include precise scientific definitions, units of measurement, and standard formulas.
- Provide structured point-by-point breakdowns, cause-and-effect reasoning, and exam-oriented problem-solving steps.
- Highlight common exam mistakes and key takeaway points.
''';
    }

    // Higher Secondary (11th & 12th Standard)
    if (lower.contains('11th') || lower.contains('12th')) {
      return '''
TARGET AUDIENCE: Senior Secondary student in Grades 11-12 (Pre-University / Board & Entrance Exam level, Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Deep analytical rigor appropriate for Class 11-12 curriculum.
- In-depth theoretical principles, rigorous mathematical derivations, chemical mechanisms, or economic/accounting principles.
- Use precise formal terminology, notation, and diagram/graph descriptions where applicable.
- Bridge foundational theory with competitive entrance concepts (e.g. JEE, NEET, CUET).
''';
    }

    // Undergraduate / Bachelor Degrees
    if (lower.contains('b.tech') ||
        lower.contains('b.e.') ||
        lower.contains('b.sc') ||
        lower.contains('b.com') ||
        lower.contains('bba') ||
        lower.contains('bca') ||
        lower.contains('mbbs') ||
        lower.contains('b.pharm') ||
        lower.contains('b.arch') ||
        lower.contains('llb') ||
        lower.contains('bachelor') ||
        lower.contains('undergraduate')) {
      return '''
TARGET AUDIENCE: Undergraduate College / University Degree student (Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Provide high-level academic, university-grade depth and professional domain context.
- Include formal technical terminology, mathematical proofs/derivations, algorithmic complexity, architectural paradigms, or clinical/legal frameworks where applicable.
- Discuss practical industry applications, edge cases, standard design patterns, and engineering/business trade-offs.
- Avoid oversimplification; treat the student as a serious university student in their respective field.
''';
    }

    // Postgraduate / Master Degrees
    if (lower.contains('m.tech') ||
        lower.contains('m.e.') ||
        lower.contains('m.sc') ||
        lower.contains('mba') ||
        lower.contains('mca') ||
        lower.contains('m.com') ||
        lower.contains('md') ||
        lower.contains('ms') ||
        lower.contains('llm') ||
        lower.contains('master') ||
        lower.contains('postgraduate')) {
      return '''
TARGET AUDIENCE: Master's / Postgraduate Degree student (Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Advanced theoretical and applied mastery.
- Deep architectural, analytical, and critical analysis.
- Discuss state-of-the-art methodology, performance benchmarks, optimization techniques, research literature perspectives, and strategic implementations.
- Maintain a scholarly and professional peer-level tone.
''';
    }

    // Doctorate / PhD / Research
    if (lower.contains('phd') ||
        lower.contains('doctorate') ||
        lower.contains('post-doctoral') ||
        lower.contains('research')) {
      return '''
TARGET AUDIENCE: PhD Scholar / Advanced Academic Researcher (Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Rigorous academic scholarship at the frontier of research.
- Emphasize foundational theory, mathematical proofs, empirical methodologies, research frontiers, open problems, and cross-domain synthesis.
- Precise academic citations or conceptual attributions where relevant.
- Treat the student as an expert colleague and researcher.
''';
    }

    // Competitive Exams
    if (lower.contains('jee') ||
        lower.contains('neet') ||
        lower.contains('upsc') ||
        lower.contains('gate') ||
        lower.contains('cat') ||
        lower.contains('ca') ||
        lower.contains('aspirant')) {
      return '''
TARGET AUDIENCE: Competitive Examination Aspirant (Level: $std).
PEDAGOGICAL INSTRUCTIONS:
- Focus on high-yield exam concepts, analytical speed, shortcut techniques, and rigorous problem-solving accuracy.
- Highlight tricky edge cases, trap options, elimination strategies, and standard exam patterns.
- Clear step-by-step solutions with time-saving tips and core formula sheets.
''';
    }

    // Fallback: Use standard as declared
    return '''
TARGET AUDIENCE: Student studying at level: $std.
PEDAGOGICAL INSTRUCTIONS:
- Tailor vocabulary, technical depth, and complexity precisely to this student's level ($std).
- Provide clear, accurate, and conceptually solid explanations suitable for this standard.
''';
  }

  // ============================================================
  // ASK QUESTION
  // ============================================================

  Future<String> askQuestion({
    required String question,
    String? standard,
    String language = 'English',
  }) async {
    final standardInstruction = _getStandardInstruction(standard);
    final prompt =
        '''
You are EduSpark, an intelligent AI tutor and learning mentor.

$standardInstruction

Answer the student's question clearly, accurately, and tailored to their education level.

Language: $language

IMPORTANT RULES:
- Adhere strictly to the target audience level and pedagogical instructions above.
- If the question is unclear, explain what is unclear politely.
- Do not include greetings.
- Do not use Markdown headings using #.
- Give a useful, insightful explanation, not just a one-word answer.
- Include a relevant example or application when it helps understanding.

Return ONLY the answer.
''';

    final content = [Content.text('$prompt\n\nStudent question:\n$question')];

    try {
      final response = await _model.generateContent(content);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return 'Sorry, I could not understand the question.';
      }

      return text;
    } catch (e) {
      throw Exception('Failed to answer question: $e');
    }
  }

  // ============================================================
  // AI FOLLOW-UP CHAT
  // ============================================================

  Future<String> askFollowUpQuestion({
    required String originalQuestion,
    required String previousAnswer,
    required String followUpQuestion,
    String? standard,
    String language = 'English',
  }) async {
    final standardInstruction = _getStandardInstruction(standard);
    final prompt =
        '''
You are EduSpark, an intelligent AI tutor and learning mentor.

$standardInstruction

The student previously asked a question and received an answer.

Original question:
$originalQuestion

Previous EduSpark answer:
$previousAnswer

Now the student has a follow-up question:
$followUpQuestion

Language: $language

IMPORTANT RULES:
- Continue the conversation naturally.
- Use the previous answer as context.
- Do not repeat the entire previous answer unless necessary.
- If the student says they do not understand something, explain it differently.
- Adhere strictly to the target audience level and pedagogical instructions above.
- Give examples when useful.
- If the student asks "why", explain the reasoning.
- If the student asks for steps, provide clear steps.
- Do not include greetings.
- Do not use Markdown headings using #.

Return ONLY the answer.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return 'Sorry, I could not answer the follow-up question.';
      }

      return text;
    } catch (e) {
      throw Exception('Failed to answer follow-up question: $e');
    }
  }

  // ============================================================
  // GENERAL CHAT WITH CONVERSATION HISTORY
  // ============================================================
  //
  // This allows the future Gemini-style chat screen to maintain
  // multiple messages instead of only one question and answer.
  // ============================================================

  Future<String> chat({
    required List<Map<String, String>> messages,
    String? standard,
    String language = 'English',
  }) async {
    final conversation = StringBuffer();

    for (final message in messages) {
      final role = message['role'] ?? 'user';
      final text = message['text'] ?? '';

      conversation.writeln(
        '${role == 'assistant' ? 'EduSpark' : 'Student'}: $text',
      );
    }

    final standardInstruction = _getStandardInstruction(standard);
    final prompt =
        '''
You are EduSpark, an intelligent AI tutor and learning mentor.

$standardInstruction

Continue the following educational conversation.

Language: $language

Conversation:
$conversation

IMPORTANT RULES:
- Answer the student's latest message.
- Remember the previous conversation.
- Be clear and educational.
- Adhere strictly to the target audience level and pedagogical instructions above.
- If the student asks a follow-up, use the previous messages as context.
- If appropriate, give examples or step-by-step explanations.
- Do not include greetings unless the student explicitly asks for one.
- Do not use Markdown headings using #.
- Do not pretend to know information that is not available.

Return ONLY the response to the student's latest message.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return 'Sorry, I could not generate a response.';
      }

      return text;
    } catch (e) {
      throw Exception('Failed to continue AI conversation: $e');
    }
  }

  // ============================================================
  // TEXTBOOK IMAGE ANALYSIS
  // ============================================================

  Future<String> analyzeTextbookImage({
    required Uint8List imageBytes,
    required String mimeType,
    String? standard,
    String language = 'English',
  }) async {
    final standardInstruction = _getStandardInstruction(standard);
    final prompt =
        '''
You are EduSpark, an intelligent AI tutor analyzing study material or a textbook page.

$standardInstruction

Analyze the textbook page shown in the image carefully.

Your job is to:
- Identify the subject.
- Estimate the grade/class if possible.
- Identify the main topic.
- Explain what is actually visible on the page.
- Explain important terms in clear language matching the target education level.
- Give one relevant real-world example.

Language: $language

IMPORTANT RULES:
- Base the answer primarily on the uploaded textbook page.
- Do not invent facts that are not supported by the image.
- If the class/grade cannot be determined, say "Not clearly identified".
- If the subject cannot be determined, say "Not clearly identified".
- If the image is blurry or incomplete, clearly mention that.
- Keep the explanation tailored strictly to the target audience instructions above.
- Do not include greetings.
- Do not include Markdown headings using #.
- Do not add information outside the requested structure.
- Return ONLY the structure below.

SUBJECT: <subject>

GRADE: <grade or approximate class>

TOPIC: <main topic>

EXPLANATION:
<clear explanation tailored for this student's level>

KEY_TERMS:
- <term>: <meaning tailored for this student's level>
- <term>: <meaning tailored for this student's level>
- <term>: <meaning tailored for this student's level>

EXAMPLE:
<one relevant real-world example>
''';

    final content = [
      Content.multi([TextPart(prompt), InlineDataPart(mimeType, imageBytes)]),
    ];

    try {
      final response = await _model.generateContent(content);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return 'Sorry, I could not understand this textbook page.';
      }

      return text;
    } catch (e) {
      throw Exception('Failed to analyze textbook image: $e');
    }
  }

  // ============================================================
  // GENERATE QUIZ
  // ============================================================

  Future<List<GeminiQuizQuestion>> generateQuiz({
    required String subject,
    required String quizTitle,
    required int questionCount,
    String? standard,
    String language = 'English',
  }) async {
    final schema = Schema.object(
      properties: {
        'questions': Schema.array(
          items: Schema.object(
            properties: {
              'question': Schema.string(),
              'options': Schema.array(items: Schema.string()),
              'answerIndex': Schema.integer(),
              'explanation': Schema.string(),
            },
          ),
        ),
      },
    );

    final quizModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final standardInstruction = _getStandardInstruction(standard);
    final prompt =
        '''
You are EduSpark, an intelligent AI tutor creating a quiz.

$standardInstruction

Create a quiz with exactly $questionCount questions.

Subject: $subject
Quiz title: $quizTitle
Language: $language

IMPORTANT RULES:
- Questions must match the subject and quiz title.
- Keep the difficulty and depth strictly appropriate for the target audience level specified above.
- Each question must have exactly 4 options.
- Only ONE option must be correct.
- answerIndex must be 0, 1, 2, or 3.
- answerIndex represents the position of the correct option.
- Give a short explanation for the correct answer suitable for this level.
- Do not create trick questions.
- Do not create duplicate questions.
- Return ONLY the requested JSON structure.
''';

    try {
      final response = await quizModel.generateContent([Content.text(prompt)]);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        throw Exception('Gemini returned an empty quiz.');
      }

      final decoded = jsonDecode(text) as Map<String, dynamic>;

      final questions = decoded['questions'] as List<dynamic>;

      return questions
          .map(
            (question) =>
                GeminiQuizQuestion.fromJson(question as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  // ============================================================
  // YOUTUBE LEARNING SEARCH
  // ============================================================
  //
  // IMPORTANT:
  // Gemini does NOT directly give us a guaranteed YouTube video URL.
  // This method generates useful YouTube search queries.
  //
  // The Flutter YouTube feature can then use these queries to open
  // YouTube search results or later connect to the YouTube API.
  // ============================================================

  Future<List<String>> generateYouTubeSearchQueries({
    required String topic,
    String? subject,
    String? grade,
    String language = 'English',
  }) async {
    final schema = Schema.object(
      properties: {'queries': Schema.array(items: Schema.string())},
    );

    final targetGrade = (grade != null && grade.trim().isNotEmpty)
        ? grade.trim()
        : UserProfileService.instance.standard;

    final youtubeModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.6-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final prompt =
        '''
You are EduSpark, an AI tutor helping students find educational YouTube videos.

Create 5 useful YouTube search queries for this topic.

Topic: $topic
Subject: ${subject ?? 'Not specified'}
Grade/Standard: $targetGrade
Language: $language

Rules:
- Queries must be educational.
- Prefer searches that explain the topic clearly at the $targetGrade level.
- Include searches appropriate for the student's education standard ($targetGrade).
- Do not include entertainment or unrelated content.
- Do not invent video IDs or URLs.
- Return exactly 5 search queries.
''';

    try {
      final response = await youtubeModel.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        throw Exception('Gemini returned empty YouTube search suggestions.');
      }

      final decoded = jsonDecode(text) as Map<String, dynamic>;

      final queries = (decoded['queries'] as List<dynamic>)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();

      return queries;
    } catch (e) {
      throw Exception('Failed to generate YouTube search queries: $e');
    }
  }

  // ============================================================
  // WHITEBOARD PRACTICE
  // ============================================================

  Future<String> generateWhiteboardPractice({
    required String topic,
    String? subject,
    String? grade,
    String language = 'English',
  }) async {
    final targetGrade = (grade != null && grade.trim().isNotEmpty)
        ? grade.trim()
        : UserProfileService.instance.standard;
    final standardInstruction = _getStandardInstruction(targetGrade);

    final prompt =
        '''
You are EduSpark, an intelligent AI tutor creating a practice problem for a
student to solve on a digital whiteboard.

$standardInstruction

Topic: $topic
Subject: ${subject ?? 'Not specified'}
Grade/Standard: $targetGrade
Language: $language

Create ONE practice problem.

Rules:
- Make it strictly appropriate for the student's level ($targetGrade).
- The student should be able to solve it by writing/drawing steps
  on a whiteboard.
- Do not immediately reveal the answer.
- Give a short instruction telling the student what to do.
- Keep it clear and concise.
- Do not use Markdown headings using #.

Return only:
PROBLEM:
<problem>

HINT:
<short hint suitable for this student's level>
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return 'Could not generate a practice problem.';
      }

      return text;
    } catch (e) {
      throw Exception('Failed to generate whiteboard practice: $e');
    }
  }

  // ============================================================
  // CHECK WHITEBOARD ANSWER
  // ============================================================

  Future<String> checkWhiteboardAnswer({
    required Uint8List imageBytes,
    required String mimeType,
    required String problem,
    String? standard,
    String language = 'English',
  }) async {
    final standardInstruction = _getStandardInstruction(standard);
    final prompt =
        '''
You are EduSpark, an intelligent AI tutor checking a student's handwritten
work on a digital whiteboard.

$standardInstruction

Problem:
$problem

Language: $language

Look carefully at the student's handwritten work in the image.

Explain:
- Whether the approach is correct.
- What was done correctly.
- Any mistake that needs to be fixed.
- The next step the student should take.

IMPORTANT:
- Do not simply give the final answer if the student has made a mistake.
- Help the student learn from the work.
- Be encouraging but accurate.
- Keep the explanation strictly suitable for the student's education level.
- If the handwriting cannot be read, clearly say so.
- Do not use Markdown headings using #.

Return ONLY the feedback.
''';

    final content = [
      Content.multi([TextPart(prompt), InlineDataPart(mimeType, imageBytes)]),
    ];

    try {
      final response = await _model.generateContent(content);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return 'Sorry, I could not evaluate the whiteboard work.';
      }

      return text;
    } catch (e) {
      throw Exception('Failed to check whiteboard answer: $e');
    }
  }

  Future<String> generateNotes({
    required String topic,
    String? standard,
    String language = 'English',
  }) async {
    final standardInstruction = _getStandardInstruction(standard);
    final prompt =
        '''
You are EduSpark, an intelligent AI tutor creating study and revision notes.

$standardInstruction

Topic:
$topic

Language: $language

IMPORTANT RULES:
- Make the notes useful for study and exam revision.
- Calibrate the depth, vocabulary, formulas, and rigor strictly to the student's education level.
- Include the main definition or core conceptual principle.
- Include important points.
- Include formulas/theorems/paradigms when relevant.
- Include relevant examples matching the education level.
- Do not invent facts.
- Do not include greetings.
- Use Markdown formatting.
- Use headings, bullet points and numbered lists where useful.
- Keep the notes concise but complete.
- End with a short "Quick Revision" section containing 3 to 5 key points.

Return ONLY the revision notes.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        throw Exception('Gemini returned empty notes.');
      }

      return text;
    } catch (e) {
      throw Exception('Failed to generate notes: $e');
    }
  }
}
