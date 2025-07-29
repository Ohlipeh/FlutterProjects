import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 3),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_basket_rounded,
          size: size * 0.6,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }
}