import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/homescreen.dart';

final pallatte = Pallatte();
class ImageService {
  final String _apiKey = 'AIzaSyDtquRflpVYBQQV1PJxq7EqjDgZp9exSH8';
  final String _searchEngineId = 'b02a2216396244498';

  Future<List<String>> fetchImages(String query) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/customsearch/v1?q=$query&cx=$_searchEngineId&key=$_apiKey&searchType=image'),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final items = result['items'] as List;
      return items.map<String>((item) => item['link'] as String).toList();
    } else {
      throw Exception('Failed to generate itinerary');
    }
  }
}


class ItineraryService {
  final GenerativeModel _model;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ItineraryService(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

  Future<String?> generateAndStoreItinerary(String location, String startDate, String endDate) async {
    final prompt = "Generate a travel itinerary for $location from $startDate to $endDate.";

    final response = await _model.generateContent(
      [Content.text(prompt)],
    );

    if (response.error != null) {
      throw Exception('Failed to generate itinerary: ${response.error!.message}');
    }

    final itinerary = response.text;
    if (itinerary != null) {
      final imageService = ImageService();
      final images = await imageService.fetchImages(location);
      final imageUrl = images.isNotEmpty ? images[0] : '';

      await _firestore.collection('itineraries').add({
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'itinerary': itinerary,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    return itinerary;
  }
}

extension on GenerateContentResponse {
  get error => null;
}

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> with SingleTickerProviderStateMixin{
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  String _itinerary = '';
  List<String> _images = [];
  bool _removeLocationBorder = false;
  bool _removeStartDateBorder = false;
  bool _removeEndDateBorder = false;
  bool _hasGenerated = false;
  bool _isLoading = false;
@override
  void initState() {
    
    super.initState();
    _controller = AnimationController(vsync: this,duration: const Duration(seconds: 6));
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.topRight), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.bottomRight), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end:Alignment.bottomLeft), 
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end:Alignment.topLeft), 
        weight: 1,
        )
      ],
      ).animate(_controller);

  _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end:Alignment.bottomLeft),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end:Alignment.topLeft),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end:Alignment.topRight),
        weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topRight, end:Alignment.bottomRight),
        weight: 1,
        )
      ],
      ).animate(_controller);

      _controller.repeat();
  }
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _getItineraryAndImages() async {
    setState(() {
      _isLoading = true;
    });

    final itineraryService = ItineraryService('AIzaSyAmZ-D4pjxQMgo8KpwBU2F2_Y2rhiX6ziQ');
    final imageService = ImageService();
    final location = _locationController.text;
    final startDate = _startDateController.text;
    final endDate = _endDateController.text;

    try {
      final itinerary = await itineraryService.generateAndStoreItinerary(location, startDate, endDate);
      final images = await imageService.fetchImages(location);

      setState(() {
        _itinerary = itinerary ?? 'No itinerary found';
        _images = images;
        _hasGenerated = true;
      });
    } catch (e) {
      setState(() {
        _itinerary = 'Error: $e';
        _images = [];
        _hasGenerated = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context,_) {
          return Container(
            decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:_topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: [pallatte.backgroundColor1, pallatte.backgroundColor2],
                  ),
                ),
            child: Column(
              children: <Widget>[
                AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'Itinerary Generator',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFE4B5),
                    ),
                  ),
                          leading: Builder(
                builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFFFFE4B5),
                onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ));
                  },
                  );
                  },
                  ),
                ),
                            const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(15.0),
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
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _locationController,
                        onTap: () {
                          setState(() {
                            _removeLocationBorder = true;
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: _removeLocationBorder ? InputBorder.none : null,
                          labelText: _removeLocationBorder ? null : '  Location',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
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
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _startDateController,
                              readOnly: true,
                              onTap: () => _selectDate(context, _startDateController),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: _removeStartDateBorder ? InputBorder.none : null,
                                labelText: _removeStartDateBorder ? null : ' Start Date',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'To',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFE4B5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
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
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _endDateController,
                              readOnly: true,
                              onTap: () => _selectDate(context, _endDateController),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: _removeEndDateBorder ? InputBorder.none : null,
                                labelText: _removeEndDateBorder ? null : ' End Date',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                  child: GradientButton(buttonText: 'Generate Itinerary', onPressed: _getItineraryAndImages),
                ),
                const SizedBox(height: 20),
                if (_isLoading) ...[
                  Center(
                    child: Lottie.asset(
                                  'assets/animation/loading1.json',
                                  height: 80,
                                  width: 80,
                                ),
                  ),
                ] else ...[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            if (_hasGenerated) ...[
                              Container(
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
            padding: const EdgeInsets.all(12.0),
            child: MarkdownBody(
              data: _itinerary,
              styleSheet: MarkdownStyleSheet(
                h2: const TextStyle(
                  fontFamily: 'Nato Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color.fromARGB(255, 16, 0, 109),
                ),
                p: const TextStyle(
                  fontFamily: 'Nato Sans',
                  fontSize: 16,
                  color: Color.fromARGB(255, 16, 0, 109),
                ),
                strong: const TextStyle(
                  fontFamily: 'Nato Sans',
                  fontWeight: FontWeight.bold,
                ),
                listBullet: const TextStyle(
                  fontFamily: 'Nato Sans',
                  fontSize: 16,
                  color: Color.fromARGB(255, 16, 0, 109),
                ),
              ),
            ),
          ),
        ),
                              const SizedBox(height: 20),
                              for (String imageUrl in _images) Image.network(imageUrl),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
      ),
    );
  }
}
