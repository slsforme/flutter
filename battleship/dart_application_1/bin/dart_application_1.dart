import 'dart:io';
import 'dart:math';

class SeaBattleGame {
  final int size = 10;
  final Map<int, int> shipsLayout = {1: 4, 2: 3, 3: 2, 4: 1};
  List<List<String>> board1;
  List<List<String>> board2;
  List<List<int>> ships1 = [];
  List<List<int>> ships2 = [];
  List<List<int>> hits1 = [];
  List<List<int>> hits2 = [];
  bool playAgainstComputer = false;

  // Статистика
  int player1Hits = 0;
  int player1Misses = 0;
  int player2Hits = 0;
  int player2Misses = 0;

  SeaBattleGame()
      : board1 = List.generate(10, (_) => List.filled(10, '~')),
        board2 = List.generate(10, (_) => List.filled(10, '~'));

  void printBoard(List<List<String>> board) {
    print("   ${List.generate(size, (i) => i).join(" ")}");
    for (int i = 0; i < board.length; i++) {
      print("$i  ${board[i].join(" ")}");
    }
  }

  bool isHit(int x, int y, List<List<String>> opponentBoard, List<List<int>> hits, List<List<int>> opponentShips, int playerNum) {
    if (hits.any((hit) => hit[0] == x && hit[1] == y)) {
      print("Эта клетка уже обстреляна!");
      return false;
    }
    hits.add([x, y]);
    if (opponentBoard[x][y] == 'S') {
      print("Попадание!");
      opponentBoard[x][y] = 'X';
      opponentShips.removeWhere((pos) => pos[0] == x && pos[1] == y);
      if (playerNum == 1) {
        player1Hits++;
      } else {
        player2Hits++;
      }
      return true;
    } else {
      print("Мимо!");
      // Заменим тильду на звездочку при промахе
      opponentBoard[x][y] = '*';
      if (playerNum == 1) {
        player1Misses++;
      } else {
        player2Misses++;
      }
      return false;
    }
  }

  bool isGameOver(List<List<int>> ships) {
    return ships.isEmpty;
  }

  bool playerTurn(int playerNum, List<List<String>> board, List<List<int>> hits, List<List<String>> opponentBoard, List<List<int>> opponentShips) {
    print("Ход игрока $playerNum:");
    print("Доска игрока 1:");
    printBoard(board1);  // Отображение доски игрока 1
    print("Доска игрока 2:");
    printBoard(board2);  // Отображение доски игрока 2

    while (true) {
      try {
        stdout.write("Введите координаты для выстрела (строка колонка): ");
        List<int> coords = stdin.readLineSync()!.split(' ').map(int.parse).toList();
        int x = coords[0], y = coords[1];
        if (x >= 0 && x < size && y >= 0 && y < size) {
          return isHit(x, y, opponentBoard, hits, opponentShips, playerNum);
        } else {
          print("Координаты вне диапазона! Попробуйте снова.");
        }
      } catch (e) {
        print("Неверный ввод! Введите два числа.");
      }
    }
  }

  bool computerTurn() {
    Random random = Random();
    while (true) {
      int x = random.nextInt(size);
      int y = random.nextInt(size);
      if (!hits2.any((hit) => hit[0] == x && hit[1] == y)) {
        print("Компьютер стреляет в ($x, $y)");
        return isHit(x, y, board1, hits2, ships1, 2);
      }
    }
  }

  void saveStatistics(String winner) {
    final directory = Directory('game_results');
    if (!directory.existsSync()) {
      directory.createSync();
    }
    final file = File('${directory.path}/stats.txt');

    int player1ShipsLost = 20 - ships1.length;
    int player2ShipsLost = 20 - ships2.length;

    String stats = '''
Результат игры:
Победитель: $winner

Статистика игрока 1:
Попадания: $player1Hits
Промахи: $player1Misses
Потеряно кораблей: $player1ShipsLost
Оставшиеся корабли: ${ships1.length}

Статистика игрока 2:
Попадания: $player2Hits
Промахи: $player2Misses
Потеряно кораблей: $player2ShipsLost
Оставшиеся корабли: ${ships2.length}
''';

    file.writeAsStringSync(stats);
    print("Статистика сохранена в файл ${file.path}");
  }

  void setupShips(List<List<String>> board, List<List<int>> ships, String player) {
    while (true) {
      stdout.write("$player, выберите способ расстановки кораблей:\n1. Вручную\n2. Автоматически\nВаш выбор: ");
      String? choice = stdin.readLineSync();
      if (choice == '1') {
        setupShipsManual(board, ships);
        break;
      } else if (choice == '2') {
        setupShipsAuto(board, ships);
        break;
      } else {
        print("Некорректный ввод! Попробуйте снова.");
      }
    }
  }

