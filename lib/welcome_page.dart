import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/handai-logo-filled.svg', width: 100),
            const SizedBox(height: 20),
            SvgPicture.asset('assets/handai-text.svg', width: 200),
          ],
        ),
      ),
    );
  }
}
