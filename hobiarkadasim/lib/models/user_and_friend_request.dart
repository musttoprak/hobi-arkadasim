import 'package:hobiarkadasim/models/friend_request.dart';
import 'package:hobiarkadasim/models/user_info.dart';

class UserAndFriendRequest {
  final UserInformation userInformation;
  final FriendRequest friendRequest;

  UserAndFriendRequest({
    required this.userInformation,
    required this.friendRequest,
  });
}