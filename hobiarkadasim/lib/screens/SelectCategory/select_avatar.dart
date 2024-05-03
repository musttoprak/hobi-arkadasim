import 'package:flutter/material.dart';
import 'package:hobiarkadasim/models/user_info.dart';
import 'package:hobiarkadasim/screens/SelectCategory/set_user_description.dart';
import 'package:hobiarkadasim/services/user_service.dart';

import '../../components/bottom_navigation_bar.dart';
import '../../components/showSnackbar.dart';

class SelectAvatar extends StatefulWidget {
  final UserInformation userInformation;

  const SelectAvatar({
    super.key,
    required this.userInformation,
  });

  @override
  _SelectAvatarState createState() => _SelectAvatarState();
}

class _SelectAvatarState extends State<SelectAvatar> {
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
  int? selectedAvatar;
  late UserInformation userInformation;

  @override
  void initState() {
    userInformation = widget.userInformation;
    setState(() {
      selectedAvatar = userInformation.avatarId;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "Sizi İfade Eden Avatarı Seçin:",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 24),
            selectingAvatars(),
            const Spacer(),
            buildElevatedButton(),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton() {
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize:
            MaterialStateProperty.all<Size>(const Size(double.infinity, 50)),
      ),
      onPressed: () async {
        await buttonComplete();
      },
      child: const Text("İlerle"), // Buton yazısı
    );
  }

  Future<void> buttonComplete() async {
    UserService service = UserService();
    await service.addUserInformation(userInformation).then((uinfo) {
      print("işlem tamamlandı");
      if(uinfo.desc.isEmpty){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetUserDesc(
              userInformation: userInformation,
            ),
          ), // Avatar seçme sayfasına git
        );
      }else {
        ShowMySnackbar.snackbarShow(context, true, "İşleminiz tamamlanmıştır");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeTabbarView(),
          ), // Avatar seçme sayfasına git
              (route) => false,
        );
      }
    });
  }

  Wrap selectingAvatars() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: List.generate(avatars.length, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAvatar = index;
              userInformation.avatarId = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    selectedAvatar == index ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              avatars[index], // Avatar resmini göster
              width: 80,
              height: 80,
            ),
          ),
        );
      }),
    );
  }
}
