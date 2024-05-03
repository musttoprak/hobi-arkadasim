import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hobiarkadasim/constants/app_colors.dart';
import 'package:hobiarkadasim/models/user_info.dart';
import 'package:hobiarkadasim/screens/Notifications/notification.dart';
import 'package:hobiarkadasim/screens/Profile/profile.dart';
import 'package:hobiarkadasim/screens/Search/search.dart';
import 'package:hobiarkadasim/screens/home_screen.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_with_name.dart';
import '../screens/AddPost/add_post.dart';

class HomeTabbarView extends StatefulWidget {
  const HomeTabbarView({super.key});

  @override
  State<HomeTabbarView> createState() => _HomeTabbarViewState();
}

class _HomeTabbarViewState extends State<HomeTabbarView> {
  UserInformation? user;
  List<HobbyCategory>? category;

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserService service = UserService();
    await service
        .getUserInformation(prefs.getString('id')!)
        .then((value) async {
      await service.getUserHobbies(prefs.getString('id')!).then((value2) {
        setState(() {
          user = value;
          category = value2;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        bottomNavigationBar: const BottomAppBar(
          height: 60,
          color: Color(0xFFF8F8FF),
          child: TabBar(
            indicatorColor: AppColors.headerTextColor,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(Icons.home),
              ),
              Tab(
                icon: Icon(Icons.notifications_sharp),
              ),
              Tab(
                icon: Icon(Icons.add),
              ),
              Tab(
                icon: Icon(Icons.search),
              ),
              Tab(
                icon: Icon(Icons.account_circle),
              )
            ],
          ),
        ),
        body: user != null
            ? TabBarView(
                children: [
                  HomeScreen(userInformation: user!, category: category!),
                  const NotificationView(),
                  const AddPost(),
                  SearchView(userInformation: user!, category: category!),
                  ProfileView(userInformation: user!, category: category!)
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
