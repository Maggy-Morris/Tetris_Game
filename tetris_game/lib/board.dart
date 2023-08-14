import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris_game/piece.dart';
import 'package:tetris_game/pixel.dart';
import 'package:tetris_game/values.dart';

//create Game Board
List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(rowLength, (j) => null),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.L);
  int currentScore = 0;

  //game over status
  bool gameOver = false;
  @override
  void initState() {
    super.initState();

    //start game when app starts
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();
    //Frame refresh rate

    Duration frameRate = const Duration(milliseconds: 200);
    gameLoop(frameRate);
  }

//Gmae Loop
  void gameLoop(Duration frameRate) {
    Timer.periodic(
      frameRate,
      (timer) {
        setState(() {
          //Clear Lines
          clearLines();
          //check landing
          checkLanding();

          //check if game is over
          if (gameOver == true) {
            timer.cancel();
            showGameOverDialog();
          }

          //Move current piece down
          currentPiece.movePiece(Direction.down);
        });
      },
    );
  }

  //Game Over Message
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score is :$currentScore'),
        actions: [
          TextButton(
              onPressed: () {
                //reset the game
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again')),
        ],
      ),
    );
  }

  //reset game
  void resetGame() {
    //clear the game board
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(
        rowLength,
        (i) => null,
      ),
    );

    //new game
    gameOver = false;
    currentScore = 0;

    //create new Piece
    createNewPiece();

    //start game again
    startGame();
  }

// check for collision in future position
// return true -> there is collision
// return false -> there is no collision
  bool checkCollision(Direction direction) {
    //loop through each positon of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      //calculate the row and column of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      //adjust the row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }
      // check if the pieces is out of bounds (either too low or too far to the left or right)
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }
    }
    //if no collisions re detected
    return false;
  }

  void checkLanding() {
    //if going down is occupied
    if (checkCollision(Direction.down) || checkLanded()) {
      //mark position as occupied on the gameboard
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      //once landed , create the next piece
      createNewPiece();
    }
  }

  bool checkLanded() {
    //loop through each position of the current position
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      //check if the cell below is already occupied
      if (row + 1 < colLength && row >= 0 && gameBoard[row + 1][col] != null) {
        return true; //collision with a landed piece
      }
    }
    return false; //NO COLLISION WITH A landed piece
  }

  void createNewPiece() {
    //create a random object to generate random tetromino types
    Random rand = Random();

    // create a new piece with random type
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  //move left
  void moveLeft() {
    //make sure the piece is valid before moving there
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }
  //move right

  void moveRight() {
    //make sure the piece is valid before moving there
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  //rotate piece
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  //Clear Lines
  void clearLines() {
    //step 1 : Loop through each row of the game board from bottom to top

    for (int row = colLength - 1; row >= 0; row--) {
      //step 2 : Initialize a variable to track if the row is full
      bool rowIsFull = true;

      //step 3 :check if the row is full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        //if there's an empty column, set rowIsFull to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      //step 4 :if the row is full, clear the row and shift rows down
      if (rowIsFull) {
        //step 5 : move all rows above the cleared row down by one position
        for (int r = row; r > 0; r--) {
          //copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        //step 6 : set the top row to empty
        gameBoard[0] = List.generate(row, (index) => null);

        //step 7 : Increase the score
        currentScore++;
      }
    }
  }

  //Game Over Method
  bool isGameOver() {
    //check if any colomns is the top row are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    //if the top row is empty , the game is not over
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength),
              itemBuilder: (context, index) {
                //get row and col of each index
                int row = (index / rowLength).floor();
                int col = index % rowLength;

                // current piece
                if (currentPiece.position.contains(index)) {
                  return Pixel(
                    color: currentPiece.color,
                  );
                }
                //landed pieces
                else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return Pixel(
                    color: tetrominoColors[tetrominoType],
                  );
                }
                //blank pixel
                else {
                  return Pixel(
                    color: Colors.grey[900],
                  );
                }
              },
            ),
          ),

          //Score
          Text(
            'Score: $currentScore',
            style: const TextStyle(color: Colors.white),
          ),

          //Game controls
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, top: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: moveLeft,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_back_ios),
                ),
                IconButton(
                  onPressed: rotatePiece,
                  color: Colors.white,
                  icon: const Icon(Icons.rotate_right),
                ),
                IconButton(
                  onPressed: moveRight,
                  color: Colors.white,
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
