import 'package:flutter/material.dart';

Widget textInput(controller, width, height, handleSubmitted,answered) {
  return Container(
    alignment: Alignment.topCenter,
    width: width / 1.6,
    height: height < 126 ? height * 0.2 : 70,
    child: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              TextField(
                controller: controller,
                onSubmitted: handleSubmitted,
                maxLines: null,
                expands: false,
                textInputAction: answered? TextInputAction.done:TextInputAction.none,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(79, 255, 255, 255), width: 1)),
                  filled: true,
                  fillColor: const Color.fromARGB(0, 0, 0, 0),
                  hintText: 'Ask a question',
                  hintStyle: const TextStyle(color: Colors.white60),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(68, 255, 255, 255),
                          width: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
