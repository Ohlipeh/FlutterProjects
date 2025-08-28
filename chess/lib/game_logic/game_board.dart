import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import '../components/dead_piece.dart';
import '../components/piece.dart';
import '../components/square.dart';
import 'bot_ai.dart';
import 'game_rules.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;
  final GameRules _gameRules = GameRules();
  final BotAI _botAI = BotAI();

  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool isCheck = false;
  final List<ChessPiece> whitePiecesTaken = [];
  final List<ChessPiece> blackPiecesTaken = [];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(8, (_) => List.generate(8, (_) => null));
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: 'images/bP.svg');
      newBoard[6][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true, imagePath: 'images/wP.svg');
    }
    newBoard[0][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'images/bR.svg');
    newBoard[0][7] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'images/bR.svg');
    newBoard[7][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'images/wR.svg');
    newBoard[7][7] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'images/wR.svg');
    newBoard[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'images/bN.svg');
    newBoard[0][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'images/bN.svg');
    newBoard[7][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'images/wN.svg');
    newBoard[7][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'images/wN.svg');
    newBoard[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'images/bB.svg');
    newBoard[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'images/bB.svg');
    newBoard[7][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'images/wB.svg');
    newBoard[7][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'images/wB.svg');
    newBoard[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: 'images/bQ.svg');
    newBoard[7][3] = ChessPiece(type: ChessPieceType.queen, isWhite: true, imagePath: 'images/wQ.svg');
    newBoard[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: 'images/bK.svg');
    newBoard[7][4] = ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: 'images/wK.svg');
    board = newBoard;
  }

  void squareTapped(int row, int col) {
    if (!isWhiteTurn) return;
    setState(() {
      if (selectedPiece == null) {
        if (board[row][col] != null && board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
          validMoves = _calculateRealValidMoves(row, col, selectedPiece, true);
        }
      } else {
        bool isMoveValid = validMoves.any((move) => move[0] == row && move[1] == col);
        if (isMoveValid) {
          movePiece(row, col);
        } else {
          var tappedPiece = board[row][col];
          if (tappedPiece != null && tappedPiece.isWhite == isWhiteTurn) {
            selectedPiece = tappedPiece;
            selectedRow = row;
            selectedCol = col;
            validMoves = _calculateRealValidMoves(row, col, selectedPiece, true);
          } else {
            _resetSelection();
          }
        }
      }
    });
  }

  List<List<int>> _calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> rawValidMoves = _gameRules.calculateRawValidMoves(row, col, piece, board);
    if (checkSimulation) {
      for (var move in rawValidMoves) {
        if (_simulatedMoveIsSafe(piece!, row, col, move[0], move[1])) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = rawValidMoves;
    }
    return realValidMoves;
  }

  bool _simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    List<List<ChessPiece?>> simulatedBoard = List.generate(8, (r) => List.from(board[r]));
    simulatedBoard[endRow][endCol] = piece;
    simulatedBoard[startRow][startCol] = null;
    return !_gameRules.isKingInCheck(simulatedBoard, piece.isWhite);
  }

  void movePiece(int newRow, int newCol) async {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol]!;
      setState(() {
        if (capturedPiece.isWhite) {
          whitePiecesTaken.add(capturedPiece);
        } else {
          blackPiecesTaken.add(capturedPiece);
        }
      });
    }
    ChessPiece movedPiece = selectedPiece!;
    board[newRow][newCol] = movedPiece;
    board[selectedRow][selectedCol] = null;
    if (movedPiece.type == ChessPieceType.king) {
      if (movedPiece.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }
    if (movedPiece.type == ChessPieceType.pawn && (newRow == 0 || newRow == 7)) {
      await _showPawnPromotionDialog(newRow, newCol);
    }
    isCheck = _gameRules.isKingInCheck(board, !isWhiteTurn);
    isWhiteTurn = !isWhiteTurn;
    _resetSelection();
    if (_isGameOver()) {
      _showGameOverDialog();
      return;
    }
    if (!isWhiteTurn) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _makeBotMove();
      });
    }
  }

  void _makeBotMove() {
    var bestMove = _botAI.findBestMove(board, whiteKingPosition, blackKingPosition);
    if (bestMove != null) {
      setState(() {
        selectedPiece = board[bestMove[0]][bestMove[1]];
        selectedRow = bestMove[0];
        selectedCol = bestMove[1];
        movePiece(bestMove[2], bestMove[3]);
      });
    }
  }

  Future<void> _showPawnPromotionDialog(int row, int col) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Promover Peão"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPromotionButton(context, row, col, ChessPieceType.queen),
            _buildPromotionButton(context, row, col, ChessPieceType.rook),
            _buildPromotionButton(context, row, col, ChessPieceType.bishop),
            _buildPromotionButton(context, row, col, ChessPieceType.knight),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionButton(BuildContext context, int row, int col, ChessPieceType type) {
    bool isWhite = (row == 0);
    String imagePath = "";
    String pieceName = "";
    switch (type) {
      case ChessPieceType.queen: imagePath = isWhite ? 'images/wQ.svg' : 'images/bQ.svg'; pieceName = "Rainha"; break;
      case ChessPieceType.rook: imagePath = isWhite ? 'images/wR.svg' : 'images/bR.svg'; pieceName = "Torre"; break;
      case ChessPieceType.bishop: imagePath = isWhite ? 'images/wB.svg' : 'images/bB.svg'; pieceName = "Bispo"; break;
      case ChessPieceType.knight: imagePath = isWhite ? 'images/wN.svg' : 'images/bN.svg'; pieceName = "Cavalo"; break;
      default: break;
    }
    return TextButton(
      child: Row(children: [SvgPicture.asset(imagePath, width: 40, height: 40), const SizedBox(width: 10), Text(pieceName)]),
      onPressed: () {
        setState(() { board[row][col] = ChessPiece(type: type, isWhite: isWhite, imagePath: imagePath); });
        Navigator.of(context).pop();
      },
    );
  }

  bool _isGameOver() {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        ChessPiece? piece = board[i][j];
        if (piece != null && piece.isWhite == isWhiteTurn) {
          if (_calculateRealValidMoves(i, j, piece, true).isNotEmpty) return false;
        }
      }
    }
    return true;
  }

  void _showGameOverDialog() {
    String title;
    if (_gameRules.isKingInCheck(board, isWhiteTurn)) {
      title = isWhiteTurn ? "Xeque-mate! Pretas Venceram." : "Xeque-mate! Brancas Venceram.";
    } else {
      title = "Empate por Rei Afogado!";
    }
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [TextButton(onPressed: () { _resetGame(); Navigator.of(context).pop(); }, child: const Text("Jogar Novamente"))],
      ),
    );
  }

  void _resetSelection() {
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];
  }

  void _resetGame() {
    setState(() {
      _initializeBoard();
      isWhiteTurn = true;
      isCheck = false;
      whiteKingPosition = [7, 4];
      blackKingPosition = [0, 4];
      whitePiecesTaken.clear();
      blackPiecesTaken.clear();
      _resetSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      // 1. SafeArea evita que o app fique embaixo da barra de status ou notch do celular
      body: SafeArea(
        child: Column(
          children: [
            // Área de peças capturadas (Cemitério do Bot)
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: blackPiecesTaken.map((piece) {
                  return BounceInDown(
                    duration: const Duration(milliseconds: 500),
                    child: DeadPiece(
                      imagePath: piece.imagePath,
                      isWhite: piece.isWhite,
                    ),
                  );
                }).toList(),
              ),
            ),

            // 2. Expanded faz esta área central (tabuleiro e textos) ocupar todo o espaço disponível
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCheck)
                    FadeInDown(child: const Text("XEQUE!", style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold))),
                  Text(isWhiteTurn ? "Sua Vez (Brancas)" : "Vez do Bot (Pretas)", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // 3. AspectRatio garante que o tabuleiro seja sempre um quadrado que ocupe a largura da tela
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: GridView.builder(
                      itemCount: 64,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                      itemBuilder: (context, index) {
                        int row = index ~/ 8;
                        int col = index % 8;
                        bool isWhiteSquare = (row + col) % 2 == 0;
                        bool isSelected = row == selectedRow && col == selectedCol;
                        bool isValidMove = validMoves.any((move) => move[0] == row && move[1] == col);
                        bool isKingInCheckSquare = (isWhiteTurn && row == whiteKingPosition[0] && col == whiteKingPosition[1]) ||
                            (!isWhiteTurn && row == blackKingPosition[0] && col == blackKingPosition[1]);
                        return Square(
                          isWhite: isWhiteSquare,
                          piece: board[row][col],
                          isSelected: isSelected,
                          isValidMove: isValidMove,
                          isCheck: isCheck && isKingInCheckSquare,
                          onTap: () => squareTapped(row, col),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Área de peças capturadas (Seu cemitério)
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: whitePiecesTaken.map((piece) {
                  return BounceInDown(
                    duration: const Duration(milliseconds: 500),
                    child: DeadPiece(
                      imagePath: piece.imagePath,
                      isWhite: piece.isWhite,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

