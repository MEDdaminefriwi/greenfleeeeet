import 'package:flutter/material.dart';
import 'location_picker_screen.dart';

class PublishScreen extends StatefulWidget {
  final Function(Map<String, String>) onNext;

  const PublishScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  String? address;
  String? destination;
  String? dateTime;
  String? car;

  final Color primaryColor = const Color(0xFF1B4242);
  final Color accentColor = const Color(0xFF4FBDBA);

  Future<void> _handleMapSelection(String label) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(title: 'Select $label'),
      ),
    );

    if (result != null && result is Map && result['address'] != null) {
      setState(() {
        if (label == 'Address') address = result['address'];
        if (label == 'Destination') destination = result['address'];
      });
    }
  }

  Future<void> _showInputDialog(String label) async {
    if (label == 'Address' || label == 'Destination') {
      await _handleMapSelection(label);
      return;
    }

    if (label == 'Car') {
      final cars = [
        'Hyundai Grand i10',
        'Kia Picanto',
        'Kia Rio',
        'Golf 5',
        'Golf 6',
        'Golf 7',
        'Golf 8',
        'x6',
        'Clio Bombé',
        'Autre',
      ];

      final selectedCar = await showModalBottomSheet<String>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: cars
              .map(
                (carName) => ListTile(
              title: Text(carName),
              leading: const Icon(Icons.directions_car),
              onTap: () => Navigator.pop(context, carName),
            ),
          )
              .toList(),
        ),
      );

      if (selectedCar != null) {
        setState(() {
          car = selectedCar;
        });
      }
      return;
    }

    if (label == 'Date & Time') {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          final formattedDateTime =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')} • ${pickedTime.format(context)}";
          setState(() {
            dateTime = formattedDateTime;
          });
        }
      }
    }
  }

  Widget _buildField(String label, String? value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () => _showInputDialog(label),
        child: Row(
          children: [
            Icon(_getIcon(label), color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value ?? 'Tap to select $label',
                style: TextStyle(
                  fontSize: 16,
                  color: value != null ? Colors.black : Colors.grey,
                  fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String label) {
    switch (label) {
      case 'Address':
        return Icons.home_rounded;
      case 'Destination':
        return Icons.flag_rounded;
      case 'Date & Time':
        return Icons.calendar_month_rounded;
      case 'Car':
        return Icons.directions_car_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text("Publish Ride"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildField('Address', address),
              _buildField('Destination', destination),
              _buildField('Date & Time', dateTime),
              _buildField('Car', car),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final publishData = {
                      'address': address ?? 'No address',
                      'destination': destination ?? 'No destination',
                      'dateTime': dateTime ?? 'No dateTime',
                      'car': car ?? 'No car',
                    };
                    widget.onNext(publishData);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded,color: Colors.white),
                  label: const Text(
                    "Continue",
                    style: TextStyle(

                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
