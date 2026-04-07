import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter Vibe Coding',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Clean Architecture',
              style: GoogleFonts.outfit(fontSize: 24),
            ),
            const SizedBox(height: 16),
            const Text(
              'Project initialized with Bloc, GetIt, Hive, and GoRouter.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
