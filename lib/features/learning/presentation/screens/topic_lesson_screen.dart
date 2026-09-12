import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/student_curriculum_service.dart';

class TopicLessonScreen extends StatefulWidget {
  final String topic;
  final String subject;

  const TopicLessonScreen({
    super.key,
    required this.topic,
    required this.subject,
  });

  @override
  State<TopicLessonScreen> createState() => _TopicLessonScreenState();
}

class _TopicLessonScreenState extends State<TopicLessonScreen> {
  bool _isCompleted = false;
  bool _isGeneratingAi = false;
  String? _aiExplanation;
  int _selectedQuizOption = -1;
  bool _hasAnsweredQuiz = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.topic,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              widget.subject,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Ask AI Tutor',
            onPressed: () {
              context.push('/ai-tutor/type');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            // Status banner
            if (_isCompleted)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Topic Completed! +25 XP Earned',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Topic Hero Card
            _buildHeroCard(),

            const SizedBox(height: 24),

            // Key Takeaways / Concept Breakdown
            _buildConceptSection(),

            const SizedBox(height: 24),

            // AI Explanation Section
            _buildAiExplanationSection(),

            const SizedBox(height: 24),

            // Interactive Mini Concept Check
            _buildConceptCheckSection(),

            const SizedBox(height: 30),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: AppColors.primary,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '~10 mins lesson',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+25 XP',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Core Fundamentals of ${widget.topic}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mastering ${widget.topic} builds an essential foundation in ${widget.subject}. Review key definitions, practical examples, and step-by-step concepts.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptSection() {
    final points = _getDefaultKeyPoints(widget.topic);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: AppColors.secondary, size: 20),
              SizedBox(width: 10),
              Text(
                'Key Concepts',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiExplanationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EduSpark AI Tutor',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Tailored explanation & exam hints',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_aiExplanation != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _aiExplanation!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _isGeneratingAi ? null : _generateAiExplanation,
              icon: _isGeneratingAi
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.psychology_rounded, size: 20),
              label: Text(
                _aiExplanation == null
                    ? 'Generate AI Deep Explanation'
                    : 'Regenerate Explanation',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptCheckSection() {
    final quiz = _getQuizForTopic(widget.topic);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.quiz_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'Quick Concept Check',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (_hasAnsweredQuiz)
                Text(
                  _selectedQuizOption == quiz.answerIndex
                      ? 'Correct! 🎉'
                      : 'Try Again',
                  style: TextStyle(
                    color: _selectedQuizOption == quiz.answerIndex
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            quiz.question,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...quiz.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;

            Color bgColor = AppColors.background;
            Color borderColor = AppColors.border;

            if (_hasAnsweredQuiz) {
              if (idx == quiz.answerIndex) {
                bgColor = AppColors.success.withValues(alpha: 0.15);
                borderColor = AppColors.success;
              } else if (idx == _selectedQuizOption) {
                bgColor = AppColors.danger.withValues(alpha: 0.15);
                borderColor = AppColors.danger;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedQuizOption = idx;
                    _hasAnsweredQuiz = true;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          String.fromCharCode(65 + idx),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isCompleted = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Awesome! Completed ${widget.topic} (+25 XP)'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              _isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.task_alt_rounded,
            ),
            label: Text(
              _isCompleted ? 'Completed ✓' : 'Mark Lesson as Completed',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              context.push('/ai-tutor/notes', extra: widget.topic);
            },
            icon: const Icon(Icons.note_alt_rounded, size: 18),
            label: const Text(
              'Generate Full Revision Notes',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generateAiExplanation() async {
    setState(() {
      _isGeneratingAi = true;
    });

    try {
      final currentStandard = StudentCurriculumService.instance.activeStandard;
      final answer = await GeminiService.instance.askQuestion(
        question:
            'Explain the topic "${widget.topic}" in ${widget.subject} for a student enrolled in $currentStandard. Provide a clear concept summary, 2 practical real-world applications or engineering/academic examples, and an essential exam/interview tip in 3 concise paragraphs.',
      );

      if (!mounted) return;
      setState(() {
        _aiExplanation = answer;
        _isGeneratingAi = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGeneratingAi = false;
        _aiExplanation =
            '${widget.topic} in ${widget.subject} is fundamental. Focus on core architectural principles, step-by-step algorithms, and solving practical test cases to master this module.';
      });
    }
  }

  List<String> _getDefaultKeyPoints(String topic) {
    final t = topic.toLowerCase();

    // OS Topics
    if (t.contains('process') || t.contains('lifecycle')) {
      return const [
        'A Process is a program in execution containing Text, Data, Heap, and Stack segments.',
        'Process States: New -> Ready -> Running -> Waiting/Blocked -> Terminated.',
        'Process Control Block (PCB) stores PID, Registers, PC, and Scheduling state during context switching.',
        'fork() creates an identical child process; exec() replaces address space with a new program.',
      ];
    }
    if (t.contains('schedul')) {
      return const [
        'CPU Scheduler selects ready processes to allocate CPU time via the dispatcher.',
        'Metrics evaluated: CPU Utilization, Throughput, Turnaround Time, Waiting Time & Response Time.',
        'Shortest Job First (SJF) gives minimum average waiting time but requires burst prediction.',
        'Round Robin (RR) allocates a fixed time quantum, ensuring fairness without starvation.',
      ];
    }
    if (t.contains('synchro') || t.contains('mutex') || t.contains('concurrency')) {
      return const [
        'Critical Section problem requires 3 criteria: Mutual Exclusion, Progress, and Bounded Waiting.',
        'Mutex is a locking primitive owned by a single thread; Semaphores are signaling integer counters.',
        'Counting semaphores coordinate resource pools using atomic wait (P) and signal (V) operations.',
        'Classic synchronization dilemmas include Producer-Consumer, Dining Philosophers, and Readers-Writers.',
      ];
    }
    if (t.contains('deadlock')) {
      return const [
        'Deadlock occurs when 4 Coffman conditions hold: Mutual Exclusion, Hold & Wait, No Preemption, Circular Wait.',
        'Resource Allocation Graphs (RAG) detect deadlocks through cycles in single-instance resource systems.',
        'Banker\'s Algorithm computes safety vectors (Available, Max, Allocation, Need) to avoid deadlock states.',
        'Recovery involves process termination (abort all or one-by-one) or resource preemption with rollback.',
      ];
    }
    if (t.contains('paging') || t.contains('virtual memory')) {
      return const [
        'Virtual memory allows execution of processes exceeding physical RAM capacity via demand paging.',
        'Paging maps fixed-size logical Pages into physical memory Frames using the Page Table.',
        'Translation Lookaside Buffer (TLB) is an associative hardware cache reducing memory translation overhead.',
        'Page Replacement algorithms: FIFO, LRU (Least Recently Used), and Optimal (FIFO exhibits Belady\'s Anomaly).',
      ];
    }

    // DSA Topics
    if (t.contains('tree') || t.contains('bst')) {
      return const [
        'Binary Search Tree (BST) property: left subtree values < root < right subtree values.',
        'In-order traversal of a BST produces elements in strictly ascending sorted order.',
        'Balanced search trees (AVL, Red-Black) guarantee O(log n) worst-case search, insertion, and deletion.',
        'Tree rotations (Left, Right, Left-Right, Right-Left) restore height balance dynamically.',
      ];
    }
    if (t.contains('graph')) {
      return const [
        'Graphs represent networks of vertices and edges (directed/undirected, weighted/unweighted).',
        'Breadth-First Search (BFS) uses a FIFO Queue and identifies shortest paths in unweighted graphs.',
        'Depth-First Search (DFS) uses recursion/Stack; essential for cycle detection and Topological Sorting.',
        'Dijkstra\'s algorithm computes single-source shortest paths in O((V + E) log V) using a Min-Priority Queue.',
      ];
    }
    if (t.contains('dynamic programming')) {
      return const [
        'Dynamic Programming applies when problems exhibit Optimal Substructure and Overlapping Subproblems.',
        'Top-Down Memoization stores recursion results; Bottom-Up Tabulation builds iterative table entries.',
        'Classic canonical DP problems: 0/1 Knapsack, Longest Common Subsequence (LCS), and Edit Distance.',
        'Always formulate the state representation and recurrence relation before optimizing memory space.',
      ];
    }

    // DBMS Topics
    if (t.contains('relational') || t.contains('sql') || t.contains('normaliz') || t.contains('acid')) {
      return const [
        'ACID Properties ensure transaction reliability: Atomicity, Consistency, Isolation, and Durability.',
        'Normalization eliminates redundant data and insertion/update/deletion anomalies.',
        'Normal Forms: 1NF (Atomic attributes), 2NF (No partial dependency), 3NF (No transitive dependency), BCNF.',
        'B+ Tree indexing structures optimize search, range queries, and sequential disk reads.',
      ];
    }

    // Computer Networks Topics
    if (t.contains('network') || t.contains('osi') || t.contains('tcp') || t.contains('protocol')) {
      return const [
        'OSI 7-Layer model: Physical, Data Link, Network, Transport, Session, Presentation, Application.',
        'TCP guarantees reliable, ordered byte streams via 3-way handshake and sliding window flow control.',
        'UDP provides lightweight, connectionless datagram delivery with minimal latency overhead.',
        'IPv4 addresses (32-bit) and IPv6 (128-bit) route global packets using CIDR subnet masks.',
      ];
    }

    // AI / ML Topics
    if (t.contains('regression') || t.contains('neural') || t.contains('deep learning') || t.contains('nlp')) {
      return const [
        'Supervised learning trains models on labeled datasets to minimize empirical prediction error.',
        'Gradient Descent iteratively updates model parameters opposite to the gradient of the loss function.',
        'Backpropagation uses the calculus chain rule to distribute errors back across neural network layers.',
        'Regularization techniques (L1/L2, Dropout, Batch Normalization) prevent overfitting on training data.',
      ];
    }

    // School STEM Topics
    if (t.contains('photosynthesis')) {
      return const [
        'Plants convert light energy into chemical energy stored in glucose.',
        'Equation: 6CO₂ + 6H₂O + Sunlight ➔ C₆H₁₂O₆ + 6O₂.',
        'Takes place in the chloroplasts containing the green pigment chlorophyll.',
        'Essential for generating oxygen and sustaining all earth food chains.',
      ];
    }
    if (t.contains('fraction')) {
      return const [
        'A fraction represents part of a whole: Numerator / Denominator.',
        'Proper fraction: numerator < denominator (e.g. 3/4).',
        'Improper fraction: numerator ≥ denominator (e.g. 5/2).',
        'To add or subtract fractions, always find the Common Denominator (LCM).',
      ];
    }
    if (t.contains('matter')) {
      return const [
        'Matter is anything that has mass and occupies volume.',
        'Three primary physical states: Solid, Liquid, and Gas.',
        'Solid has fixed shape & volume; Liquid has fixed volume; Gas fills container.',
        'States can change with temperature: melting, boiling, condensation, freezing.',
      ];
    }
    if (t.contains('grammar')) {
      return const [
        'Sentences require a Subject, Verb, and Object for complete meaning.',
        'Parts of speech: Noun, Pronoun, Verb, Adjective, Adverb, Preposition, Conjunction.',
        'Subject-verb agreement: Singular subjects take singular verbs.',
        'Punctuation guides rhythm and clarity in written communication.',
      ];
    }

    // Dynamic Fallback
    return [
      'Fundamental definitions, mathematical formulas, and primary principles of $topic.',
      'Core architectural workflow, execution pipeline, and standard algorithms in ${widget.subject}.',
      'Real-world industry applications, practical implementation trade-offs, and system constraints.',
      'Critical edge cases, optimization strategies, and high-yield examination problem patterns.',
    ];
  }

  _TopicQuiz _getQuizForTopic(String topic) {
    final t = topic.toLowerCase();

    if (t.contains('schedul') || t.contains('process') || t.contains('operat') || t.contains('kernel')) {
      return const _TopicQuiz(
        question: 'Which CPU scheduling algorithm minimizes the average waiting time for a given set of processes?',
        options: [
          'SJF (Shortest Job First)',
          'FCFS (First Come First Served)',
          'Round Robin with large quantum',
          'Priority without preemption',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('deadlock')) {
      return const _TopicQuiz(
        question: 'Which algorithm is used by Operating Systems for deadlock avoidance in resource allocation?',
        options: [
          'Banker\'s Algorithm',
          'Dijkstra\'s Algorithm',
          'Round Robin Scheduling',
          'Peterson\'s Algorithm',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('paging') || t.contains('memory')) {
      return const _TopicQuiz(
        question: 'Which hardware cache is used to speed up virtual-to-physical address translation in paging?',
        options: [
          'TLB (Translation Lookaside Buffer)',
          'L3 Memory Cache',
          'Instruction Register',
          'Disk Write Buffer',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('tree') || t.contains('bst') || t.contains('algorithm') || t.contains('dsa')) {
      return const _TopicQuiz(
        question: 'What is the worst-case time complexity of searching an element in a balanced AVL or Red-Black Tree?',
        options: [
          'O(log n)',
          'O(n)',
          'O(1)',
          'O(n log n)',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('graph')) {
      return const _TopicQuiz(
        question: 'Which algorithm finds the single-source shortest path in a graph with non-negative edge weights?',
        options: [
          'Dijkstra\'s Algorithm',
          'Kruskal\'s Algorithm',
          'Depth-First Search',
          'Floyd-Warshall Algorithm',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('database') || t.contains('acid') || t.contains('dbms') || t.contains('normaliz')) {
      return const _TopicQuiz(
        question: 'Which ACID property guarantees that transaction modifications persist permanently even across power failures?',
        options: [
          'Durability',
          'Atomicity',
          'Consistency',
          'Isolation',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('network') || t.contains('tcp') || t.contains('protocol')) {
      return const _TopicQuiz(
        question: 'Which transport protocol performs a 3-way handshake (SYN, SYN-ACK, ACK) before data transfer?',
        options: [
          'TCP',
          'UDP',
          'ICMP',
          'DNS',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('neural') || t.contains('machine learn') || t.contains('ai') || t.contains('deep')) {
      return const _TopicQuiz(
        question: 'Which algorithm calculates the gradients of the loss function with respect to weights using the chain rule?',
        options: [
          'Backpropagation',
          'K-Means Clustering',
          'Principal Component Analysis',
          'Linear Discriminant Analysis',
        ],
        answerIndex: 0,
      );
    }
    if (t.contains('photosynthesis')) {
      return const _TopicQuiz(
        question: 'Which pigment absorbs light energy during photosynthesis?',
        options: ['Chlorophyll', 'Hemoglobin', 'Melanin', 'Carotene'],
        answerIndex: 0,
      );
    }
    if (t.contains('fraction')) {
      return const _TopicQuiz(
        question: 'What is 1/2 + 1/4 equal to?',
        options: ['2/6', '3/4', '1/3', '2/4'],
        answerIndex: 1,
      );
    }
    if (t.contains('matter')) {
      return const _TopicQuiz(
        question: 'Which state of matter has neither a definite shape nor a definite volume?',
        options: ['Solid', 'Liquid', 'Gas', 'Crystal'],
        answerIndex: 2,
      );
    }
    return const _TopicQuiz(
      question: 'Which method is most effective when studying a technical module?',
      options: [
        'Passive reading without problem-solving',
        'Solving active practice questions & reviewing edge cases',
        'Skipping foundational definitions directly to past exams',
        'Memorizing solutions without understanding algorithms',
      ],
      answerIndex: 1,
    );
  }
}

class _TopicQuiz {
  final String question;
  final List<String> options;
  final int answerIndex;

  const _TopicQuiz({
    required this.question,
    required this.options,
    required this.answerIndex,
  });
}
