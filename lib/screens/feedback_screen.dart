import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/navigation_widget.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate() && _rating > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback submitted! Thank you.'),
          duration: Duration(seconds: 2),
        ),
      );
      _feedbackController.clear();
      setState(() {
        _rating = 0;
      });
    } else if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Feedback'),
        backgroundColor: AppConstants.white,
        elevation: 0,
        titleTextStyle: AppConstants.headline2,
      ),
      body: Container(
        color: AppConstants.backgroundColor,
        padding: AppConstants.defaultPadding,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We value your feedback! Let us know how we can improve.',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rate your experience:',
                  style: AppConstants.headline3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Your Feedback',
                    labelStyle: TextStyle(color: AppConstants.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                      borderSide: BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: AppConstants.white,
                      padding: AppConstants.buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppConstants.buttonBorderRadius,
                      ),
                    ),
                    child: Text(
                      'Submit Feedback',
                      style: AppConstants.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavigationWidget(currentIndex: 4),
    );
  }
}
