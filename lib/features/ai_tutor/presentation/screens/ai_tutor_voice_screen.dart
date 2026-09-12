import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/gemini_service.dart';

class AiTutorVoiceScreen extends StatefulWidget {
  const AiTutorVoiceScreen({super.key});

  @override
  State<AiTutorVoiceScreen> createState() => _AiTutorVoiceScreenState();
}

class _AiTutorVoiceScreenState extends State<AiTutorVoiceScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  String _spokenText = '';
  String _answer = '';

  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _speechAvailable = available;
    });
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      await _initializeSpeech();
    }

    if (!_speechAvailable) {
      _showMessage('Speech recognition is not available on this device.');
      return;
    }

    setState(() {
      _spokenText = '';
      _answer = '';
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          _spokenText = result.recognizedWords;
        });
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });
  }

  Future<void> _askGemini() async {
    final question = _spokenText.trim();

    if (question.isEmpty) {
      _showMessage('Please speak your question first.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _answer = '';
    });

    try {
      final answer = await GeminiService.instance.askQuestion(
        question: question,
        language: 'English',
      );

      if (!mounted) return;

      setState(() {
        _answer = answer;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage('Sorry, I could not get an answer. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearQuestion() {
    setState(() {
      _spokenText = '';
      _answer = '';
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,

        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 21,
            ),
            SizedBox(width: 8),
            Text('Voice Tutor', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 10),

              const Text(
                'Ask your question',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Speak naturally and I will help you understand it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              // MICROPHONE
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),

                  width: 120,
                  height: 120,

                  decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : AppColors.surface,

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: _isListening ? 0.45 : 0.18,
                      ),
                      width: 2,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: _isListening ? 0.15 : 0.05,
                        ),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),

                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                _isListening
                    ? 'Listening... Tap to stop'
                    : 'Tap the microphone to speak',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              // SPOKEN QUESTION
              if (_spokenText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Your question',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        _spokenText,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (_spokenText.isNotEmpty) const SizedBox(height: 16),

              // ASK BUTTON
              if (_spokenText.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _askGemini,

                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded),

                    label: Text(
                      _isLoading ? 'Thinking...' : 'Ask EduSpark',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              if (_spokenText.isNotEmpty) const SizedBox(height: 10),

              if (_spokenText.isNotEmpty)
                TextButton.icon(
                  onPressed: _isLoading ? null : _clearQuestion,

                  icon: const Icon(Icons.refresh_rounded, size: 18),

                  label: const Text('Ask another question'),
                ),

              // ANSWER
              if (_answer.isNotEmpty) ...[
                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),

                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,

                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.primary,
                              size: 19,
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'EduSpark Answer',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _answer,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
