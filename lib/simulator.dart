import 'dart:math';

import 'package:flutter/material.dart';

enum CellType {
  NONE,
  SAND,
  SAND_GENERATOR,
  WATER,
  WATER_GENERATOR,
  STEAM,
  PLANT,
  FIRE,
}

extension MaterialColor on CellType {
  Color get color {
    switch (this) {
      case CellType.NONE:
        return Colors.black;
      case CellType.SAND:
        return Colors.orange;
      case CellType.WATER:
        return Colors.blueAccent;
      case CellType.STEAM:
        return Colors.white54;
      case CellType.SAND_GENERATOR:
        return Colors.orange[100];
      case CellType.PLANT:
        return Colors.green;
      case CellType.WATER_GENERATOR:
        return Colors.blue;
      case CellType.FIRE:
        return Colors.amberAccent;
      default:
        return Colors.amberAccent;
    }
  }
}

extension MaterialName on CellType {
  String get name {
    switch (this) {
      case CellType.NONE:
        return 'Empty';
      case CellType.SAND:
        return 'Sand';
      case CellType.WATER:
        return 'Water';
      case CellType.STEAM:
        return 'Steam';
      case CellType.SAND_GENERATOR:
        return 'Sand generator';
      case CellType.PLANT:
        return 'Plant';
      case CellType.WATER_GENERATOR:
        return 'Water generator';
      case CellType.FIRE:
        return 'Fire';
      default:
        return '';
    }
  }
}

class Simulator {
  var _board;
  int width;
  int height;
  Random _random;

  Simulator(int width, int height) {
    this.width = width;
    this.height = height;
    _random = Random();
    _board = List.generate(
        width, (i) => List.generate(height, (j) => CellType.NONE));
  }

  void tick(int ticks) {
    var random = Random();
    for (int i = 0; i < ticks; i++) {
      int x = random.nextInt(width);
      int y = random.nextInt(height);
      check(x, y);
    }
  }

  void check(int x, int y) {
    switch (_board[x][y]) {
      case CellType.SAND:
        doSand(x, y);
        break;
      case CellType.SAND_GENERATOR:
        doGenerator(x, y, CellType.SAND);
        break;
      case CellType.WATER:
        doWater(x, y);
        break;
      case CellType.WATER_GENERATOR:
        doGenerator(x, y, CellType.WATER);
        break;
      case CellType.PLANT:
        doPlant(x, y);
        break;
      case CellType.FIRE:
        doFire(x, y);
        break;
      case CellType.STEAM:
        doSteam(x, y);
        break;
    }
  }

  void doSteam(int x, int y) {
    if (isEmpty(x, y - 1) || isFluid(x, y - 1)) {
      swap(x, y, x, y - 1);
    } else if (_random.nextInt(100) < 50) {
      if (!checkGasRight(x, y) && !checkGasLeft(x, y)) {
        checkCondensation(x, y);
      }
    } else if (!checkGasLeft(x, y) && !checkGasRight(x, y)) {
      checkCondensation(x, y);
    }
  }

  bool checkGasRight(int x, int y) {
    for (int i = x + 1; i < width; i++) {
      if (isEmpty(i, y - 1) || isFluid(i, y - 1)) {
        swap(x, y, i, y + -1);
        return true;
      }
    }
    return false;
  }

  void checkCondensation(int x, int y) {
    if (_random.nextInt(1000) < 5) {
      _board[x][y] = CellType.WATER;
    }
  }

  bool checkGasLeft(int x, int y) {
    for (int i = x - 1; i >= 0; i--) {
      if (isEmpty(i, y + -1) || isFluid(i, y - 1)) {
        swap(x, y, i, y + -1);
        return true;
      }
    }
    return false;
  }

  void doFire(int x, int y) {
    if (test(x, y + 1, CellType.PLANT)) {
      _board[x][y + 1] = CellType.FIRE;
    }
    if (test(x + 1, y + 1, CellType.PLANT)) {
      _board[x + 1][y + 1] = CellType.FIRE;
    }
    if (test(x + 1, y, CellType.PLANT)) {
      _board[x + 1][y] = CellType.FIRE;
    }
    if (test(x + 1, y - 1, CellType.PLANT)) {
      _board[x + 1][y - 1] = CellType.FIRE;
    }
    if (test(x, y - 1, CellType.PLANT)) {
      _board[x][y - 1] = CellType.FIRE;
    }
    if (test(x - 1, y - 1, CellType.PLANT)) {
      _board[x - 1][y - 1] = CellType.FIRE;
    }
    if (test(x - 1, y, CellType.PLANT)) {
      _board[x - 1][y] = CellType.FIRE;
    }
    if (test(x - 1, y + 1, CellType.PLANT)) {
      _board[x - 1][y + 1] = CellType.FIRE;
    }
    _board[x][y] = CellType.NONE;
    if (test(x, y - 1, CellType.WATER)) {
      _board[x][y - 1] = CellType.STEAM;
    }
  }

