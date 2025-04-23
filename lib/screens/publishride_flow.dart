import 'package:flutter/material.dart';
import 'publish/publish_screen.dart';
import 'publish/stopover_screen.dart';
import 'publish/places_screen.dart';
import 'publish/preferences_screen.dart';
import 'publish/confirmation_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PublishRideFlow extends StatefulWidget {
  @override
  _PublishRideFlowState createState() => _PublishRideFlowState();
}

class _PublishRideFlowState extends State<PublishRideFlow> {
  final PageController _controller = PageController();
  int currentPage = 0;

  final Color primaryColor = const Color(0xFF1B4242);

  // Stores user inputs from each step
  final Map<String, dynamic> rideData = {};

  void nextPage() {
    if (currentPage < 4) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage++);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentPage--);
    }
  }

  void submitRide() async {
    //*****************************lien*******************************



    final url = Uri.parse('https://your.api/endpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(rideData),

      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(rideData: rideData),
          ),
        );
      } else {
        // Handle server errors
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Publish Ride",
          style: TextStyle(
            color: Color(0xFF1B4242),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: LinearProgressIndicator(
              value: (currentPage + 1) / 5,
              backgroundColor: primaryColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 5,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                PublishScreen(
                  onNext: (publishData) {
                    rideData['publish'] = publishData;
                    nextPage();
                  },
                ),
                StopoverScreen(
                  startAddress: rideData['publish']?['address'] ?? 'No address',
                  endAddress: rideData['publish']?['destination'] ?? 'No destination',
                  onNext: (stopoverData) {
                    rideData['stopover'] = stopoverData;
                    nextPage();
                  },
                  onBack: previousPage,
                ),
                PlacesScreen(
                  onNext: (placesData) {
                    rideData['places'] = placesData;
                    nextPage();
                  },
                  onBack: previousPage,
                ),
                PreferencesScreen(
                  onSubmit: (preferencesData) {
                    rideData['preferences'] = preferencesData;
                    submitRide();
                  },
                  onBack: previousPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}