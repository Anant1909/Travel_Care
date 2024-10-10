import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/homescreen.dart';
import 'package:travel_care/provider.dart';

final pallatte = Pallatte();
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Itinerary Suggestions',
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
          builder: (context) =>  const Homescreen(),
        ));
                  },
                  );
                  },
                  ),
        centerTitle: true,
      ),
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
            child: Consumer<ItineraryProvider>(
              builder: (context, provider, child) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('itineraries')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Lottie.asset(
                                      'assets/animation/loading1.json',
                                      height: 80,
                                      width: 80,
                                    ),
                      );
                    }
          
                    final itineraries = snapshot.data!.docs;
          
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      provider.setItineraries(itineraries);
                    });
          
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        itemCount: itineraries.length,
                        itemBuilder: (context, index) {
                          final itinerary = itineraries[index];
                          final imageUrl = itinerary['imageUrl'] as String;
                          final startDateStr = itinerary['startDate'] as String;
                          final endDateStr = itinerary['endDate'] as String;
          
                          
                          final startDateTime = DateTime.parse(startDateStr);
                          final endDateTime = DateTime.parse(endDateStr);
          
                          
                          final difference = endDateTime.difference(startDateTime).inDays;
          
                          return GestureDetector(
                            onTap: () {
                              _showItineraryDialog(context, itinerary['itinerary']);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.zero,
                                    bottomRight: Radius.circular(20),
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.zero,
                                  ),
                                ),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            itinerary['location'],
                                            style: const TextStyle(
                                              fontFamily: 'NerkoOne',
                                              color: Colors.white,
                                              fontSize: 50,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            'Days: $difference',
                                            style: const TextStyle(
                                              fontFamily: 'NerkoOne',
                                              color: Colors.white,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.white),
                                            onPressed: () {
                                              provider.deleteItinerary(itinerary.id);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      ),
    );
  }

  void _showItineraryDialog(BuildContext context, String itinerary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 247, 240, 229),
          title: const Text('Itinerary'),
          content: SingleChildScrollView(
            child: Text(itinerary),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
