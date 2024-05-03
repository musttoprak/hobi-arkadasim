class UserInformation {
  String uid;
  int avatarId;
  String desc;
  String fullName;
  String gender;
  String age;
  int rating;

  UserInformation(
      {required this.uid,
      required this.avatarId,
      required this.desc,
      required this.fullName,
      required this.gender,
      required this.age,
      required this.rating});

  factory UserInformation.fromJson(Map<String, dynamic> json) {
    return UserInformation(
      uid: json['uid'],
      avatarId: json['avatarId'],
      desc: json['desc'],
      fullName: json['fullName'],
      gender: json['gender'],
      age: json['age'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'avatarId': avatarId,
      'desc': desc,
      'fullName': fullName,
      'gender': gender,
      'age': age,
      'rating': rating,
    };
  }
}
