import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'topic_lesson_screen.dart';

class SubjectTopicsScreen extends StatelessWidget {
  final String subject;
  final IconData icon;

  const SubjectTopicsScreen({
    super.key,
    required this.subject,
    required this.icon,
  });

  List<_TopicData> _topicsForSubject() {
    final s = subject.toLowerCase().trim();

    // 1. Operating Systems & Kernel Architecture
    if (s.contains('operat') || s.contains('kernel') || s == 'os') {
      return const [
        _TopicData('Process Management & Lifecycle', 'Process States, PCB, Context Switching & fork()', 0.85),
        _TopicData('CPU Scheduling Algorithms', 'FCFS, SJF, Round Robin & Multi-Level Feedback Queues', 0.70),
        _TopicData('Process Synchronization & Concurrency', 'Critical Section, Mutex, Semaphores & Peterson Algorithm', 0.50),
        _TopicData('Deadlocks & Banker\'s Algorithm', 'Coffman Conditions, Prevention, Avoidance & Resource Graphs', 0.30),
        _TopicData('Virtual Memory & Paging', 'Page Tables, TLB, Page Replacement (LRU, FIFO) & Thrashing', 0.15),
        _TopicData('File Systems & Disk Scheduling', 'Inodes, File Allocation, FCFS, SSTF, SCAN & C-SCAN', 0.0),
        _TopicData('System Calls & Kernel Arch', 'Monolithic vs Microkernel, Interrupts & Trap Handling', 0.0),
      ];
    }

    // 2. Data Structures & Algorithms
    if (s.contains('data struct') || s.contains('algorithm') || s.contains('dsa')) {
      return const [
        _TopicData('Arrays & Dynamic Sizing', 'Amortized Analysis, Two Pointers & Sliding Window', 0.90),
        _TopicData('Linked Lists & Pointer Manipulation', 'Singly, Doubly, Circular Lists & Cycle Detection', 0.75),
        _TopicData('Stacks & Queues', 'LIFO/FIFO, Monotonic Stack & Circular Queue', 0.60),
        _TopicData('Trees & Binary Search Trees', 'In/Pre/Post Traversals, Balanced AVL & Red-Black Trees', 0.40),
        _TopicData('Heaps & Priority Queues', 'Min/Max Heap, Heapify, Heapsort & Median Maintenance', 0.25),
        _TopicData('Hashing & Hash Tables', 'Hash Functions, Collisions, Chaining & Open Addressing', 0.15),
        _TopicData('Graph Algorithms: BFS, DFS & Dijkstra', 'Adjacency Lists, Topological Sort & Shortest Paths', 0.0),
        _TopicData('Dynamic Programming & Memoization', 'Subproblems, Memoization vs Tabulation, 0/1 Knapsack & LCS', 0.0),
      ];
    }

    // 3. Database Management Systems (DBMS)
    if (s.contains('database') || s.contains('dbms') || s.contains('sql')) {
      return const [
        _TopicData('Relational Model & ER Diagrams', 'Entities, Relationships, Cardinality & Key Constraints', 0.85),
        _TopicData('Relational Algebra & Tuple Calculus', 'Select, Project, Cartesian Product, Joins & Set Operations', 0.70),
        _TopicData('Advanced SQL & Aggregations', 'Joins, Subqueries, Group By, Window Functions & CTEs', 0.50),
        _TopicData('Database Normalization', 'Functional Dependencies, 1NF, 2NF, 3NF & BCNF Normalization', 0.35),
        _TopicData('Transactions & ACID Properties', 'Atomicity, Consistency, Isolation Levels & Durability', 0.20),
        _TopicData('Concurrency Control & 2PL', 'Two-Phase Locking, Deadlock Handling & Timestamp Protocols', 0.0),
        _TopicData('Indexing & B+ Trees', 'Primary/Secondary Indexes, B+ Tree Indexing & Query Plans', 0.0),
      ];
    }

    // 4. Computer Networks
    if (s.contains('network') || s.contains('protocol')) {
      return const [
        _TopicData('Network Architecture & OSI Model', '7-Layer OSI Model vs 4-Layer TCP/IP Stack & Encapsulation', 0.85),
        _TopicData('Data Link Layer & Error Detection', 'Framing, Parity, Checksum, CRC & Sliding Window Protocols', 0.65),
        _TopicData('Medium Access Control (MAC)', 'CSMA/CD, CSMA/CA, Ethernet Standards & Collision Resolution', 0.45),
        _TopicData('Network Layer & IPv4/IPv6', 'IP Addressing, CIDR Subnetting, NAT, ARP & ICMP', 0.30),
        _TopicData('Routing Protocols: OSPF & BGP', 'Distance-Vector (RIP), Link-State (OSPF) & BGP Routing', 0.15),
        _TopicData('Transport Layer: TCP vs UDP', 'Three-Way Handshake, Flow Control & Congestion Avoidance', 0.0),
        _TopicData('Application Layer: DNS, HTTP/3 & TLS', 'DNS Lookup, HTTP/2 & HTTP/3 (QUIC), SSL/TLS Handshake', 0.0),
      ];
    }

    // 5. Artificial Intelligence & Machine Learning
    if (s.contains('ai') || s.contains('artificial') || s.contains('machine learn') || s.contains('ml')) {
      return const [
        _TopicData('Linear & Logistic Regression', 'Cost Functions, Gradient Descent & Bias-Variance Tradeoff', 0.85),
        _TopicData('Supervised Classification', 'Decision Trees, Random Forests & Support Vector Machines (SVM)', 0.65),
        _TopicData('Unsupervised Learning & Clustering', 'K-Means, Hierarchical Clustering & PCA Dimensionality Reduction', 0.40),
        _TopicData('Neural Networks & Backpropagation', 'Perceptron, Multi-Layer Perceptron, Activation Functions & Loss', 0.25),
        _TopicData('Deep Learning & CNNs', 'Convolutional Filters, Pooling, ResNet & Transfer Learning', 0.10),
        _TopicData('Natural Language Processing (NLP)', 'Tokenization, Embeddings, RNN/LSTM & Transformer Attention', 0.0),
      ];
    }

    // 6. Software Engineering & Cloud DevOps
    if (s.contains('devops') || s.contains('software eng') || s.contains('cloud')) {
      return const [
        _TopicData('Software Development Life Cycle (SDLC)', 'Agile, Scrum Sprints, Kanban Boards & Milestone Tracking', 0.80),
        _TopicData('Design Patterns & SOLID Principles', 'Singleton, Factory, Observer, Strategy & Clean Code Architecture', 0.60),
        _TopicData('Version Control & Git Workflows', 'Branching Strategies, Git Flow, Rebase & Pull Request Reviews', 0.45),
        _TopicData('Automated Testing & TDD', 'Unit Testing, Integration Testing, Mocking & CI Test Suites', 0.25),
        _TopicData('CI/CD Pipelines & GitHub Actions', 'Build Automation, Linting, Artifact Deployment & Workflows', 0.10),
        _TopicData('Docker Containers & Kubernetes', 'Dockerfiles, Container Images, Kubernetes Pods & Microservices', 0.0),
      ];
    }

    // 7. Compiler Design & Theory of Computation
    if (s.contains('compiler') || s.contains('computation') || s.contains('automata')) {
      return const [
        _TopicData('Finite Automata & Regular Languages', 'DFA, NFA, Regular Expressions & State Minimization', 0.80),
        _TopicData('Context-Free Grammars & Pushdown Automata', 'CFG, Ambiguity, Pushdown Automata & Chomsky Normal Form', 0.60),
        _TopicData('Lexical & Syntactic Analysis', 'Lexers, LL(1) Parsing, LR(0), SLR & LALR Parsers', 0.40),
        _TopicData('Syntax Directed Translation (SDT)', 'Annotated Parse Trees, S-Attributed & L-Attributed SDDs', 0.20),
        _TopicData('Intermediate Code Generation & 3AC', 'Three-Address Code, Quadruples, Triples & Syntax Trees', 0.0),
        _TopicData('Code Optimization & Register Allocation', 'Basic Blocks, Flow Graphs, Loop Invariants & Graph Coloring', 0.0),
      ];
    }

    // 8. Mechanical Engineering
    if (s.contains('thermodynamic') || s.contains('heat')) {
      return const [
        _TopicData('First & Second Laws of Thermodynamics', 'Internal Energy, Heat, Work, Enthalpy & Entropy Formulation', 0.80),
        _TopicData('Carnot & Rankine Power Cycles', 'Vapor Power Cycles, Thermal Efficiency & Reheat Systems', 0.60),
        _TopicData('Refrigeration & Heat Pumps', 'Vapor Compression Refrigeration Cycle & COP Analysis', 0.40),
        _TopicData('Conduction & Thermal Resistance', 'Fourier\'s Law, Plane Walls, Cylinders & Critical Insulation', 0.20),
        _TopicData('Convection & Radiation Heat Transfer', 'Newton\'s Law of Cooling, Stefan-Boltzmann Law & Emissivity', 0.0),
        _TopicData('Heat Exchangers & LMTD Method', 'Log Mean Temperature Difference & Effectiveness-NTU Method', 0.0),
      ];
    }

    if (s.contains('fluid')) {
      return const [
        _TopicData('Fluid Statics & Hydrostatic Pressure', 'Pressure Measurement, Manometers, Buoyancy & Metacenter', 0.80),
        _TopicData('Bernoulli Equation & Flow Dynamics', 'Euler Equation, Energy Equation & Pitot Tube Velocity', 0.60),
        _TopicData('Navier-Stokes & Viscous Fluid Flow', 'Differential Continuity, Momentum & Laminar Velocity Profiles', 0.40),
        _TopicData('Laminar vs Turbulent Pipe Flow', 'Reynolds Number, Darcy-Weisbach Friction & Moody Chart', 0.20),
        _TopicData('Boundary Layer Theory & Drag', 'Displacement Thickness, Momentum Thickness & Separation Control', 0.0),
        _TopicData('Pumps, Turbines & Turbo-Machinery', 'Pelton Wheel, Francis Turbine & Centrifugal Pump Curves', 0.0),
      ];
    }

    if (s.contains('strength') || s.contains('solid mechanics')) {
      return const [
        _TopicData('Stress-Strain & Hooke\'s Law', 'Tensile Testing, Elastic Modulus, Poisson\'s Ratio & Factor of Safety', 0.85),
        _TopicData('Mohr\'s Circle & Principal Stresses', 'Biaxial Stress States, Principal Planes & Maximum Shear Stress', 0.65),
        _TopicData('Shear Force & Bending Moment (SFD/BMD)', 'Cantilever, Simply Supported & Overhanging Beam Loadings', 0.45),
        _TopicData('Deflection of Beams', 'Double Integration, Macaulay\'s Method & Superposition', 0.25),
        _TopicData('Torsion of Shafts & Polar Modulus', 'Torsional Shear Stress, Power Transmission & Angle of Twist', 0.10),
        _TopicData('Euler\'s Column Buckling', 'Critical Buckling Load, Slenderness Ratio & End Fixity Conditions', 0.0),
      ];
    }

    if (s.contains('kinematic') || s.contains('robot')) {
      return const [
        _TopicData('Degrees of Freedom & Linkages', 'Gruebler & Kutzbach Criteria, Four-Bar Mechanism & Inversions', 0.80),
        _TopicData('Velocity & Acceleration Analysis', 'Instantaneous Centers of Rotation & Coriolis Acceleration', 0.60),
        _TopicData('Gears & Epicyclic Gear Trains', 'Law of Gearing, Involute Profile, Velocity Ratios & Sun-Planet Gears', 0.40),
        _TopicData('Cams & Follower Kinematics', 'SHM, Uniform Velocity, Cycloidal Cam Motion & Profile Synthesis', 0.20),
        _TopicData('Robot Kinematics: Forward & Inverse', 'DH Parameters, Transformation Matrices & Workspace Analysis', 0.0),
        _TopicData('Actuators, Sensors & End-Effectors', 'Servos, Stepper Motors, Tactile Grippers & Motion Controllers', 0.0),
      ];
    }

    // 9. Medical (MBBS) Subjects
    if (s.contains('anatomy')) {
      return const [
        _TopicData('Musculoskeletal & Upper Limb Anatomy', 'Bones, Joints, Brachial Plexus & Nerve Injuries', 0.80),
        _TopicData('Thorax, Heart & Coronary Circulation', 'Cardiac Chambers, Valves, Great Vessels & Auscultation', 0.60),
        _TopicData('Abdomen & Gastrointestinal Viscera', 'Peritoneum, Stomach, Liver, Gallbladder & Blood Supply', 0.40),
        _TopicData('Head, Neck & Cranial Nerves', 'Cranial Nerves 1-12, Face, Pharynx, Larynx & Infratemporal Fossa', 0.20),
        _TopicData('Neuroanatomy: Brain & Spinal Cord', 'Cerebrum, Cerebellum, Brainstem, Ventricles & CSF Pathway', 0.0),
        _TopicData('Histology & Microscopic Anatomy', 'Epithelium, Connective Tissue, Cartilage, Bone & Organ Biopsies', 0.0),
      ];
    }

    if (s.contains('physiolog')) {
      return const [
        _TopicData('Membrane Transport & Resting Potentials', 'Diffusion, Nernst Potential, Ion Channels & Action Potentials', 0.85),
        _TopicData('Cardiac Cycle & 12-Lead ECG', 'Wiggers Diagram, Cardiac Output, Blood Pressure & Conduction', 0.65),
        _TopicData('Respiratory Mechanics & Gas Exchange', 'Lung Volumes, Surfactant, V/Q Matching & O2-CO2 Transport', 0.45),
        _TopicData('Renal Physiology & Fluid Balance', 'Glomerular Filtration Rate, Tubular Reabsorption & RAAS System', 0.25),
        _TopicData('Endocrine Control & Hormones', 'Hypothalamic-Pituitary Axis, Thyroid, Adrenal & Insulin Regulation', 0.10),
        _TopicData('Neurophysiology & Reflexes', 'Synaptic Transmission, Neuromuscular Junction & Motor Pathways', 0.0),
      ];
    }

    if (s.contains('biochem')) {
      return const [
        _TopicData('Protein Structure & Enzyme Kinetics', 'Peptide Bonds, Michaelis-Menten Equation, Km, Vmax & Inhibition', 0.80),
        _TopicData('Carbohydrate Metabolism', 'Glycolysis, Gluconeogenesis, Glycogen Storage & Pentose Pathway', 0.60),
        _TopicData('Citric Acid Cycle & Oxidative Phosphorylation', 'TCA Cycle, Electron Transport Chain Complexes & ATP Synthase', 0.40),
        _TopicData('Lipid Metabolism & Ketogenesis', 'Beta-Oxidation of Fatty Acids, Cholesterol & Lipoproteins (HDL/LDL)', 0.20),
        _TopicData('Nucleic Acids & Molecular Genetics', 'Purine/Pyrimidine Synthesis, DNA Replication & Transcription', 0.0),
        _TopicData('Vitamins, Minerals & Clinical Markers', 'Fat/Water Soluble Vitamins, Electrolytes & Liver/Kidney Panels', 0.0),
      ];
    }

    if (s.contains('patholog') || s.contains('pharma')) {
      return const [
        _TopicData('Cellular Adaptations & Cell Death', 'Hypertrophy, Metaplasia, Coagulative/Liquefactive Necrosis & Apoptosis', 0.80),
        _TopicData('Inflammation & Tissue Repair', 'Vascular & Cellular Events, Chemical Mediators, Granulation Tissue', 0.60),
        _TopicData('Hemodynamic Disorders & Thrombosis', 'Virchow Triad, Thromboembolism, Infarction & Shock Stages', 0.40),
        _TopicData('Neoplasia & Carcinogenesis', 'Benign vs Malignant, Oncogenes, Tumor Suppressors & Metastasis', 0.20),
        _TopicData('Pharmacokinetics: ADME Principles', 'Absorption, Bioavailability, Distribution, Metabolism & Elimination', 0.10),
        _TopicData('Autonomic & Cardiovascular Drugs', 'Adrenergic, Cholinergic, Beta-Blockers, ACE Inhibitors & Statins', 0.0),
      ];
    }

    // 10. School Science & STEM Subjects
    if (s.contains('physics')) {
      return const [
        _TopicData('Light: Reflection, Refraction & Optical Lenses', 'Ray Diagrams, Lens Formula, Magnification & Prisms', 0.85),
        _TopicData('Human Eye & Colourful World', 'Structure of Eye, Defects of Vision & Atmospheric Refraction', 0.65),
        _TopicData('Electricity & Ohm\'s Law', 'Electric Current, Potential Difference, Resistance & Joule Heating', 0.45),
        _TopicData('Magnetic Effects of Electric Current', 'Magnetic Field Lines, Right Hand Thumb Rule & Electric Motors', 0.25),
        _TopicData('Electromagnetic Induction & AC Circuits', 'Faraday\'s Law, Fleming\'s Right-Hand Rule & AC Generators', 0.10),
        _TopicData('Sources of Energy & Conservation', 'Renewable vs Non-renewable Energy & Solar/Nuclear Power', 0.0),
      ];
    }

    if (s.contains('chem')) {
      return const [
        _TopicData('Chemical Reactions & Balancing Equations', 'Types of Reactions, Oxidation-Reduction & Corrosion', 0.80),
        _TopicData('Acids, Bases and Salts', 'pH Scale, Indicators, Neutralization & Salts in Daily Life', 0.60),
        _TopicData('Metals, Non-Metals & Metallurgy', 'Physical/Chemical Properties, Reactivity Series & Extraction', 0.40),
        _TopicData('Carbon and its Compounds', 'Covalent Bonding, Hydrocarbons, Isomers & Soaps/Detergents', 0.20),
        _TopicData('Periodic Classification of Elements', 'Mendeleev vs Modern Periodic Table & Periodic Trends', 0.0),
        _TopicData('Environmental Chemistry & Pollution', 'Green Chemistry, Acid Rain & Greenhouse Effect', 0.0),
      ];
    }

    if (s.contains('bio')) {
      return const [
        _TopicData('Life Processes: Nutrition & Respiration', 'Autotrophic/Heterotrophic Modes & Aerobic/Anaerobic Pathways', 0.80),
        _TopicData('Circulation & Excretion in Humans', 'Heart Anatomy, Double Circulation, Nephrons & Dialysis', 0.60),
        _TopicData('Control and Coordination', 'Nervous System, Synapse, Brain Structure & Plant Hormones', 0.40),
        _TopicData('Reproduction in Animals & Plants', 'Asexual Modes, Flower Anatomy & Human Reproductive Health', 0.20),
        _TopicData('Heredity and Mendelian Genetics', 'Monohybrid/Dihybrid Crosses, Punnett Squares & Sex Determination', 0.0),
        _TopicData('Ecosystems & Environmental Conservation', 'Food Chains, Trophic Levels & Ozone Depletion', 0.0),
      ];
    }

    if (s.contains('math')) {
      return const [
        _TopicData('Real Numbers & Prime Factorization', 'Euclid Division Lemma, Fundamental Theorem of Arithmetic & Proofs', 0.85),
        _TopicData('Polynomials & Quadratic Equations', 'Zeroes of Polynomials, Factoring & Quadratic Formula Method', 0.70),
        _TopicData('Linear Equations in Two Variables', 'Graphical Method, Substitution, Elimination & Consistency', 0.50),
        _TopicData('Arithmetic Progressions (AP)', 'Finding nth Term, Sum of First n Terms & Word Problems', 0.35),
        _TopicData('Triangles & Similarity Theorems', 'Basic Proportionality Theorem (BPT) & Pythagoras Theorem', 0.20),
        _TopicData('Trigonometry & Heights/Distances', 'Trigonometric Ratios, Standard Values & Angle of Elevation', 0.10),
        _TopicData('Coordinate Geometry & Distance Formula', 'Section Formula, Centroid & Area of Triangles', 0.0),
        _TopicData('Circles, Tangents & Mensuration', 'Lengths of Tangents, Surface Areas & Volumes of Solids', 0.0),
        _TopicData('Statistics & Probability', 'Mean, Median, Mode of Grouped Data & Classical Probability', 0.0),
      ];
    }

    if (s.contains('english')) {
      return const [
        _TopicData('Reading Comprehension & Critical Analysis', 'Unseen Passages, Context Clues & Authorial Intent', 0.80),
        _TopicData('Grammar: Tenses, Modals & Voice', 'Active/Passive Voice, Reported Speech & Subject-Verb Agreement', 0.65),
        _TopicData('Formal Letter & Analytical Writing', 'Business Letters, Editor Letters & Analytical Paragraphs', 0.45),
        _TopicData('Vocabulary & Idiomatic Phrases', 'Collocations, Word Roots, Synonyms, Antonyms & Phrasal Verbs', 0.25),
        _TopicData('Literature: Prose & Narrative Analysis', 'Theme Exploration, Narrative Devices & Character Studies', 0.10),
        _TopicData('Poetry & Figurative Devices', 'Metaphors, Similes, Rhyme Scheme, Imagery & Symbolism', 0.0),
      ];
    }

    // 11. Social Studies / Humanities (ONLY when subject actually matches)
    if (s.contains('social') || s.contains('history') || s.contains('civic') || s.contains('geograph')) {
      return const [
        _TopicData('Rise of Nationalism in Europe & India', 'French Revolution, Non-Cooperation & Civil Disobedience', 0.75),
        _TopicData('Resources, Agriculture & Water Systems', 'Soil Classification, Major Crops & Water Conservation', 0.55),
        _TopicData('Democratic Politics & Power Sharing', 'Federalism, Decentralization, Gender, Religion & Caste', 0.35),
        _TopicData('Economic Development & Money/Credit', 'Sectors of Economy, Formal Credit & Globalisation', 0.20),
        _TopicData('Consumer Rights & Modern Governance', 'Consumer Protection Act & Public Distribution System', 0.0),
      ];
    }

    // 12. Primary School Subjects
    if (s.contains('environmental') || s.contains('evs')) {
      return const [
        _TopicData('My Family, Friends & Home', 'Relationships, Daily Habits & Helping Each Other', 0.85),
        _TopicData('Plants & Green Trees Around Us', 'Parts of a Plant, Leaves, Flowers & Caring for Nature', 0.65),
        _TopicData('Animals & Birds Safari', 'Domestic & Wild Animals, Animal Homes & Sounds', 0.45),
        _TopicData('Water, Seasons & Weather', 'Rainy Days, Sunny Days, Clean Drinking Water & Clouds', 0.25),
        _TopicData('Good Habits, Health & Cleanliness', 'Washing Hands, Brushing Teeth & Healthy Food Habits', 0.0),
      ];
    }

    if (s.contains('art') || s.contains('craft') || s.contains('color')) {
      return const [
        _TopicData('Rainbow & Primary Colors', 'Red, Yellow, Blue, Color Mixing & Identification', 0.85),
        _TopicData('Finger Painting & Scribble Art', 'Creative Hand Prints, Patterns & Fun Texture Art', 0.60),
        _TopicData('Origami & Paper Crafts', 'Folding Paper Boats, Planes, Fans & Hats', 0.40),
        _TopicData('Clay Modeling & Play-Dough', 'Rolling Beads, Animals, Fruits & 3D Sculptures', 0.20),
        _TopicData('Nature Craft & Collage Making', 'Leaf Rubbings, Dried Flower Art & Scrapbook Pages', 0.0),
      ];
    }

    // 13. Dynamic Fallback for any custom degree / standard subject
    return [
      _TopicData('$subject: Core Principles & Definitions', 'Foundational concepts and primary terminology', 0.80),
      _TopicData('$subject: Theoretical Architectures', 'Core building blocks, systems and structural flow', 0.60),
      _TopicData('$subject: Methods & Problem Solving', 'Key formulas, workflows and analytical techniques', 0.40),
      _TopicData('$subject: Practical Implementations', 'Real-world case studies, implementations and labs', 0.20),
      _TopicData('$subject: Advanced Analysis & Optimization', 'Edge cases, design trade-offs and best practices', 0.0),
      _TopicData('$subject: Comprehensive Exam Review', 'High-yield points, mock problems and key takeaways', 0.0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final topics = _topicsForSubject();

    final completed = topics.where((topic) => topic.progress >= 1).length;
    final inProgress = topics
        .where((topic) => topic.progress > 0 && topic.progress < 1)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          subject,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _buildHeader(topics.length, completed, inProgress),

            const SizedBox(height: 26),

            const Text(
              'Topics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            ...topics.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopicCard(
                  number: entry.key + 1,
                  topic: entry.value,
                  onTap: () {
                    _openTopic(context, entry.value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int total, int completed, int inProgress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total topics available',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Your overall progress',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _overallProgress(),
              minHeight: 9,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _StatItem(value: '$completed', label: 'Completed'),
              const SizedBox(width: 22),
              _StatItem(value: '$inProgress', label: 'In progress'),
              const SizedBox(width: 22),
              _StatItem(value: '$total', label: 'Total'),
            ],
          ),
        ],
      ),
    );
  }

  double _overallProgress() {
    final topics = _topicsForSubject();

    if (topics.isEmpty) return 0;

    final total = topics.fold<double>(0, (sum, topic) => sum + topic.progress);

    return total / topics.length;
  }

  void _openTopic(BuildContext context, _TopicData topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TopicLessonScreen(
          topic: topic.title,
          subject: subject,
        ),
      ),
    );
  }
}

class _TopicData {
  final String title;
  final String description;
  final double progress;

  const _TopicData(this.title, this.description, this.progress);
}

class _TopicCard extends StatelessWidget {
  final int number;
  final _TopicData topic;
  final VoidCallback onTap;

  const _TopicCard({
    required this.number,
    required this.topic,
    required this.onTap,
  });

  String get _status {
    if (topic.progress >= 1) return 'Completed';
    if (topic.progress > 0) return 'Continue';
    return 'Start';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      topic.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    if (topic.progress > 0) ...[
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: topic.progress,
                          minHeight: 5,
                          backgroundColor: AppColors.border,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                      color: topic.progress > 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
