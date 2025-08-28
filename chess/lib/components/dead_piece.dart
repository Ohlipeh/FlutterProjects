import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;

  const DeadPiece({
    super.key,
    required this.imagePath,
    required this.isWhite,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Tamanho menor para peças capturadas
      width: 30,
      child: SvgPicture.asset(
        imagePath,
      ),
    );
  }
}