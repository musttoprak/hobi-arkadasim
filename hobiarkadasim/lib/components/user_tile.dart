import 'package:flutter/material.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final int avatarpath;
  const UserTile({super.key, required this.text, this.onTap, required this.avatarpath});


  @override
  Widget build(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              color:Colors.white, // ListTile'ın arka plan rengi
              child: ListTile(
                trailing: Icon(Icons.arrow_circle_right),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),

                leading:ClipOval(
                  child: Ink(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Image.asset(
                      avatars[avatarpath],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Divider(height: 1,)
          ],
        ),
      ),
    );
  }
}
