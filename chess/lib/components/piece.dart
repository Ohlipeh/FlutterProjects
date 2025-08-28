import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece extends StatelessWidget {
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;

  const ChessPiece({
    super.key,
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      imagePath,
      fit: BoxFit.contain,
    );
  }
}