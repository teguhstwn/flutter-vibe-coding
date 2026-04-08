import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/');
            },
          ),
        ),
        body: ListView(
          children: [
            // Menu: Theme Settings
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDarkMode = themeMode == ThemeMode.dark;
                return SwitchListTile(
                  title: const Text('Mode Gelap (Dark Mode)'),
                  subtitle: Text(isDarkMode ? 'Nonaktifkan untuk Mode Terang' : 'Aktifkan untuk Mode Gelap'),
                  secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  value: isDarkMode,
                  onChanged: (bool value) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                );
              },
            ),
            const Divider(),
            
            // Menu: About App
            ListTile(
              title: const Text('Tentang Aplikasi'),
              subtitle: const Text('Informasi versi dan pengelolanya'),
              leading: const Icon(Icons.info_outline),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Flutter Vibe Coding',
                  applicationVersion: '1.0.0+1',
                  applicationIcon: const FlutterLogo(size: 40),
                  applicationLegalese: 'Copyright © 2024 Vibe Coding Team\nDeveloped with Antigravity AI',
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Aplikasi ini adalah demonstrasi pengembangan cepat menggunakan Flutter dan AI.'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
