import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobiarkadasim/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_with_name.dart';
import '../models/user_search_view.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserSearchView userSearchView;
  List<HobbyCategory> hobbies = [];
  bool isLoading = false;
  BuildContext context;
  int? eventCount;
  int? statu;
  int? takipEdilen;
  int? takipci;
  UserProfileCubit(this.context, this.userSearchView) : super(UserProfileInitialState()){
    getMatches();
  }

  Future<void> getMatches() async{
    changeLoadingView();
    UserService service = UserService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    eventCount = await service.getMatchingEventsCount(userSearchView.userInformation.uid);
    String? _statu = await service.getRequestStatus(prefs.getString('id')!,userSearchView.userInformation.uid);
    statu = int.parse(_statu ?? "0");

    await service.getRequestCount(prefs.getString('id')!,userSearchView.userInformation.uid).then((value) async {
      takipEdilen = value;
      await service.getRequestCount(userSearchView.userInformation.uid, prefs.getString('id')!).then((value2) async {
        takipci = value2;
        await service.getUserHobbies(prefs.getString('id')!).then((value3) {
          hobbies = value3;
          emit(UserProfileEventCountState(eventCount!,statu!,takipEdilen ?? 0,takipci ?? 0));
          changeLoadingView();
        });
      });
    });
  }

  Future<void> changeStatu() async{
    if(statu != null){
      if(statu == 0){
        statu = statu! + 1;
      }else{
        statu = 0;
      }
      UserService service = UserService();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await service.changeStatu(prefs.getString('id')!,userSearchView.userInformation.uid,statu!);
      emit(UserProfileEventCountState(eventCount!,statu!,takipEdilen ?? 0,takipci ?? 0));
    }
  }

  void changeLoadingView() {
    isLoading = !isLoading;
    emit(UserProfileLoadingState(isLoading));
  }


}

abstract class UserProfileState {}

class UserProfileInitialState extends UserProfileState {}

class UserProfileLoadingState extends UserProfileState {
  final bool isLoading;

  UserProfileLoadingState(this.isLoading);
}
class UserProfileEventCountState extends UserProfileState {
  final int eventCount;
  final int statu;
  final int takipEdilen;
  final int takipci;

  UserProfileEventCountState(this.eventCount,this.statu,this.takipEdilen,this.takipci);
}
