import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/bloc/home_screen_cubit.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';
import 'package:hobiarkadasim/screens/AddPost/add_post.dart';
import 'package:hobiarkadasim/screens/Message/message_list.dart';

import '../models/category_with_name.dart';
import '../models/user_info.dart';

class HomeScreen extends StatefulWidget {
  final UserInformation userInformation;
  final List<HobbyCategory> category;

  const HomeScreen(
      {super.key, required this.userInformation, required this.category});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with HomeScreenMixin {
  @override
  void initState() {
    userInformation = widget.userInformation;
    category = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenCubit(context),
      child: BlocBuilder<HomeScreenCubit, HomeScreenState>(
        builder: (context, state) {
          return buildScaffold(context);
        },
      ),
    );
  }
}

mixin HomeScreenMixin {
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
  late UserInformation userInformation;
  late List<HobbyCategory> category;

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.headerTextColor,
      appBar: AppBar(
        backgroundColor: AppColors.headerTextColor,
        title: const Text(
          "Hobby Arkadaşım",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageList(),
                  )),
              icon: const Icon(Icons.message))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                color: AppColors.headerTextColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 10),
                child: Stack(
                  children: [
                    ClipOval(
                      child: Ink(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Image.asset(
                          avatars[userInformation.avatarId],
                          height: 65,
                          width: 65,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: -1,
                        left: 40,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AddPost()),
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
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 1,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: context.watch<HomeScreenCubit>().isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : context.watch<HomeScreenCubit>().postModels!.isEmpty
                        ? const Center(
                            child: Text(
                                "Hiçbir arkadaşınız bir etkinlikte bulunmadı"),
                          )
                        : Center(
                            child: Column(
                              children: context
                                  .watch<HomeScreenCubit>()
                                  .postModels!
                                  .map(
                                (e) {
                                  String categoryName = context
                                      .watch<HomeScreenCubit>()
                                      .categoryNames
                                      .where((element) =>
                                          element.keys.first ==
                                          int.parse(e.eventModel.categoryId))
                                      .first
                                      .values
                                      .first;
                                  print(categoryName);
                                  return Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(.3),
                                              offset: const Offset(0, 4),
                                              blurRadius: 2,
                                              spreadRadius: 2)
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              ClipOval(
                                                child: Ink(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.black,
                                                  ),
                                                  child: Image.asset(
                                                    avatars[e.userInformation
                                                        .avatarId],
                                                    height: 35,
                                                    width: 35,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                e.userInformation.fullName,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    ClipOval(
                                                      child: Ink(
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        child: Image.asset(
                                                          avatars[e
                                                              .friendInformation
                                                              .avatarId],
                                                          height: 35,
                                                          width: 35,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          e.friendInformation.fullName.toUpperCase(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey,fontWeight: FontWeight.bold),
                                                        ),
                                                        Text(" İle $categoryName.",style: const TextStyle(color: Colors.black),)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const Text(
                                                    "Mustafa İle Beraber Counter Strike oynadık. Çok eğlendik. Çok eğlenceli bir kişiliği olduğu için ona 3 puan verdim."),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    StarDisplay(
                                                        value: e
                                                            .eventModel.rating),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Text(
                                                          '${e.eventModel.date.hour}:${e.eventModel.date.minute} '
                                                                  '${e.eventModel.date.day} ${_getMonthName(e.eventModel.date.month)} ${e.eventModel.date.year}'
                                                              .toString(),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Ocak';
      case 2:
        return 'Şubat';
      case 3:
        return 'Mart';
      case 4:
        return 'Nisan';
      case 5:
        return 'Mayıs';
      case 6:
        return 'Haziran';
      case 7:
        return 'Temmuz';
      case 8:
        return 'Ağustos';
      case 9:
        return 'Eylül';
      case 10:
        return 'Ekim';
      case 11:
        return 'Kasım';
      case 12:
        return 'Aralık';
      default:
        return '';
    }
  }
}

class StarDisplay extends StatelessWidget {
  final int value; // Aktif yıldız sayısı
  final int totalStars; // Toplam yıldız sayısı

  const StarDisplay({super.key, required this.value, this.totalStars = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(totalStars, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
          // Aktif veya boş yıldız
          color: index < value ? Colors.yellow : Colors.grey,
          // Aktif yıldız sarı, boş yıldız gri
          size: 24, // Yıldız boyutu
        );
      }),
    );
  }
}
