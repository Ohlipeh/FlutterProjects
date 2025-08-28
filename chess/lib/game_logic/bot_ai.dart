import '../components/piece.dart';
import 'game_rules.dart';

class BotAI {
  final GameRules _gameRules = GameRules();

  // AVALIA A PONTUAÇÃO DO TABULEIRO
  // Pontuação positiva é boa para as Brancas.
  // Pontuação negativa é boa para as Pretas (o Bot).
  int _evaluateBoard(List<List<ChessPiece?>> board) {
    int totalScore = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        ChessPiece? piece = board[i][j];
        if (piece != null) {
          int pieceValue = _getPieceValue(piece.type);
          totalScore += piece.isWhite ? pieceValue : -pieceValue;
        }
      }
    }
    return totalScore;
  }

  // RETORNA O VALOR DE CADA PEÇA
  int _getPieceValue(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.pawn: return 10;
      case ChessPieceType.knight: return 30;
      case ChessPieceType.bishop: return 30;
      case ChessPieceType.rook: return 50;
      case ChessPieceType.queen: return 90;
      case ChessPieceType.king: return 900;
      default: return 0;
    }
  }

  // ALGORITMO MINIMAX
  // Ele explora recursivamente as jogadas futuras para encontrar a melhor.
  int _minimax(List<List<ChessPiece?>> board, int depth, bool isMaximizingPlayer, List<int> whiteKing, List<int> blackKing) {
    // Caso base: se a profundidade acabar ou o jogo terminar, retorna a pontuação.
    if (depth == 0 || _isGameOver(board, isMaximizingPlayer, whiteKing, blackKing)) {
      return _evaluateBoard(board);
    }

    if (isMaximizingPlayer) { // Vez das Brancas (tentam maximizar a pontuação)
      int maxEval = -99999;
      var moves = _getAllPossibleMoves(board, true, whiteKing, blackKing);
      for (var move in moves) {
        var simulatedBoard = _simulateMove(board, move);
        int eval = _minimax(simulatedBoard, depth - 1, false, whiteKing, blackKing);
        maxEval = max(maxEval, eval);
      }
      return maxEval;
    } else { // Vez das Pretas/Bot (tentam minimizar a pontuação)
      int minEval = 99999;
      var moves = _getAllPossibleMoves(board, false, whiteKing, blackKing);
      for (var move in moves) {
        var simulatedBoard = _simulateMove(board, move);
        int eval = _minimax(simulatedBoard, depth - 1, true, whiteKing, blackKing);
        minEval = min(minEval, eval);
      }
      return minEval;
    }
  }

  // FUNÇÃO PRINCIPAL PARA ENCONTRAR O MELHOR MOVIMENTO PARA O BOT
  List<int>? findBestMove(List<List<ChessPiece?>> board, List<int> whiteKing, List<int> blackKing) {
    List<int>? bestMove;
    int bestValue = 99999; // Bot quer o menor valor possível

    var moves = _getAllPossibleMoves(board, false, whiteKing, blackKing);
    for (var move in moves) {
      var simulatedBoard = _simulateMove(board, move);
      // A profundidade 2 é um bom começo. Aumentar pode deixar o bot mais lento.
      int moveValue = _minimax(simulatedBoard, 2, true, whiteKing, blackKing);
      if (moveValue < bestValue) {
        bestValue = moveValue;
        bestMove = move;
      }
    }
    return bestMove;
  }

  // Funções auxiliares para a IA
  List<List<int>> _getAllPossibleMoves(List<List<ChessPiece?>> board, bool isWhite, List<int> whiteKing, List<int> blackKing) {
    final List<List<int>> allMoves = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        ChessPiece? piece = board[i][j];
        if (piece != null && piece.isWhite == isWhite) {
          var moves = _gameRules.calculateRawValidMoves(i, j, piece, board);
          for (var move in moves) {
            // Simula para ver se o movimento é seguro
            var simulatedBoard = _simulateMove(board, [i, j, move[0], move[1]]);
            if (!_gameRules.isKingInCheck(simulatedBoard, isWhite)) {
              allMoves.add([i, j, move[0], move[1]]);
            }
          }
        }
      }
    }
    return allMoves;
  }

  List<List<ChessPiece?>> _simulateMove(List<List<ChessPiece?>> board, List<int> move) {
    List<List<ChessPiece?>> newBoard = List.generate(8, (r) => List.from(board[r]));
    int startRow = move[0], startCol = move[1], endRow = move[2], endCol = move[3];
    newBoard[endRow][endCol] = newBoard[startRow][startCol];
    newBoard[startRow][startCol] = null;
    return newBoard;
  }

  bool _isGameOver(List<List<ChessPiece?>> board, bool isWhiteTurn, List<int> whiteKing, List<int> blackKing) {
    return _getAllPossibleMoves(board, isWhiteTurn, whiteKing, blackKing).isEmpty;
  }

  int max(int a, int b) => a > b ? a : b;
  int min(int a, int b) => a < b ? a : b;
}