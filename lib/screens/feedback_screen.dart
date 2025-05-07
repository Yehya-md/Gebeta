import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _feedbackController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Feedback', style: TextStyle(color: Color(0xFF4B0082))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_feedbackController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback submitted!')));
                  _feedbackController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B0082)),
              child: const Text('Submit Feedback',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
