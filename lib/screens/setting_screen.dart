import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../state/favorites_state.dart';
import '../widgets/navigation_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Amharic'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setString('language', _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppConstants.white,
        elevation: 0,
        titleTextStyle: AppConstants.headline2,
      ),
      body: Container(
        color: AppConstants.backgroundColor,
        padding: AppConstants.defaultPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personalize your Gebeta experience.',
                style: TextStyle(
                  fontSize: 18,
                  color: AppConstants.grey,
                ),
              ),
              const SizedBox(height: 24),
              // Theme Toggle
              ListTile(
                title: Text('Dark Mode', style: AppConstants.headline3),
                subtitle: Text(
                  'Switch between light and dark themes.',
                  style: TextStyle(color: AppConstants.grey),
                ),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    // TODO: Update theme via ThemeProvider
                    // Example: Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
                  },
                  activeColor: AppConstants.primaryColor,
                ),
              ),
              const Divider(),
              // Notifications
              ListTile(
                title: Text('Notifications', style: AppConstants.headline3),
                subtitle: Text(
                  'Enable or disable push notifications.',
                  style: TextStyle(color: AppConstants.grey),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    // TODO: Update notification settings
                  },
                  activeColor: AppConstants.primaryColor,
                ),
              ),
              const Divider(),
              // Language Selection
              ListTile(
                title: Text('Language', style: AppConstants.headline3),
                subtitle: Text(
                  'Select your preferred language.',
                  style: TextStyle(color: AppConstants.grey),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedLanguage,
                  items: _languages.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                    }
                  },
                  style: TextStyle(color: AppConstants.primaryColor),
                  underline: Container(),
                ),
              ),
              const Divider(),
              // Clear Favorites
              ListTile(
                title: Text('Clear Favorites', style: AppConstants.headline3),
                subtitle: Text(
                  'Remove all favorited recipes.',
                  style: TextStyle(color: AppConstants.grey),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: AppConstants.errorColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Favorites'),
                        content: const Text(
                          'Are you sure you want to remove all favorited recipes?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: AppConstants.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Favorites cleared.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              'Clear',
                              style: TextStyle(color: AppConstants.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _saveSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: AppConstants.white,
                    padding: AppConstants.buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppConstants.buttonBorderRadius,
                    ),
                  ),
                  child: Text(
                    'Save Settings',
                    style: AppConstants.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavigationWidget(currentIndex: 3),
    );
  }
}
