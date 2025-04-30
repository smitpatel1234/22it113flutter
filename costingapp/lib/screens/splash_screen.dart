import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation using implicit animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              builder: (context, double value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: const Icon(Icons.inventory, size: 120, color: Colors.blue),
            ),
            const SizedBox(height: 30),
            // Text with fade-in animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              builder: (context, double value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: const Text(
                'SmartFab Industries',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
