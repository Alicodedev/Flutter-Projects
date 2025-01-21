import 'package:flutter/material.dart';
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.teal,

        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,// space both red and blue containers form each other
          children: [
            Container(
              alignment: Alignment.center,
              color: Colors.red,
              width: 100.0,
              height: 800.0,

            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center, // center both yellow and green containers vertically
              children: [
                Container(
                  alignment: Alignment.center,
                  color: Colors.yellow,
                  width: 100.0,
                  height: 100.0,

                ),



                Container(
                  alignment: Alignment.center,
                  color: Colors.green,
                  width: 100.0,
                  height: 100.0,

                ),
              ],
            ),



            Container(
              alignment: Alignment.center,
              color: Colors.blue,
              width: 100.0,
              height: 800.0,// approxmiate height of the container

            ),
          ],
        ),


        ),
      ),
  );
}

