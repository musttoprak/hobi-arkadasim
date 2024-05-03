import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hobiarkadasim/components/user_tile.dart';
import 'package:hobiarkadasim/models/user_info.dart';
import 'package:hobiarkadasim/screens/Message/chat_page.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageList extends StatefulWidget {
  MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final UserService userservice = UserService();
  String uid = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getinitid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Text(
          "Mesajlar",
          style: TextStyle(color: Colors.black, fontSize: 24),
          textAlign: TextAlign.start,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: _buildUserList(userservice, uid),
    );
  }

  Future<void> getinitid() async {
    uid = await getid();
    setState(() {});
  }
}

Future<String> getid() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('id')!;
}

Widget _buildUserList(UserService userservice, String id) {
  return StreamBuilder(
      stream: userservice.getFriendStream(id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        print(snapshot.data!.map((e) => e.fullName));
        return ListView(
          children: snapshot.data!
              .map<Widget>(
                  (userData) => _buildUserListItem(userData, context, id))
              .toList(),
        );
      });
}

// Widget _buildUserList(UserService userservice,String id) {
//   return FutureBuilder(
//     future: userservice.getLastMessagesWithFriends(id), // Son mesajları getirir
//     builder: (context, snapshot) {
//       if (snapshot.hasError) {
//         return const Text("Bir hata oluştu.");
//       }

//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const CircularProgressIndicator(); // Yükleniyor işareti
//       }

//       var lastMessages = snapshot.data ?? [];

//       return ListView(
//         children: lastMessages.map((msg) {
//           String otherUserId = msg["otherUserId"];
//           String lastMessage = msg["lastMessage"];
//           var timestamp = msg["timestamp"];
//           DateTime dateTime = (timestamp as Timestamp).toDate();

//           final DateFormat formatter = DateFormat.jm('tr'); // Türkiye saat formatı
//           final formattedTime = formatter.format(dateTime);

//           return _buildUserListItem(otherUserId, lastMessage, formattedTime);
//         }).toList(),
//       );
//     },
//   );
// }
Widget _buildUserListItem(
    UserInformation userData, BuildContext context, String id) {
  return UserTile(
    text: userData.fullName,
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(
                    recievername: userData.fullName,
                    recieverId: userData.uid,
                    myId: id,
                  )));
    },
    avatarpath: userData.avatarId,
  );
}
