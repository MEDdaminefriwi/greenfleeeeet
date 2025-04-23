import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;
  final VoidCallback onBack;

  const PreferencesScreen({
    required this.onSubmit,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF1B4242);

  String? _chatPreference;
  String? _smokingPreference;
  String? _musicPreference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Preferences"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    'Plan Your Dream Trip',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildPreferenceGroup(
                    icon: Icons.chat_bubble_outline,
                    title: "Chattiness",
                    groupValue: _chatPreference,
                    options: [
                      "I love to chat",
                      "I'm chatty when I feel comfortable",
                      "I'm the quiet type",
                    ],
                    onChanged: (val) => setState(() => _chatPreference = val),
                  ),
                  _buildPreferenceGroup(
                    icon: Icons.smoking_rooms_outlined,
                    title: "Smoking",
                    groupValue: _smokingPreference,
                    options: [
                      "I'm fine with smoking",
                      "Cigarette breaks outside the car are ok",
                      "No smoking, please",
                    ],
                    onChanged: (val) => setState(() => _smokingPreference = val),
                  ),
                  _buildPreferenceGroup(
                    icon: Icons.music_note_outlined,
                    title: "Music",
                    groupValue: _musicPreference,
                    options: [
                      "It's all about the playlist!",
                      "I'll jam depending on the mood",
                      "Silence is golden",
                    ],
                    onChanged: (val) => setState(() => _musicPreference = val),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_chatPreference != null &&
                          _smokingPreference != null &&
                          _musicPreference != null) {
                        final preferencesData = {
                          'chatPreference': _chatPreference!,
                          'smokingPreference': _smokingPreference!,
                          'musicPreference': _musicPreference!,
                        };
                        widget.onSubmit(preferencesData); // Pass preferences data to onSubmit
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select all preferences')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceGroup({
    required IconData icon,
    required String title,
    required String? groupValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: primaryColor),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...options.map((option) {
              return RadioListTile<String>(
                value: option,
                groupValue: groupValue,
                onChanged: onChanged,
                title: Text(option),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}