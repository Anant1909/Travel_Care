import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ItineraryProvider with ChangeNotifier {
  List<DocumentSnapshot> _itineraries = [];

  List<DocumentSnapshot> get itineraries => _itineraries;

  void setItineraries(List<DocumentSnapshot> newItineraries) {
    _itineraries = newItineraries;
    notifyListeners();
  }

  Future<void> deleteItinerary(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('itineraries').doc(documentId).delete();
      _itineraries.removeWhere((itinerary) => itinerary.id == documentId);
      notifyListeners();
    } catch (e) {
      // Handle errors
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
