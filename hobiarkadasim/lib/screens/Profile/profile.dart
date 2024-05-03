import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hobiarkadasim/components/bottom_navigation_bar.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';
import 'package:hobiarkadasim/models/user_info.dart';
import 'package:hobiarkadasim/screens/SelectCategory/select_avatar.dart';
import 'package:hobiarkadasim/screens/SelectCategory/select_category.dart';
import 'package:hobiarkadasim/screens/Welcome/welcome_screen.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/showSnackbar.dart';
import '../../models/category_with_name.dart';

class ProfileView extends StatefulWidget {
  final UserInformation userInformation;
  final List<HobbyCategory> category;

  const ProfileView({
    super.key,
    required this.userInformation,
    required this.category,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late List<HobbyCategory> category;
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController desccontroller = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late UserInformation userInformation;
  String _selectedGender = 'Erkek';
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
    category = widget.category;
    userInformation = widget.userInformation;
    fullnamecontroller.text = userInformation.fullName;
    desccontroller.text = userInformation.desc;
    _dateController.text = userInformation.age;
    _selectedGender = userInformation.gender;
    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose(); // Controller'ı serbest bırak
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Başlangıç tarihi
      firstDate: DateTime(1900), // Geçerli bir ilk tarih
      lastDate: DateTime.now(), // Geçerli bir son tarih
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text =
            DateFormat.yMd().format(selectedDate); // Tarihi biçimlendirme
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: buildAppBar(context),
      body: Column(children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 1,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 41, 78, 141),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50.0),
              bottomRight: Radius.circular(50.0),
            ),
          ),
          child: Column(
            children: [
              avatarWidget(),
            ],
          ),
        ),
        Expanded(
            child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 238, 238, 238),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, left: 15, right: 7),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      dynamicTextWidget("Hobilerim"),
                      const SizedBox(
                        height: 7,
                      ),
                      myyHobbyWidget(category),
                      const SizedBox(
                        height: 7,
                      ),
                      dynamicTextWidget("Ad-Soyad"),
                      const SizedBox(
                        height: 7,
                      ),
                      fullNameTextFormField(),
                      const SizedBox(
                        height: 7,
                      ),
                      dynamicTextWidget("Cinsiyet"),
                      const SizedBox(
                        height: 7,
                      ),
                      genderWidget(),
                      const SizedBox(
                        height: 7,
                      ),
                      dynamicTextWidget("Doğum Tarihi"),
                      const SizedBox(
                        height: 7,
                      ),
                      ageTextFormField(context),
                      const SizedBox(
                        height: 7,
                      ),
                      dynamicTextWidget("Açıklama"),
                      const SizedBox(
                        height: 7,
                      ),
                      descTextFormField(),
                      const SizedBox(
                        height: 7,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ))
      ]),
    );
  }

  TextFormField descTextFormField() {
    return TextFormField(
      controller: desccontroller,
      validator: (value) => value != null
          ? value.isEmpty
              ? "Lütfen bu alanı doldurunuz."
              : null
          : "Lütfen bu alanı doldurunuz.",
      maxLines: 4,
      decoration: InputDecoration(
        icon: const Icon(Icons.description),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
        hintText: "Merhaba ben...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  TextFormField ageTextFormField(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      validator: (value) => value != null
          ? value.isEmpty
              ? "Lütfen bu alanı doldurunuz."
              : null
          : "Lütfen bu alanı doldurunuz.",
      decoration: InputDecoration(
        icon: const Icon(Icons.date_range),
        hintText: "Tarih seçin...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      readOnly: true,
      // Sadece tarih seçici ile değiştirilebilir
      onTap: () => _selectDate(context), // Tıklandığında tarih seçici açılır
    );
  }

  Widget genderWidget() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = 'Erkek';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedGender == 'Erkek'
                      ? AppColors.headerTextColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    "Erkek",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = 'Kadın'; // Cinsiyeti değiştir
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedGender == 'Kadın'
                      ? AppColors.headerTextColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    "Kadın",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField fullNameTextFormField() {
    return TextFormField(
      controller: fullnamecontroller,
      validator: (value) => value != null
          ? value.isEmpty
              ? "Lütfen bu alanı doldurunuz."
              : null
          : "Lütfen bu alanı doldurunuz.",
      decoration: InputDecoration(
        icon: const Icon(Icons.person),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
        hintText: "Ad Soyad",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 41, 78, 141),
      title: const Text(
        "Profilim",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      actions: [saveActionWidget(context), exitActionWidget(context)],
    );
  }

  Align avatarWidget() {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          ClipOval(
            child: Ink(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Image.asset(
                avatars[userInformation.avatarId],
                height: 90,
                width: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectAvatar(
                            userInformation: widget
                                .userInformation)), // Avatar seçme sayfasına git
                  );
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 3, color: Colors.white),
                    color: const Color.fromARGB(255, 59, 118, 166),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget exitActionWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('id');
            await prefs.remove('email');
            await prefs.remove('password');

            ShowMySnackbar.snackbarShow(context, true, "Başarıyla çıkış yapıldı");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ),
                (route) => false);
          },
          style: const ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.all(8)),
            backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
          ),
          child: const Text(
            "Çıkış",
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
          )),
    );
  }

  Widget saveActionWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              userInformation.fullName = fullnamecontroller.text;
              userInformation.desc = desccontroller.text;
              userInformation.age = _dateController.text;
              userInformation.gender = _selectedGender;
              UserService service = UserService();
              await service.addUserInformation(userInformation).then((value) {
                ShowMySnackbar.snackbarShow(
                    context, true, "Güncelleme işlemi tamamlandı");
                if (userInformation.fullName.isNotEmpty) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeTabbarView(),
                      ),
                      (route) => false);
                }
              });
            }
          },
          style: const ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.all(8)),
            backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
          ),
          child: const Text(
            "Kaydet",
            style: TextStyle(
                color: AppColors.headerTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          )),
    );
  }

  InkWell myyHobbyWidget(List<HobbyCategory> displayWords) {
    return InkWell(
      onTap: () async {
        UserService service = UserService();
        await service.getCategoryNames().then((value) async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectCategory(
                categories: value,
                savedCategories: displayWords,
              ),
            ), // Avatar seçme sayfasına git
          );
        });
      },
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 3,
        runSpacing: 3,
        children: displayWords
            .map((category) => Chip(
                  color: const MaterialStatePropertyAll<Color>(
                      AppColors.headerTextColor),
                  label: Text(category.name),
                ))
            .toList(),
      ),
    );
  }

  Widget dynamicTextWidget(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black87,
        fontFamily: "font4",
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
