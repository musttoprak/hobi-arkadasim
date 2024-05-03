import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_with_name.dart';
import '../models/user_hobby.dart';
import '../models/user_info.dart';
import '../models/user_search_view.dart';

class SearchCubit extends Cubit<SearchState> {
  final UserInformation userInformation;
  final List<HobbyCategory> category;
  bool isLoading = false;
  BuildContext context;
  List<HobbyCategory> myCategory = [];
  List<UserSearchView> userSearchView = [];
  String id = "";
  SearchCubit(this.context, this.userInformation, this.category)
      : super(SearchInitialState()) {
    getMatches();
  }

  Future<void> getMatches() async {
    userSearchView = [];
    changeLoadingView();
    UserService service = UserService();
    await service.getUserHobbyCategoryIds(category).then((value) async {
      value.forEach((element) async {
        UserInformation userInformation =
            await service.getUserInformation(element.uid);
        userSearchView.add(UserSearchView(
            userInformation: userInformation, userHobbyModel: element));
        userSearchView.removeWhere((element) => element.userInformation.uid == id);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      id = prefs.getString('id')!;
      await service.getUserHobbies(prefs.getString('id')!).then((value) {
        myCategory = value;
        print(myCategory.length);
        print("myCategory.length");
        emit(SearchUserSearchState(userSearchView));
        changeLoadingView();
      });
    });
  }
  Future<void> getMatchesFilter(List<HobbyCategory> filterHobbies) async {
    userSearchView = [];
    changeLoadingView();
    UserService service = UserService();
    await service.getUserHobbyCategoryIds(filterHobbies).then((value) async {
      value.forEach((element) async {
        UserInformation userInformation =
        await service.getUserInformation(element.uid);
        userSearchView.add(UserSearchView(
            userInformation: userInformation, userHobbyModel: element));
        userSearchView.removeWhere((element) => element.userInformation.uid == id);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await service.getUserHobbies(prefs.getString('id')!).then((value) {
        myCategory = value;
        print(myCategory.length);
        print("myCategory.length");
        emit(SearchUserSearchState(userSearchView));
        changeLoadingView();
      });
    });
  }

  void changeLoadingView() {
    isLoading = !isLoading;
    emit(SearchLoadingState(isLoading));
  }
}

abstract class SearchState {}

class SearchInitialState extends SearchState {}

class SearchLoadingState extends SearchState {
  final bool isLoading;

  SearchLoadingState(this.isLoading);
}

class SearchUserSearchState extends SearchState {
  final List<UserSearchView> userSearchView;

  SearchUserSearchState(this.userSearchView);
}