  void doWater(int x, int y) {
    if (_random.nextInt(100) < 50) {
      return;
    }
    if (isEmpty(x, y + 1)) {
      swap(x, y, x, y + 1);
      return;
    }
    if (_random.nextInt(100) < 50) {
      if (!checkFluidRight(x, y)) {
        checkFluidLeft(x, y);
      }
    } else {
      if (!checkFluidLeft(x, y)) {
        checkFluidRight(x, y);
      }
    }
  }

  void doSand(int x, int y) {
    if (canMove(x, y + 1)) {
      swap(x, y, x, y + 1);
    } else if (canMove(x + 1, y + 1)) {
      swap(x, y, x + 1, y + 1);
    } else if (canMove(x - 1, y + 1)) {
      swap(x, y, x - 1, y + 1);
    }
  }

  bool checkFluidLeft(int x, int y) {
    for (int i = x - 1; i >= 0; i--) {
      if (!isEmpty(i, y) && !isGas(i, y)) {
        return false;
      }
      if (isEmpty(i, y + 1) || isGas(i, y + 1)) {
        swap(x, y, i, y + 1);
        return true;
      }
    }
    return false;
  }

  bool checkFluidRight(int x, int y) {
    for (int i = x + 1; i < width; i++) {
      if (!isEmpty(i, y) && !isGas(i, y)) {
        return false;
      }
      if (isEmpty(i, y + 1) || isGas(i, y + 1)) {
        swap(x, y, i, y + 1);
        return true;
      }
    }
    return false;
  }

  void swap(int x, int y, int nextX, int nextY) {
    CellType value = _board[x][y];
    _board[x][y] = _board[nextX][nextY];
    _board[nextX][nextY] = value;
  }

  bool canMove(int x, int y) {
    return isEmpty(x, y) || isFluid(x, y);
  }

  bool isGas(int x, int y) {
    return test(x, y, CellType.STEAM);
  }

  bool isFluid(int x, int y) {
    return test(x, y, CellType.WATER);
  }

  bool test(int x, int y, CellType material) {
    if (x >= width || x < 0 || y >= height || y < 0) {
      return false;
    }
    return _board[x][y] == material;
  }

  bool inBounds(int x, int y) {
    return x < width && x >= 0 && y < height && y >= 0;
  }

  bool isEmpty(int x, int y) {
    if (!inBounds(x, y)) {
      return false;
    }

    return _board[x][y] == CellType.NONE;
  }

  CellType getCellType(int x, int y) {
    return _board[x][y];
  }

  void doGenerator(int x, int y, CellType type) {
    if (isEmpty(x, y + 1) || canMove(x, y + 1)) {
      _board[x][y + 1] = type;
    }
  }

  void setMaterial(int x, int y, CellType type) {
    if (!inBounds(x, y)) {
      return;
    }
    _board[x][y] = type;
  }

  void doPlant(int x, int y) {
    if (testWater(x, y + 1)) {
      _board[x][y + 1] = CellType.PLANT;
    } else if (testWater(x + 1, y + 1)) {
      _board[x + 1][y + 1] = CellType.PLANT;
    } else if (testWater(x + 1, y)) {
      _board[x + 1][y] = CellType.PLANT;
    } else if (testWater(x + 1, y - 1)) {
      _board[x + 1][y - 1] = CellType.PLANT;
    } else if (testWater(x, y - 1)) {
      _board[x][y - 1] = CellType.PLANT;
    } else if (testWater(x - 1, y - 1)) {
      _board[x - 1][y - 1] = CellType.PLANT;
    } else if (testWater(x - 1, y)) {
      _board[x - 1][y] = CellType.PLANT;
    } else if (testWater(x - 1, y + 1)) {
      _board[x - 1][y + 1] = CellType.PLANT;
    }
  }

  bool testWater(int x, int y) {
    return test(x, y, CellType.WATER) || test(x, y, CellType.WATER_GENERATOR);
  }
}
