import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_care/constants/color.dart';
import 'package:travel_care/pages/gradient_button.dart';
import 'package:travel_care/pages/homescreen.dart';

final pallatte = Pallatte();



class FlightStatus extends StatefulWidget {
  const FlightStatus({super.key});

  @override
  State<FlightStatus> createState() => _FlightStatusState();
}

class _FlightStatusState extends State<FlightStatus> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _departureDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();

  bool _removeDepartureBorder = false;
  bool _removeArrivalBorder = false;
  bool _removeDepartureDateControllerBorder = false;
  bool _removeReturnDateBorder = false;
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
  List<Map<String, dynamic>> _flightDetails = [];
  int _currentIndex = 0;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

      setState(() {
        if (controller == _departureDateController) {
          _departureDateController.text = formattedDate;
        } else if (controller == _returnDateController) {
          DateTime? departureDate = DateFormat('dd-MM-yyyy').parseStrict(_departureDateController.text, true);
  
            _returnDateController.text = formattedDate;
          }
        
      });

      
    }
  }

  Future<void> _saveData() async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('flight_status').add({
      'departure': _departureController.text,
      'arrival': _arrivalController.text,
      'start_date': _departureDateController.text,
      'return_date': _returnDateController.text.isEmpty ? null : _returnDateController.text,
      'timestamp': FieldValue.serverTimestamp(),
    }).catchError((e) {
      print("Error saving data: $e");
    });
  }

  Future<void> _fetchData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore.collection('flight_status').get();
      final fetchedDetails = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        _flightDetails = [];
        const List<String> times = [
          '06:00 - 08:00',
          '08:00 - 10:00',
          '10:00 - 12:00',
          '12:00 - 14:00',
          '14:00 - 16:00',
          '16:00 - 18:00',
          '18:00 - 20:00',
          '20:00 - 22:00'
        ];

        for (var flight in fetchedDetails) {
          if (flight['departure'] == _departureController.text &&
              flight['arrival'] == _arrivalController.text) {

            if (_returnDateController.text.isEmpty) {
              // Only Departure Date is entered
              for (var time in times) {
                _flightDetails.add({
                  'departure': flight['departure'],
                  'arrival': flight['arrival'],
                  'start_date': flight['start_date'],
                  'return_date': null,
                  'airport': 'Abc International Airport',
                  'airline': 'Akasa Air',
                  'time': time,
                  'type': 'departure',
                });
              }
            } else {
              // Both Departure and Return Dates are entered
              for (var time in times) {
                _flightDetails.add({
                  'departure': flight['departure'],
                  'arrival': flight['arrival'],
                  'start_date': flight['start_date'],
                  'return_date': null,
                  'airport': 'Abc International Airport',
                  'airline': 'Akasa Air',
                  'time': time,
                  'type': 'departure',
                });

                _flightDetails.add({
                  'departure': flight['arrival'],
                  'arrival': flight['departure'],
                  'start_date': _returnDateController.text,
                  'return_date': null,
                  'airport': 'XYZ International Airport',
                  'airline': 'Akasa Air',
                  'time': time,
                  'type': 'return',
                });
              }
            }
          }
        }

        if (_flightDetails.isEmpty) {
          _flightDetails.add({
            'departure': 'No flights available',
            'arrival': '',
            'start_date': '',
            'return_date': null,
            'airport': '',
            'airline': '',
            'time': '',
            'type': 'none',
          });
        }
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _removeReturnDate() {
    setState(() {
      _returnDateController.clear();
      _flightDetails.removeWhere((flight) => flight['type'] == 'return');
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isDelayedTime(String time) {
    return time == '08:00 - 10:00' || time == '12:00 - 14:00' || time == '14:00 - 16:00' || time == '18:00 - 20:00';
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
                  'Flight Status',
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
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
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
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _departureController,
                          onTap: () {
                            setState(() {
                              _removeDepartureBorder = true;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: _removeDepartureBorder ? InputBorder.none : null,
                            labelText: _removeDepartureBorder ? null : '  Departure*',
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _arrivalController,
                          onTap: () {
                            setState(() {
                              _removeArrivalBorder = true;
                            });
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: _removeArrivalBorder ? InputBorder.none : null,
                            labelText: _removeArrivalBorder ? null : '  Arrival*',
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
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
                            controller: _departureDateController,
                            onTap: () => _selectDate(context, _departureDateController),
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Departure Date*',
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Stack(
                        children: [
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
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _returnDateController,
                                onTap: () => _selectDate(context, _returnDateController),
                                readOnly: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Return Date',
          
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _removeReturnDate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(15,0,15,0),
                child: GradientButton(
                  buttonText: 'Search',
                  onPressed: () async {
                    // Validation check
                    if (_departureController.text.isEmpty ||
                        _arrivalController.text.isEmpty ||
                        _departureDateController.text.isEmpty) {
                      _showErrorDialog('Please fill in all required fields.');
                      return;
                    }
                        
                    
                        
                    setState(() {
                      _isLoading = true;
                    });
                        
                    await _fetchData();
                        
                    setState(() {
                      _isLoading = false;
                      _hasGenerated = true;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              _hasGenerated
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _flightDetails.length,
                        itemBuilder: (context, index) {
                          final flight = _flightDetails[index];
        
                          if (flight['type'] == 'none') {
                            return Center(child: Text(flight['departure']));
                          }
        
                          final String time = flight['time'];
                          final bool isDelayed = _isDelayedTime(time);
        
                          return Card(
                            color: isDelayed ? const Color.fromARGB(255, 255, 173, 173) : Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 100,
                                    width: 100,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${flight['departure']} -> ${flight['arrival']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Airline: ${flight['airline']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Date: ${flight['start_date']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Time: ${flight['time']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Airport: ${flight['airport']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        if (isDelayed)
                                          const SizedBox(height: 10),
                                        if (isDelayed)
                                          const Text(
                                            'Note: This flight may be delayed by 1-2 hours.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(255, 255, 0, 0),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      }
    ),
  );
}
}