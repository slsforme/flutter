import 'dart:io';
import 'dart:math';
import 'package:logging/logging.dart';

// Constants
final LOG = Logger('logger');
final random = Random();

int exception_handler(String _prompt) {
  while (true) {
    try {
      stdout.write(_prompt);
      String? input = stdin.readLineSync();
      int size = int.parse(input!);
      if (size < 3 || size > 9) {
        print("Данное число не входит в заданный диапазон (3-9).");
      } else {
        return size;
      }
    } catch (e) {
      LOG.severe('Error while entering number: $e');
      print('Вы неправильно ввели значение. Пожалуйста, введите целое число.');
    }
  }
}

void print_field(List<List<dynamic>> field) {
  stdout.write("  ");
  for (var colIndex = 1; colIndex <= field[0].length; colIndex++) {
    stdout.write('$colIndex '); 
  }
  print('\n'); 

  for (var rowIndex = 0; rowIndex < field.length; rowIndex++) {
    stdout.write('${rowIndex + 1} '); 
    print(field[rowIndex].join(' ')); 
  }
}

List<int> move_handler(int width, int height, List<List<dynamic>> field, bool is_X_turn) {
  while (true) {
    try {
      stdout.write('Введите два целых числа через пробел: ');
      String? input = stdin.readLineSync();

      if (input != null) {
        List<String> parts = input.split(' ');
        int h = int.parse(parts[0]);
        int w = int.parse(parts[1]);

        // Validating move
        if (!(1 <= h && h <= height) || !(1 <= w && w <= width)) {
          print('Значение вне пределов игрового поля. Попробуйте ещё раз.');
          continue;
        }

        if (field[h - 1][w - 1] != '.') {
          print("Данная клетка уже занята значением ${field[h - 1][w - 1]}. Выберите другую клетку.");
          continue;
        }

        return [h, w];
      } else {
        print('Введите целые числа через пробел!');      
      }
    } catch (e) {
      LOG.severe('Error while entering numbers: $e');
      print("Вы неправильно ввели значение. Пожалуйста, введите целые числа через пробел.");
    }
  }
}

List<int> robot_move(int width, int height, List<List<String>> field, bool isXTurn) {
  var random = Random();
  List<List<int>> availableMoves = [];

  for (int r = 0; r < height; r++) {
    for (int c = 0; c < width; c++) {
      if (field[r][c] == '.') {
        availableMoves.add([r + 1, c + 1]); 
      }
    }
  }

  if (availableMoves.isNotEmpty) {
    List<int> move = availableMoves[random.nextInt(availableMoves.length)];
    field[move[0] - 1][move[1] - 1] = isXTurn ? 'X' : 'O';
    return move; 
  } 
  return [];
}

void commit_move(List<List<String>> field, List<int>? pos, bool is_X_turn) {
  if (pos != null) {
    if (is_X_turn) {
      field[pos[0] - 1][pos[1] - 1] = 'X';
    } else {
      field[pos[0] - 1][pos[1] - 1] = 'O';
    }
  }
  print_field(field);
}

bool check_winner(List<List<String>> field) {
  for (var row in field) {
    if (row.toSet().length == 1 && row[0] != '.') {
      return true;
    }
  }

  int height = field.length;
  int width = field[0].length;

  for (int c = 0; c < width; c++) {
    Set<String> columnSet = {};
    for (int r = 0; r < height; r++) {
      columnSet.add(field[r][c]);
    }
    if (columnSet.length == 1 && columnSet.first != '.') {
      return true;
    }
  }

  Set<String> mainDiagonalSet = {};
  for (int i = 0; i < height; i++) {
    mainDiagonalSet.add(field[i][i]);
  }
  if (mainDiagonalSet.length == 1 && mainDiagonalSet.first != '.') {
    return true;
  }

  Set<String> antiDiagonalSet = {};
  for (int i = 0; i < height; i++) {
    antiDiagonalSet.add(field[i][height - 1 - i]);
  }
  if (antiDiagonalSet.length == 1 && antiDiagonalSet.first != '.') {
    return true;
  }

  return false; 
}

bool is_draw(List<List<String>> field) {
  for (var row in field) {
    for (var cell in row) {
      if (cell == '.') {
        return false; // If there's at least one empty cell, the game is not a draw
      }
    }
  }
  return true; // If all cells are filled, the game is a draw
}

void start_game() {
  bool is_X_turn;
  int choice;
  while (true) {
    try {
      stdout.write('Как вы хотите играть?\n1. Против другого игрока\n2. Против робота\n3. Я хочу выйти\n');
      String? input = stdin.readLineSync();
      choice = int.parse(input!);
      if (choice == 1) {
        is_X_turn = random.nextBool(); 
        break;
      } else if (choice == 2) {
        is_X_turn = true;  // X всегда будет ходить первым против робота
        break;
      } else if (choice == 3) {
        print('Спасибо за игру.');
        exit(0);
      } else {
        print("Недопустимый выбор. Пожалуйста, выберите 1, 2 или 3.");
      }
    } catch (e) {
      LOG.severe('Error while entering number: $e');
      print("Вы неправильно ввели значение. Пожалуйста, введите целое число.");
    }
  }

  int width = exception_handler('Введите ширину поля (3-9): \n');
  int height = exception_handler('Введите длину поля (3-9): \n');

  print("Начинаем игру на поле размером $width x $height!");
  
  var field = List.generate(height, (i) => List.generate(width, (j) => '.'));
  print_field(field);

  while (true) {
    List<int>? pos;

    if (choice == 1) {
      // Player vs Player
      pos = move_handler(width, height, field, is_X_turn);
    } else if (choice == 2) {
      // Player vs Robot
      pos = move_handler(width, height, field, is_X_turn);
      commit_move(field, pos, is_X_turn);
      if (check_winner(field)) {
        print(is_X_turn ? "Игрок X победил!" : "Робот победил!");
        regenerate_game();
        break; 
      }

      if (is_draw(field)) {
        print('Ничья!');
        regenerate_game();
        break;
      }

      is_X_turn = !is_X_turn; // Switch turns after player's move
      pos = robot_move(width, height, field, is_X_turn);
      print("Робот делает ход: ${pos[0]} ${pos[1]}");
    }

    commit_move(field, pos, is_X_turn);

    if (check_winner(field)) {
      print(is_X_turn ? "Игрок X победил!" : "Робот победил!");
      regenerate_game();
      break; 
    }

    if (is_draw(field)) {
      print('Ничья!');
      regenerate_game();
      break;
    }

    is_X_turn = !is_X_turn;
  }
}

void regenerate_game() {
  while (true) {
    try {
      stdout.write('Хотите повторить игру или выйти?\n1. Продолжить\n2. Выйти из игры\n');
      String? input = stdin.readLineSync();
      int choice = int.parse(input!);
      if (choice == 1) {
        start_game();  // Restart game
        return;
      } else if (choice == 2) {
        print('Спасибо за игру!');
        exit(0);
      } else {
        print('Недопустимый выбор. Пожалуйста, выберите 1 или 2.');
      }
    } catch (e) {
      LOG.severe('Error while entering number: $e');
      print('Вы неправильно ввели значение. Пожалуйста, введите целое число.');
    }
  }
}

void main(List<String> arguments) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  start_game();
}
