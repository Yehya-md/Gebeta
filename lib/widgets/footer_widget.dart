import 'package:flutter/material.dart';
import '../constants/constants.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.defaultPadding,
      color: AppConstants.grey[200],
      child: Column(
        children: [
          Text(
            'Gebeta © 2025.',
            style: AppConstants.bodyText2,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
