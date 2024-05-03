import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hobiarkadasim/models/user_info.dart';
import 'package:hobiarkadasim/screens/Profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_service.dart';

class SetUserDesc extends StatefulWidget {
  final UserInformation userInformation;

  const SetUserDesc({super.key, required this.userInformation});

  @override
  State<SetUserDesc> createState() => _SetUserDescState();
}

class _SetUserDescState extends State<SetUserDesc> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late UserInformation userInformation;

  @override
  void initState() {
    userInformation = widget.userInformation;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose(); // Controller'ı serbest bırak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(context);
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
    appBar: AppBar(backgroundColor: Colors.white),
    body: Padding(
      padding: const EdgeInsets.all(16.0), // İçerik için boşluk
      child: Form(
        key: _formKey, // Doğrulama için form anahtarı
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kendinizi birkaç cümle ile tanımlayın",style: TextStyle(fontSize: 18)),
            descriptionWidget(),
            const Spacer(), // Buton için boşluk
            buildElevatedButton(context),
          ],
        ),
      ),
    ),
  );
  }

  Padding descriptionWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey),
        ),
        child: TextFormField(
          controller: _controller, // TextField kontrolü
          maxLines: 5, // Birkaç cümle için yeterli alan
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Kendinizi tanımlayın...",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 16.0),
          validator: (value) {
            // Doğrulama kontrolü
            if (value == null || value.isEmpty) {
              return "Lütfen kendinizi tanımlayın."; // Boş bırakmayı önler
            }
            return null; // Geçerli ise sorun yok
          },
        ),
      ),
    );
  }


  ElevatedButton buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await buildComplete();
      },
      child: const Text(
          "Tamamla"),
    );
  }

  Future<void> buildComplete() async {
    if (_formKey.currentState?.validate() ?? false) {
      userInformation.desc = _controller.text; 
      SharedPreferences prefs = await SharedPreferences.getInstance();

      UserService service = UserService();
      await service.addUserInformation(widget.userInformation).then((uinfo) async {
        await service.getUserHobbies(prefs.getString('id')!).then((value) {
          print("işlem tamamlandı");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileView(
                userInformation: userInformation,
                category: value,
              ),
            ),
          );
        });
      });
    }
  }
}
