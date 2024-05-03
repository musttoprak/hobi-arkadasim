import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String uid;
  String fuid;
  int rating;
  String desc;
  DateTime date;
  String categoryId;

  EventModel({
    required this.uid,
    required this.fuid,
    required this.rating,
    required this.desc,
    required this.date,
    required this.categoryId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      uid: json['uid'],
      fuid: json['fuid'],
      rating: json['rating'],
      desc: json['desc'],
      date: (json['date'] as Timestamp).toDate(),
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fuid': fuid,
      'rating': rating,
      'desc': desc,
      'date': date,
      'categoryId': categoryId,
    };
  }
}