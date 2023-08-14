// Grid Dimentions
import 'package:flutter/material.dart';

int rowLength = 10;
int colLength = 15;


enum Direction {
  left,
  right,
  down,
}

enum Tetromino {
  L,
  J,
  I,
  O,
  S,
  Z,
  T,
}



const Map<Tetromino, Color>tetrominoColors ={
  Tetromino.L: Color(0xFFFFA500), //Orange
    Tetromino.J: Color.fromARGB(255, 0, 102, 255),//BLue
  Tetromino.I: Colors.brown,//Brown
  Tetromino.O: Color(0xFFFFFF00), //Yellow
  Tetromino.S: Colors.green, //green
  Tetromino.Z: Colors.red, //Red
  Tetromino.T: Colors.purple, //Purple


};
