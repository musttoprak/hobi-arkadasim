import 'package:flutter/material.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';
import 'package:hobiarkadasim/models/user_and_friend_request.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_info.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<UserAndFriendRequest> requests = [];
  bool isLoading = true;
  List<String> avatars = [
    'assets/man.png',
    'assets/human.png',
    'assets/man1.png',
    'assets/woman2.png',
    'assets/man2.png',
    'assets/woman3.png',
    'assets/man3.png',
    'assets/woman4.png',
    'assets/woman5.png',
    'assets/woman6.png',
  ];

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<void> _changeStatu(
      String senderId, String receiverId, bool isAccept) async {
    UserService service = UserService();
    await service
        .changeStatu(senderId, receiverId, isAccept ? 2 : 0)
        .then((value) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserService service = UserService();
    requests = await service.getFriendsRequest(prefs.getString('id')!);
    setState(() {
      requests;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold();
  }

  Scaffold buildScaffold() {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Bildirimler",
            style: TextStyle(color: Colors.black,fontSize: 24),
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  "Bugün",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 5),
                Expanded(child: Divider()), // Doğru kullanılmıştır.
              ],
            ),
          ),
          const SizedBox(height: 5),
          Visibility(
            visible: !isLoading,
            child: Expanded(
              child: requests.isEmpty ? notNotification() : listNatifcation(),
            ),
          ),
        ],
      ),
    );
  }

  ListView listNatifcation() {
    return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (BuildContext context, int index) {
                var request = requests[index];
                String date =
                    "${request.friendRequest.createdAt.toDate().day}-${request.friendRequest.createdAt.toDate().month}-${request.friendRequest.createdAt.toDate().year}";
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            avatars[request.userInformation.avatarId],
                            height: 45,
                            width: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        Flexible(
                          // Aşırı genişliği önler
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${request.userInformation.fullName} sana takip isteği attı.",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                date,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => _changeStatu(
                                    request.friendRequest.senderId.toString(),
                                    request.friendRequest.receiverId
                                        .toString(),
                                    true),
                                icon: const Icon(Icons.done),
                              ),
                              IconButton(
                                  onPressed: () => _changeStatu(
                                      request.friendRequest.senderId
                                          .toString(),
                                      request.friendRequest.receiverId
                                          .toString(),
                                      false),
                                  icon: const Icon(Icons.cancel)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
  }

  Center notNotification() {
    return const Center(
              child: Text("Hiç bildiriminiz bulunmamaktadır."),
            );
  }
}
