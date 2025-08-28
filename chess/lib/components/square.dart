import 'package:flutter/material.dart';
import 'piece.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final bool isCheck;
  final void Function()? onTap;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.isCheck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else if (isCheck) {
      squareColor = Colors.red.shade400;
    } else {
      squareColor = isWhite ? Colors.grey[300] : Colors.grey[700];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: isValidMove ? const EdgeInsets.all(4) : EdgeInsets.zero,
        child: piece != null
            ? Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: piece,
          ),
        )
            : null,
      ),
    );
  }
}