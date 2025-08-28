import '../components/piece.dart';

class GameRules {
  // VERIFICA SE O REI ESTÁ EM XEQUE
  bool isKingInCheck(List<List<ChessPiece?>> board, bool isWhiteKing) {
    // Encontra a posição do rei
    List<int> kingPosition = findKing(board, isWhiteKing);
    int kingRow = kingPosition[0];
    int kingCol = kingPosition[1];

    // Verifica se alguma peça inimiga pode atacar o rei
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        ChessPiece? piece = board[i][j];
        if (piece == null || piece.isWhite == isWhiteKing) {
          continue; // Pula casas vazias e peças da mesma cor
        }

        List<List<int>> validMoves = calculateRawValidMoves(i, j, piece, board);
        for (var move in validMoves) {
          if (move[0] == kingRow && move[1] == kingCol) {
            return true; // Rei está em xeque
          }
        }
      }
    }
    return false; // Rei não está em xeque
  }

  // ENCONTRA A POSIÇÃO DO REI NO TABULEIRO
  List<int> findKing(List<List<ChessPiece?>> board, bool isWhiteKing) {
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        var piece = board[i][j];
        if (piece != null &&
            piece.type == ChessPieceType.king &&
            piece.isWhite == isWhiteKing) {
          return [i, j];
        }
      }
    }
    // Deveria ser inalcançável se o rei estiver sempre no tabuleiro
    return [-1, -1];
  }

  // GERA TODOS OS MOVIMENTOS VÁLIDOS PARA UMA PEÇA
  List<List<int>> calculateRawValidMoves(
      int row, int col, ChessPiece? piece, List<List<ChessPiece?>> board) {
    List<List<int>> candidateMoves = [];
    if (piece == null) return [];

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
      // Movimento para frente
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // Movimento duplo inicial
        if ((row == 6 && piece.isWhite) || (row == 1 && !piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        // Captura diagonal
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        var directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];
        candidateMoves.addAll(_getSlidingPieceMoves(row, col, piece, board, directions));
        break;
      case ChessPieceType.bishop:
        var directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
        candidateMoves.addAll(_getSlidingPieceMoves(row, col, piece, board, directions));
        break;
      case ChessPieceType.queen:
        var directions = [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [-1, 1], [1, -1], [1, 1]];
        candidateMoves.addAll(_getSlidingPieceMoves(row, col, piece, board, directions));
        break;
      case ChessPieceType.knight:
        var knightMoves = [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]];
        for (var move in knightMoves) {
          var nextRow = row + move[0];
          var nextCol = col + move[1];
          if (!isInBoard(nextRow, nextCol)) continue;
          var blockingPiece = board[nextRow][nextCol];
          if (blockingPiece == null || blockingPiece.isWhite != piece.isWhite) {
            candidateMoves.add([nextRow, nextCol]);
          }
        }
        break;
      case ChessPieceType.king:
        var kingMoves = [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [-1, 1], [1, -1], [1, 1]];
        for (var move in kingMoves) {
          var nextRow = row + move[0];
          var nextCol = col + move[1];
          if (!isInBoard(nextRow, nextCol)) continue;
          var blockingPiece = board[nextRow][nextCol];
          if (blockingPiece == null || blockingPiece.isWhite != piece.isWhite) {
            candidateMoves.add([nextRow, nextCol]);
          }
        }
        break;
    }
    return candidateMoves;
  }

  // NOVA FUNÇÃO AUXILIAR para peças que deslizam (Torre, Bispo, Rainha)
  List<List<int>> _getSlidingPieceMoves(int row, int col, ChessPiece piece,
      List<List<ChessPiece?>> board, List<List<int>> directions) {
    List<List<int>> moves = [];
    for (var d in directions) {
      var i = 1;
      while (true) {
        var nextRow = row + i * d[0];
        var nextCol = col + i * d[1];
        if (!isInBoard(nextRow, nextCol)) {
          break; // Fora do tabuleiro
        }
        var blockingPiece = board[nextRow][nextCol];
        if (blockingPiece == null) {
          moves.add([nextRow, nextCol]); // Casa vazia
        } else {
          if (blockingPiece.isWhite != piece.isWhite) {
            moves.add([nextRow, nextCol]); // Pode capturar peça inimiga
          }
          break; // Caminho bloqueado por qualquer peça
        }
        i++;
      }
    }
    return moves;
  }

  // VERIFICA SE A POSIÇÃO ESTÁ DENTRO DO TABULEIRO
  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }
}
