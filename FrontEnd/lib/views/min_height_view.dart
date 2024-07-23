import 'package:flutter/material.dart';

Widget minHeightView(height, width) {
  return Container(
    height: height,
    width: width,
    alignment: Alignment.center,
    color: const Color.fromARGB(255, 17, 17, 17),
    child: Container(
      color: const Color.fromARGB(255, 17, 17, 17),
      child: const Text(
        'Questify',
        style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w500,
            fontFamily: 'Noto',
            fontSize: 21),
      ),
    ),
  );
}
