import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'onboarding/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF030213),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(context, userProvider),
                
                const SizedBox(height: 24),
                
                // Preferences Section
                _buildPreferencesSection(context, userProvider),
                
                const SizedBox(height: 24),
                
                // App Settings Section
                _buildAppSettingsSection(context),
                
                const SizedBox(height: 24),
                
                // Support Section
                _buildSupportSection(context),
                
                const SizedBox(height: 24),
                
                // Account Actions
                _buildAccountActions(context, userProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserProvider userProvider) {
    final user = userProvider.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF030213),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF030213),
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Guest User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF030213),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'Not logged in',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF030213)),
                onPressed: () {
                  // Navigate to profile edit
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, UserProvider userProvider) {
    final user = userProvider.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF030213),
            ),
          ),
          const SizedBox(height: 16),
          _buildPreferenceTile(
            icon: Icons.person,
            title: 'Gender',
            subtitle: user?.gender ?? 'Not set',
            onTap: () => _showGenderDialog(context, userProvider),
          ),
          _buildPreferenceTile(
            icon: Icons.thermostat,
            title: 'Temperature Sensitivity',
            subtitle: user?.temperatureSensitivity.level ?? 'Normal',
            onTap: () => _showTemperatureSensitivityDialog(context, userProvider),
          ),
          _buildPreferenceTile(
            icon: Icons.style,
            title: 'Style Preferences',
            subtitle: '${user?.stylePreferences.length ?? 0} preferences set',
            onTap: () {
              // Navigate to style preferences
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF030213),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Weather alerts and recommendations',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
              activeColor: const Color(0xFF030213),
            ),
          ),
          _buildSettingTile(
            icon: Icons.location_on,
            title: 'Location Services',
            subtitle: 'For weather and recommendations',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle location toggle
              },
              activeColor: const Color(0xFF030213),
            ),
          ),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Handle dark mode toggle
              },
              activeColor: const Color(0xFF030213),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF030213),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            onTap: () {
              // Navigate to help
            },
          ),
          _buildActionTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: () {
              // Navigate to feedback
            },
          ),
          _buildActionTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF030213),
            ),
          ),
          const SizedBox(height: 16),
          if (userProvider.isLoggedIn) ...[
            _buildActionTile(
              icon: Icons.logout,
              title: 'Logout',
              titleColor: Colors.red,
              onTap: () => _showLogoutDialog(context, userProvider),
            ),
          ] else ...[
            _buildActionTile(
              icon: Icons.login,
              title: 'Login',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF030213)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF030213)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: trailing,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? const Color(0xFF030213)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? const Color(0xFF030213),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showGenderDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Male'),
              value: 'male',
              groupValue: userProvider.currentUser?.gender ?? 'male',
              onChanged: (value) {
                if (value != null) {
                  userProvider.updateGender(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Female'),
              value: 'female',
              groupValue: userProvider.currentUser?.gender ?? 'female',
              onChanged: (value) {
                if (value != null) {
                  userProvider.updateGender(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTemperatureSensitivityDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Temperature Sensitivity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Cold Sensitive'),
              subtitle: const Text('Feel cold easily'),
              value: 'low',
              groupValue: userProvider.currentUser?.temperatureSensitivity.level ?? 'normal',
              onChanged: (value) {
                if (value != null) {
                  userProvider.updateTemperatureSensitivity(
                    TemperatureSensitivity(
                      coldSensitivity: -0.5,
                      heatSensitivity: 0.0,
                      level: value,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Normal'),
              subtitle: const Text('Average sensitivity'),
              value: 'normal',
              groupValue: userProvider.currentUser?.temperatureSensitivity.level ?? 'normal',
              onChanged: (value) {
                if (value != null) {
                  userProvider.updateTemperatureSensitivity(
                    TemperatureSensitivity(
                      coldSensitivity: 0.0,
                      heatSensitivity: 0.0,
                      level: value,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Heat Sensitive'),
              subtitle: const Text('Feel hot easily'),
              value: 'high',
              groupValue: userProvider.currentUser?.temperatureSensitivity.level ?? 'normal',
              onChanged: (value) {
                if (value != null) {
                  userProvider.updateTemperatureSensitivity(
                    TemperatureSensitivity(
                      coldSensitivity: 0.0,
                      heatSensitivity: -0.5,
                      level: value,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              userProvider.logout();
              Navigator.of(context).pop();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'OOTD',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 OOTD App',
      children: [
        const Text('Optimal Outfit Tailored by Data'),
      ],
    );
  }
}
