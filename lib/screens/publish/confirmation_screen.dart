import 'package:flutter/material.dart';
import '/screens/home_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> rideData;

  const ConfirmationScreen({Key? key, required this.rideData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1B4242);
    final lightBackground = const Color(0xFFF6F6F6);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "Ride Confirmation",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF1B4242), size: 100),
            const SizedBox(height: 16),
            Text(
              "Ride Published Successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              icon: Icons.map_outlined,
              title: "Route Details",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("From", rideData['publish']?['address']),
                  const Divider(),
                  _buildDetailRow(
                    "Stopover",
                    (rideData['stopover'] as List?)?.map((e) => e['address']).join(', ') ?? "No stopovers",
                  ),
                  const Divider(),
                  _buildDetailRow("To", rideData['publish']?['destination']),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              icon: Icons.directions_car,
              title: "Trip Details",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Date & Time", rideData['publish']?['dateTime']),
                  const Divider(),
                  _buildDetailRow("Car", rideData['publish']?['car']),
                  const Divider(),
                  _buildDetailRow("Places", "${rideData['places']?['places']} passengers"),
                  const Divider(),
                  _buildDetailRow(
                    "Preferences",
                    "Chat: ${rideData['preferences']?['chatPreference'] ?? 'N/A'}, "
                        "Smoking: ${rideData['preferences']?['smokingPreference'] ?? 'N/A'}, "
                        "Music: ${rideData['preferences']?['musicPreference'] ?? 'N/A'}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home_rounded),
                label: const Text("Go to Home", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) =>  HomeScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value ?? "N/A", style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
