import 'package:hobiarkadasim/models/category_with_name.dart';

class UserHobbyModel {
  String uid;
  List<HobbyCategory> categories;
  UserHobbyModel({required this.uid,required this.categories});

  factory UserHobbyModel.fromJson(Map<String, dynamic> json) {
    return UserHobbyModel(
      uid: json['uid'],
      categories: json['categories'],
    );
  }
}