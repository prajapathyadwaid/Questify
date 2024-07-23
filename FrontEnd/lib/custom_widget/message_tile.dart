import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final String messenger;
  late final Color borderColor;
  final TextEditingController _controller = TextEditingController();

  MessageTile({super.key, required this.message, required this.messenger}) {
    borderColor = (messenger == "Questify") ?  const Color(0xFF10a37f): const Color.fromARGB(255, 227, 30, 63);
    _controller.text = message;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              messenger,
              style: TextStyle(
                  color: borderColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            decoration: BoxDecoration(
           
              border: Border(
                left: BorderSide(width: 2, color: borderColor),
              ),
            ),
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  ),
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontSize: 15),
              readOnly: true,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
