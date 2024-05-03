import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String time;
  const ChatBubble({super.key, required this.message, required this.isCurrentUser, required this.time});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:widget.isCurrentUser? Colors.green:Colors.green.shade500,
        borderRadius: BorderRadius.circular(20)
      ),
       padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 2.5,horizontal: 25),
      child: Column(
        children: [
          Text(widget.message,style: TextStyle(color: Colors.white),),
          Text(widget.time , style: TextStyle(color: Colors.white,fontSize: 11),),
        ],
      ),
    );
  }
}