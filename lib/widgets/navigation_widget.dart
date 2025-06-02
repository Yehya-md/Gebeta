import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../routes/router.dart';

class NavigationWidget extends StatelessWidget {
  final int currentIndex;
  final bool showProfile;

  const NavigationWidget({
    super.key,
    required this.currentIndex,
    this.showProfile = true,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == 2) {
      AppRouter.navigateTo(context, AppRouter.contribution, replace: true);
      return;
    }

    switch (index) {
      case 0:
        AppRouter.navigateTo(context, AppRouter.home, replace: true);
        break;
      case 1:
        AppRouter.navigateTo(context, AppRouter.recipes, replace: true);
        break;
      case 3:
        AppRouter.navigateTo(context, AppRouter.search, replace: true);
        break;
      case 4:
        AppRouter.navigateTo(
            context, showProfile ? AppRouter.about : AppRouter.about,
            replace: true);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: AppConstants.iconSize),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_dining, size: AppConstants.iconSize),
              label: 'Recipes',
            ),
            const BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: AppConstants.iconSize),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info, size: AppConstants.iconSize),
              label: 'About',
            ),
          ],
          currentIndex: currentIndex,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: AppConstants.grey,
          onTap: (index) => _onItemTapped(context, index),
          type: BottomNavigationBarType.fixed,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0), // Adjust FAB position
          child: FloatingActionButton(
            onPressed: () {
              AppRouter.navigateTo(context, AppRouter.contribution,
                  replace: true);
            },
            backgroundColor: AppConstants.primaryColor,
            child: Icon(Icons.add,
                size: AppConstants.fabIconSize, color: AppConstants.white),
            elevation: 6.0,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}
