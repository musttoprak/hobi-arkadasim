import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hinttext;
  final TextEditingController mycontroller;
  final FocusNode? focusNode;

  const MyTextField(
      {super.key,
      required this.hinttext,
      required this.mycontroller,
      this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: TextField(
          controller: mycontroller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            fillColor: Colors.transparent,
            filled: true,
            hintText: "Mesaj Girinz..",
            hintStyle: TextStyle(color: Colors.grey),
          )),
    );
  }
}