  void placeShipManual(List<List<String>> board, int shipLength, List<List<int>> ships) {
    while (true) {
      try {
        print("Разместите корабль длиной $shipLength. Введите начальные координаты и направление.");
        stdout.write("Введите начальные координаты (строка колонка): ");
        List<int> coords = stdin.readLineSync()!.split(' ').map(int.parse).toList();
        int x = coords[0], y = coords[1];
        stdout.write("Введите направление (H - горизонтально, V - вертикально): ");
        String direction = stdin.readLineSync()!.toUpperCase();

        bool validPlacement = true;
        if (direction == 'H') {
          if (y + shipLength <= size && List.generate(shipLength, (i) => board[x][y + i] == '~').every((e) => e)) {
            for (int i = 0; i < shipLength; i++) {
              board[x][y + i] = 'S';
              ships.add([x, y + i]);
            }
            break;
          }
        } else if (direction == 'V') {
          if (x + shipLength <= size && List.generate(shipLength, (i) => board[x + i][y] == '~').every((e) => e)) {
            for (int i = 0; i < shipLength; i++) {
              board[x + i][y] = 'S';
              ships.add([x + i, y]);
            }
            break;
          }
        }
        print("Неправильное размещение! Попробуйте снова.");
      } catch (e) {
        print("Некорректный ввод! Пожалуйста, попробуйте снова.");
      }
    }
  }

  void setupShipsManual(List<List<String>> board, List<List<int>> ships) {
    print("Расставьте корабли на поле вручную.");
    shipsLayout.forEach((shipLength, count) {
      for (int i = 0; i < count; i++) {
        printBoard(board);
        placeShipManual(board, shipLength, ships);
      }
    });
  }

  void setupShipsAuto(List<List<String>> board, List<List<int>> ships) {
    Random random = Random();
    print("Автоматическая расстановка кораблей...");
    shipsLayout.forEach((shipLength, count) {
      for (int i = 0; i < count; i++) {
        bool placed = false;
        while (!placed) {
          int x = random.nextInt(size);
          int y = random.nextInt(size);
          bool isHorizontal = random.nextBool();

          if (isHorizontal && y + shipLength <= size &&
              List.generate(shipLength, (k) => board[x][y + k] == '~').every((e) => e)) {
            for (int k = 0; k < shipLength; k++) {
              board[x][y + k] = 'S';
              ships.add([x, y + k]);
            }
            placed = true;
          } else if (!isHorizontal && x + shipLength <= size &&
              List.generate(shipLength, (k) => board[x + k][y] == '~').every((e) => e)) {
            for (int k = 0; k < shipLength; k++) {
              board[x + k][y] = 'S';
              ships.add([x + k, y]);
            }
            placed = true;
          }
        }
      }
    });
    printBoard(board);
  }

  void startGame() {
    while (true) {
      stdout.write("Выберите режим:\n1. Игрок против игрока\n2. Игрок против компьютера\n3. Выйти\nВаш выбор: ");
      String? choice = stdin.readLineSync();
      if (choice == '1') {
        playAgainstComputer = false;
        break;
      } else if (choice == '2') {
        playAgainstComputer = true;
        break;
      } else if (choice == '3') {
        print("Выход из игры.");
        return;
      } else {
        print("Некорректный ввод! Попробуйте снова.");
      }
    }

    setupShips(board1, ships1, "Игрок 1");

    if (playAgainstComputer) {
      setupShipsAuto(board2, ships2);
    } else {
      setupShips(board2, ships2, "Игрок 2");
    }

    int currentPlayer = 1;
    while (true) {
      if (currentPlayer == 1) {
        if (playerTurn(1, board1, hits1, board2, ships2)) {
          if (isGameOver(ships2)) {
            print("Игрок 1 победил!");
            saveStatistics("Игрок 1");
            break;
          }
        }
        currentPlayer = 2;
      } else {
        if (playAgainstComputer) {
          if (computerTurn()) {
            if (isGameOver(ships1)) {
              print("Компьютер победил!");
              saveStatistics("Компьютер");
              break;
            }
          }
        } else {
          if (playerTurn(2, board2, hits2, board1, ships1)) {
            if (isGameOver(ships1)) {
              print("Игрок 2 победил!");
              saveStatistics("Игрок 2");
              break;
            }
          }
        }
        currentPlayer = 1;
      }
    }
  }
}

void main() {
  SeaBattleGame game = SeaBattleGame();
  game.startGame();
}
