import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';

final pallatte = Pallatte();

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _solution;
  bool _removeFocusedBorder = false;
  late AnimationController _controller1;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  bool _showSolution = false;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 6),
    );

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller1);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller1);

    _controller1.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ask your query!',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFE4B5),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFFFFE4B5),
          onPressed: () {
            Navigator.of(context).pop(); // Pop back to previous screen
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller1,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
                colors: [
                  pallatte.backgroundColor1,
                  pallatte.backgroundColor2
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        // Input Container for question
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            15.0, 150.0, 15.0, 8.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 247, 240, 229),
                              border: Border.all(),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                topRight: Radius.zero,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 0.0, 0.0),
                              child: TextField(
                                controller: _controller,
                                onTap: () {
                                  setState(() {
                                    _removeFocusedBorder = true;
                                  });
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: _removeFocusedBorder
                                      ? InputBorder.none
                                      : null,
                                  labelText: _removeFocusedBorder
                                      ? null
                                      : 'Enter text to get a solution',
                                ),
                                maxLines: 4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Button to Get Solution
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GradientButton(
                            buttonText: 'Get Answer',
                            onPressed: _getSolution,
                          ),
                        ),

                        // Loading indicator
                        if (_isLoading)
                          const CircularProgressIndicator(color: Colors.white,),

                        // Solution Container
                        if (_showSolution && _solution != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 247, 240, 229),
                              border: Border.all(),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.zero,
                                bottomRight: Radius.circular(20),
                                topLeft: Radius.circular(20),
                                topRight: Radius.zero,
                              ),
                            ),
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _solution ?? 'No solution found',
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 16, 0, 109),
                                ),
                                textAlign: TextAlign.center,
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
        },
      ),
    );
  }

  // Function to get the solution from the generative AI model
  void _getSolution() async {
    final solutionService =
        SolutionService('AIzaSyAimIwyysOj4Tq4Rj2ODdUtq56zrC6mV-c'); 
    final text = _controller.text;

    setState(() {
      _isLoading = true;
      _solution = '';
      _showSolution = false;
    });

    try {
      final solution = await solutionService.generatesolution(text);

      setState(() {
        _solution = solution ?? 'No solution found';
        _showSolution = true;
      });
    } catch (e) {
      setState(() {
        _solution = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    super.dispose();
  }
}

class SolutionService {
  final GenerativeModel _model;

  SolutionService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  Future<String?> generatesolution(String text) async {
    final prompt = 'Provide the best solution for: $text';

    try {
      final response = await _model.generateContent(
        [Content.text(prompt)],
      );

      if (response.error != null) {
        throw Exception(
            'Failed to solve your problem: ${response.error!.message}');
      }

      return response.text;
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }
}

extension on GenerateContentResponse {
  get error => null;
}
