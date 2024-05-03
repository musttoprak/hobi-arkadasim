import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hobiarkadasim/components/chat_bubble.dart';
import 'package:hobiarkadasim/components/my_text_field.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final String recievername;
  final String recieverId;
  final String myId;
  ChatPage(
      {super.key,
      required this.recievername,
      required this.recieverId,
      required this.myId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messagecontroller = TextEditingController();

  final UserService userservice = UserService();

  String email = "";

  FocusNode myfocusnode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeDateFormatting('tr', null).then((_) {
      // Başlatıldıktan sonra kullanabilirsiniz
    });
    getinit();
    myfocusnode.addListener(() {
      if (myfocusnode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myfocusnode.dispose();
    _messagecontroller.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  void sendMessage() async {
    if (_messagecontroller.text.isNotEmpty) {
      await userservice.sendMessage(
          widget.recieverId, _messagecontroller.text, widget.myId, email);
      _messagecontroller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recievername),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
      ),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildUserInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: userservice.getMessage(widget.recieverId, widget.myId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          print(snapshot.data!.docs.length);

          return ListView(
              controller: _scrollController,
              children: snapshot.data!.docs
                  .map((doc) => _buildMessageItem(doc, widget.myId))
                  .toList());
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc, String id) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == widget.myId;
    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();

// 3 saat eklemek için
    DateTime adjustedTimestamp = timestamp.add(const Duration(hours: 3));

// Formatlamak için `DateFormat`
    final DateFormat formatter = DateFormat.jm('tr');
    final formattedTime = formatter.format(adjustedTimestamp);
    var aligment = isCurrentUser ? Alignment.centerLeft : Alignment.centerRight;
    return Container(
        alignment: aligment,
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data["message"],
              isCurrentUser: isCurrentUser,
              time: formattedTime,
            )
          ],
        ));
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          Expanded(
              child: MyTextField(
            hinttext: "Type a Message",
            mycontroller: _messagecontroller,
            focusNode: myfocusnode,
          )),
          Container(
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              margin: const EdgeInsets.only(right: 15),
              child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  )))
        ],
      ),
    );
  }

  Future<String> getemail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email')!;
  }

  void getinit() async {
    email = await getemail();
  }
}
