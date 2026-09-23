import 'package:cyber_blogs/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CyberBlogs());
}

class CyberBlogs extends StatelessWidget {
  const CyberBlogs({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(),
    );
  }
}
