import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/footer_widget.dart';
import '../widgets/navigation_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor, // Use Scaffold background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: AppConstants.defaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: AppConstants.headline1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: AppConstants.cardBorderRadius,
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: AppConstants.defaultPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gebeta App',
                              style: AppConstants.headline3,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Welcome to Gebeta App! Discover a wide variety of recipes from around the world, including special Habesha dishes. Save your favorite recipes, contribute your own, and explore culinary traditions with ease.',
                              style: AppConstants.bodyText1,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Version',
                              style: AppConstants.headline3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1.0.0',
                              style: AppConstants.bodyText1,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Developed By',
                              style: AppConstants.headline3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'yehya, nuredin and fuad',
                              style: AppConstants.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const FooterWidget(),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationWidget(
        currentIndex: 4,
        showProfile: false,
      ),
    );
  }
}
