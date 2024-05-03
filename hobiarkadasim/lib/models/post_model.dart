import 'package:hobiarkadasim/models/event.dart';
import 'package:hobiarkadasim/models/user_info.dart';

class PostModel{
  EventModel eventModel;
  UserInformation userInformation;
  UserInformation friendInformation;
  PostModel({required this.userInformation,required this.friendInformation,required this.eventModel});
}