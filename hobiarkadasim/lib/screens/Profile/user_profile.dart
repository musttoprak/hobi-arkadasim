import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/components/star_rating_widget.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';

import '../../bloc/user_profile_cubit.dart';
import '../../models/user_search_view.dart';

class UserProfile extends StatefulWidget {
  final UserSearchView userSearchView;

  const UserProfile({super.key, required this.userSearchView});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with UserProfileMixin {
  @override
  void initState() {
    userSearchView = widget.userSearchView;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileCubit(context, userSearchView),
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          return buildScaffold(context);
        },
      ),
    );
  }
}

mixin UserProfileMixin {
  late UserSearchView userSearchView;
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

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: buildAppBar(context),
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              topWidget(context),
              bottomWidget(context),
            ],
          ),
        ),
        followButton(context),
      ]),
    );
  }

  Widget bottomWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            dynamicTextWidget("Hobileri"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 3, // Chip'ler arası yatay boşluk
              runSpacing: 3, // Satırlar arası dikey boşluk
              children: context
                  .watch<UserProfileCubit>()
                  .hobbies
                  .map((word) => Chip(
                        label: Text(word.name),
                      ))
                  .toList(), // Chip'e dönüştür
            ),
            const SizedBox(height: 12),
            dynamicTextWidget("Hakkında"),
            const SizedBox(height: 12),
            Text(userSearchView.userInformation.desc),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Container topWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      decoration: const BoxDecoration(
        color: AppColors.headerTextColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.0),
          bottomRight: Radius.circular(50.0),
        ),
      ),
      child: Column(
        children: [
          topImageAndName(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StarRatingWidget(userSearchView.userInformation.rating, 5),
          ),
          const SizedBox(height: 10), // Boşluk eklemek için
          topInFormation(context),
          const SizedBox(height: 20),
          genderAndAge(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Row genderAndAge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.male,
          color: Colors.white,
          size: 30,
        ), // Cinsiyet simgesi
        const SizedBox(width: 8), // Boşluk
        Text(
          userSearchView.userInformation.gender, // Cinsiyet metni
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(width: 16), // Boşluk
        const Icon(
          Icons.person_outline_sharp,
          color: Colors.white,
          size: 30,
        ), // Yaş simgesi
        const SizedBox(width: 8), // Boşluk
        Text(
          "${ageCalculator(userSearchView.userInformation.age)} yaşında",
          // Yaş metni
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Center topInFormation(BuildContext context) {
    return Center(
      child: Row(
        // Yan yana düzenlemek için Row kullanılır
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.watch<UserProfileCubit>().takipEdilen != null
                    ? context.watch<UserProfileCubit>().takipEdilen.toString()
                    : "0",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Takip Edilen",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.watch<UserProfileCubit>().takipci != null
                    ? context.watch<UserProfileCubit>().takipci.toString()
                    : "0",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Takipçi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20), // Boşluk eklemek için
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.watch<UserProfileCubit>().eventCount != null
                    ? context.watch<UserProfileCubit>().eventCount.toString()
                    : "-",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Etkinlik",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column topImageAndName() {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              ClipOval(
                child: Ink(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Image.asset(
                    avatars[userSearchView.userInformation.avatarId],
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          userSearchView.userInformation.fullName,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.headerTextColor,
    );
  }

  Widget dynamicTextWidget(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontFamily: "font4",
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.start,
    );
  }

  int ageCalculator(String birthDateStr) {
    // Tarih formatı MM/dd/yyyy şeklinde olmalıdır
    List<String> parts = birthDateStr.split('/');
    if (parts.length != 3) {
      throw const FormatException(
          'Geçersiz tarih formatı. Doğru format: MM/dd/yyyy');
    }

    int month = int.tryParse(parts[0]) ?? 0;
    int day = int.tryParse(parts[1]) ?? 0;
    int year = int.tryParse(parts[2]) ?? 0;

    // Doğum tarihini oluştur
    final birthDate = DateTime(year, month, day);

    // Şu anki tarihi al
    final now = DateTime.now();

    // Yaşı hesapla
    int age = now.year - birthDate.year;
    int monthDiff = now.month - birthDate.month;
    int dayDiff = now.day - birthDate.day;

    // Doğum tarihi ay ve gün değerlerine göre yaş hesaplama
    if (monthDiff < 0 || (monthDiff == 0 && dayDiff < 0)) {
      age--;
    }

    return age;
  }
}

Align followButton(BuildContext context) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
          onPressed: () {
            context.read<UserProfileCubit>().changeStatu();
          },
          style: const ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll<Color>(AppColors.headerTextColor)),
          child: Text(
            context.watch<UserProfileCubit>().statu != null
                ? context.watch<UserProfileCubit>().statu == 0
                    ? "Takip Et"
                    : context.watch<UserProfileCubit>().statu == 1
                        ? "İsteği Kaldır"
                        : "Arkadaşlıktan Çık"
                : "-",
            style: const TextStyle(
                color: Colors.white, fontFamily: "font3", fontSize: 16),
          )),
    ),
  );
}
