import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';
import '../models/post_model.dart';

class HomeScreenCubit extends Cubit<HomeScreenState> {
  bool isLoading = true;
  BuildContext context;
  List<PostModel>? postModels;
  List<Map<int,String>> categoryNames = [];
  HomeScreenCubit(this.context) : super(HomeScreenInitialState()) {
    getPosts();
  }

  Future<void> getPosts() async {
    UserService service = UserService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await service.getFriends(prefs.getString('id')!).then((value) async {
      await service
          .getFriendPosts(value.map((e) => e.uid).toList())
          .then((value) async {
        postModels = value;
        for (var element in postModels!) {
          await service.getCategoryName(element.eventModel.categoryId).then((categoryName) {
            categoryNames.add({
              int.parse(element.eventModel.categoryId): categoryName
            });
          });
        }
        print(postModels?.length);
        emit(HomeScreenGetPostsState(postModels!,categoryNames));
        changeLoadingView();
      });
    });
  }

  Future<String> getCategoryName(int categoryId) async {
    UserService service = UserService();
    return await service.getCategoryNameById(categoryId);
  }

  void changeLoadingView() {
    isLoading = !isLoading;
    emit(HomeScreenLoadingState(isLoading));
  }
}

abstract class HomeScreenState {}

class HomeScreenInitialState extends HomeScreenState {}

class HomeScreenLoadingState extends HomeScreenState {
  final bool isLoading;

  HomeScreenLoadingState(this.isLoading);
}

class HomeScreenGetPostsState extends HomeScreenState {
  final List<PostModel> eventModels;
  final List<Map<int, String>> categoryNames;
  HomeScreenGetPostsState(this.eventModels, this.categoryNames);
}
