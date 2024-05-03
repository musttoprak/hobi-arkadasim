import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/components/showSnackbar.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/bottom_navigation_bar.dart';
import '../models/category_with_name.dart';
import '../models/event.dart';
import '../models/user_info.dart';
import '../models/user_search_view.dart';

class AddPostCubit extends Cubit<AddPostState> {
  final TextEditingController _controller;
  bool isLoading = false;
  BuildContext context;
  List<UserInformation> friends = [];
  List<HobbyCategory> hobbys = [];
  List<UserSearchView> userSearchView = [];
  String? selectedOption;
  String? selectedHobby;
  int rating = 0;

  AddPostCubit(this.context,this._controller)
      : super(AddPostInitialState()) {
    getFriendsAndHobby();
  }

  Future<void> getFriendsAndHobby() async {
    changeLoadingView();
    UserService service = UserService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    friends = await service.getFriends(prefs.getString('id')!);
    hobbys = await service.getUserHobbies(prefs.getString('id')!);
    emit(AddPostFriendsAndHobbysState(friends,hobbys));
    changeLoadingView();
  }


  void addPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    EventModel newEvent = EventModel(
      uid: prefs.getString('id')!,
      fuid: selectedOption!,
      rating: rating,
      desc: _controller.text,
      date: now,
      categoryId: selectedHobby!,
    );
    UserService service = UserService();
    await service.addEvent(newEvent).then((value) {
      ShowMySnackbar.snackbarShow(context, true, "Postunuz başarıyla oluşturuldu");
      emit(AddPostSuccessState(true));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeTabbarView(),
        ), // Avatar seçme sayfasına git
            (route) => false,
      );
    });
  }

  void changeLoadingView() {
    isLoading = !isLoading;
    emit(AddPostLoadingState(isLoading));
  }

  void changeOption(String newValue) {
    print(newValue);
    selectedOption = newValue;
    emit(AddPostChangeOptionState(selectedOption!));
  }

  void changeHobby(String newValue) {
    selectedHobby = newValue;
    emit(AddPostChangeHobbyState(selectedHobby!));
  }

  void changeRating(int newRating) {
    rating = newRating;
    emit(AddPostChangeRatingState(rating));
  }
}

abstract class AddPostState {}

class AddPostInitialState extends AddPostState {}

class AddPostLoadingState extends AddPostState {
  final bool isLoading;

  AddPostLoadingState(this.isLoading);
}
class AddPostFriendsAndHobbysState extends AddPostState {
  final List<UserInformation> friends;
  final List<HobbyCategory> hobbys;

  AddPostFriendsAndHobbysState(this.friends,this.hobbys);
}
class AddPostChangeOptionState extends AddPostState {
  final String option;

  AddPostChangeOptionState(this.option);
}

class AddPostChangeHobbyState extends AddPostState {
  final String hobby;

  AddPostChangeHobbyState(this.hobby);
}
class AddPostChangeRatingState extends AddPostState {
  final int rating;

  AddPostChangeRatingState(this.rating);
}
class AddPostSuccessState extends AddPostState {
  final bool success;

  AddPostSuccessState(this.success);
}
