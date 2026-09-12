import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/user_profile_service.dart';

class AiTutorTypeQuestionScreen extends StatefulWidget {
  const AiTutorTypeQuestionScreen({super.key});

  @override
  State<AiTutorTypeQuestionScreen> createState() =>
      _AiTutorTypeQuestionScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}

class _AiTutorTypeQuestionScreenState extends State<AiTutorTypeQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type a question first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));

      _isLoading = true;
      _questionController.clear();
    });

    _scrollToBottom();

    try {
      final conversation = _buildConversationPrompt(question);

      final answer = await GeminiService.instance.askQuestion(
        question: conversation,
        standard: UserProfileService.instance.standard,
        language: 'English',
      );

      if (!mounted) return;

      setState(() {
        _messages.add(_ChatMessage(text: answer, isUser: false));

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _buildConversationPrompt(String newQuestion) {
    if (_messages.length <= 1) {
      return newQuestion;
    }

    final currentStd = UserProfileService.instance.standard;
    final buffer = StringBuffer();

    buffer.writeln('''
You are continuing an ongoing conversation between a student and EduSpark.

Target Education Level: $currentStd

Use the previous conversation to understand what the student means.

IMPORTANT:
- Answer the student's latest question directly.
- Remember the previous discussion.
- If the student says "that", "this", "the second part", "explain more", etc.,
  use the previous messages to understand the reference.
- Do not repeat the entire previous answer unless necessary.
- Tailor the depth, tone, complexity, and vocabulary strictly for this student's level ($currentStd).
- Give examples when useful.
- Do not mention that you were given conversation history.
- Return only the answer.
''');

    buffer.writeln('PREVIOUS CONVERSATION:');
    buffer.writeln();

    for (final message in _messages) {
      if (message.isUser) {
        buffer.writeln('STUDENT: ${message.text}');
      } else {
        buffer.writeln('EDUSPARK: ${message.text}');
      }

      buffer.writeln();
    }

    buffer.writeln('LATEST STUDENT QUESTION:');
    buffer.writeln(newQuestion);

    return buffer.toString();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _questionController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  Future<void> _openYouTube() async {
    final topic = _messages
        .where((message) => message.isUser)
        .map((message) => message.text)
        .join(' ');

    if (topic.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ask a question first to find related videos.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.https('www.youtube.com', '/results', {
      'search_query': '$topic educational explanation',
    });

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open YouTube.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open YouTube.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openWhiteboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const _WhiteboardSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
                SizedBox(width: 7),
                Text(
                  'Ask EduSpark',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Adaptive • ${UserProfileService.instance.standard}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              tooltip: 'New chat',
              onPressed: _startNewChat,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : _buildConversation(),
            ),

            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      child: Column(
        children: [
          const SizedBox(height: 35),

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'What do you want to know?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Ask EduSpark anything about your studies. '
            'You can keep asking follow-up questions too.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 30),

          _SuggestionCard(
            icon: Icons.science_rounded,
            text: 'Explain photosynthesis in simple words',
            onTap: () {
              _questionController.text =
                  'Explain photosynthesis in simple words';
            },
          ),

          const SizedBox(height: 10),

          _SuggestionCard(
            icon: Icons.calculate_rounded,
            text: 'Explain how quadratic equations work',
            onTap: () {
              _questionController.text = 'Explain how quadratic equations work';
            },
          ),

          const SizedBox(height: 10),

          _SuggestionCard(
            icon: Icons.menu_book_rounded,
            text: 'Help me understand a difficult topic',
            onTap: () {
              _questionController.text = 'Help me understand a difficult topic';
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildThinkingBubble();
        }

        final message = _messages[index];

        if (message.isUser) {
          return _buildUserMessage(message.text);
        }

        return _buildAiMessage(message.text);
      },
    );
  }

  Widget _buildUserMessage(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        margin: const EdgeInsets.only(left: 45, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(
            20,
          ).copyWith(bottomRight: const Radius.circular(5)),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAiMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 20),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          20,
        ).copyWith(bottomLeft: const Radius.circular(5)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'EduSpark',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          MarkdownBody(
            data: message,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.65,
              ),
              strong: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              em: const TextStyle(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
              h1: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              h2: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
              h3: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              listBullet: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
              ),
              code: TextStyle(
                color: AppColors.textPrimary,
                backgroundColor: AppColors.background,
                fontSize: 14,
              ),
              blockquote: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 18),

          _buildTutorTools(),
        ],
      ),
    );
  }

  Widget _buildTutorTools() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ToolButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Ask follow-up',
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
        ),
        _ToolButton(
          icon: Icons.play_circle_outline_rounded,
          label: 'Watch on YouTube',
          onTap: _openYouTube,
        ),
        _ToolButton(
          icon: Icons.draw_rounded,
          label: 'Practice',
          onTap: _openWhiteboard,
        ),
      ],
    );
  }

  Widget _buildThinkingBubble() {
    return Container(
      margin: const EdgeInsets.only(right: 100, bottom: 20),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Thinking...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _questionController,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask a follow-up question...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                onSubmitted: (_) {
                  if (!_isLoading) {
                    _askQuestion();
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 50,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _askQuestion,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded, size: 23),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteboardSheet extends StatefulWidget {
  const _WhiteboardSheet();

  @override
  State<_WhiteboardSheet> createState() => _WhiteboardSheetState();
}

class _WhiteboardSheetState extends State<_WhiteboardSheet> {
  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;

  void _startStroke(Offset point) {
    setState(() {
      _currentStroke = [point];
      _strokes.add(_currentStroke!);
    });
  }

  void _updateStroke(Offset point) {
    if (_currentStroke == null) return;

    setState(() {
      _currentStroke!.add(point);
    });
  }

  void _clearBoard() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;

    setState(() {
      _strokes.removeLast();
      _currentStroke = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.draw_rounded, color: AppColors.primary),
                    SizedBox(width: 9),
                    Text(
                      'Practice Whiteboard',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                tooltip: 'Undo',
                onPressed: _undo,
                icon: const Icon(
                  Icons.undo_rounded,
                  color: AppColors.textSecondary,
                ),
              ),

              IconButton(
                tooltip: 'Clear',
                onPressed: _clearBoard,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: GestureDetector(
                  onPanStart: (details) {
                    _startStroke(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _updateStroke(details.localPosition);
                  },
                  onPanEnd: (_) {
                    _currentStroke = null;
                  },
                  child: CustomPaint(
                    painter: _WhiteboardPainter(strokes: _strokes),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Draw equations, diagrams, steps, or anything you want to practise.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Done Practising',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  const _WhiteboardPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.5, paint);
        continue;
      }

      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);

      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}
