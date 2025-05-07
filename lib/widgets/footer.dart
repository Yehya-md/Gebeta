import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(FontAwesomeIcons.facebook, size: 20, color: Colors.grey),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.instagram, size: 20, color: Colors.grey),
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.twitter, size: 20, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
        const Text("Gebeta © 2025",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 20),
      ],
    );
  }
}
