import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobiarkadasim/models/friend_request.dart';

import '../models/category_with_name.dart';
import '../models/event.dart';
import '../models/message.dart';
import '../models/post_model.dart';
import '../models/user_and_friend_request.dart';
import '../models/user_hobby.dart';
import '../models/user_info.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Stream<List<UserInformation>> getFriendStream(String uid) {
    return FirebaseFirestore.instance
        .collection('friend_requests')
        .where('status', isEqualTo: "2")
        .where('sender_id', isEqualTo: uid) // Kendi kullanıcı kimliğinizi buraya ekleyin
        .snapshots() // Stream oluşturmak için snapshots() kullanılır
        .asyncMap((querySnapshot) async {
      List<UserInformation> friendList = [];
      // Belirtilen durumu ve send_id'yi taşıyan tüm belgeleri işleyin
      for (var doc in querySnapshot.docs) {
        String receiverId = doc['receiver_id'];

        // Kullanıcı bilgilerini almak için receiver_id'yi kullanarak user_information belgesini alın
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user_information')
            .doc(receiverId)
            .get();

        // Kullanıcı bilgilerini işleyin
        if (userSnapshot.exists) {
          UserInformation userInformation = UserInformation.fromJson(
              userSnapshot.data()! as Map<String, dynamic>);
          friendList.add(userInformation);
        }
      }
      return friendList; // Güncellenmiş arkadaş listesini döndürür
    });
  }

  Future<void> sendMessage(String receiverId,message,currentuserId,currentuserEmail)async{
    final Timestamp timestamp=Timestamp.now();
    Message newmessage=Message(senderId: currentuserId, senderEmail: currentuserEmail, receiverId: receiverId, message: message, timestamp: timestamp);
    List<String> ids=[currentuserId,receiverId];
    ids.sort();
    String chatRoomId=ids.join('_');
    await _firestore.collection("chat_rooms").doc(chatRoomId).collection('messages').add(newmessage.toMap());
  }

  Stream<QuerySnapshot> getMessage(String userID,String otheruserID){
    List<String> ids=[userID,otheruserID];
    ids.sort();
    String chatRoomId=ids.join('_');
    print(chatRoomId);
    return _firestore.collection("chat_rooms").doc(chatRoomId).collection("messages").orderBy("timestamp",descending: false).snapshots() ;
  }

  Future<List<Map<String, dynamic>>> getLastMessagesWithFriends(
      String userId) async {
    List<Map<String, dynamic>> lastMessages = [];

    try {
      // 1. Belirtilen kullanıcı kimliğine sahip tüm sohbet odalarını alın
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("chat_rooms")
          .where("participants", arrayContains: userId) // Katılımcı olarak kullanıcı kimliği
          .get();

      // 2. Her sohbet odasındaki son mesajı alın
      for (var doc in querySnapshot.docs) {
        String chatRoomId = doc.id;

        // Son mesajı almak için orderBy ile timestamp'e göre sıralayıp, bir mesaj alın
        QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
            .collection("chat_rooms")
            .doc(chatRoomId)
            .collection("messages")
            .orderBy("timestamp", descending: true) // Zaman damgasına göre sıralama
            .limit(1) // Son mesajı al
            .get();

        if (messageSnapshot.docs.isNotEmpty) {
          var lastMessageDoc = messageSnapshot.docs.first;

          String lastMessage = lastMessageDoc["message"];
          var timestamp = lastMessageDoc["timestamp"];

          // Sohbet odasındaki diğer kullanıcı kimliğini alın
          List<dynamic> participants = doc["participants"];
          participants.remove(userId); // Kendinizi kaldırın
          String otherUserId = participants.isNotEmpty ? participants.first : "";

          // Verileri harita olarak ekleyin
          lastMessages.add({
            "chatRoomId": chatRoomId,
            "lastMessage": lastMessage,
            "timestamp": timestamp,
            "otherUserId": otherUserId,
          });
        }
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }

    return lastMessages;

  }

  Future<List<PostModel>> getFriendPosts(List<String> friendUIDs) async {
    List<PostModel> postModels = [];
    try {
      // Arkadaşlarınızın UID'lerini kullanarak Firestore'dan postları getirin
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('uid', whereIn: friendUIDs)
          .get();

      // Her belgeyi döngüye alarak postları oluşturun
      for (var doc in querySnapshot.docs) {
        EventModel event = EventModel.fromJson(doc.data() as Map<String, dynamic>);
        // Kullanıcının bilgilerini alın
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user_information')
            .doc(event.uid)
            .get();
        UserInformation userInformation = UserInformation.fromJson(userSnapshot.data() as Map<String, dynamic>);

        // Arkadaşın bilgilerini alın
        DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
            .collection('user_information')
            .doc(event.fuid)
            .get();
        UserInformation friendInformation = UserInformation.fromJson(friendSnapshot.data() as Map<String, dynamic>);

        // PostModel nesnesini oluşturun ve listeye ekleyin
        PostModel post = PostModel(
          userInformation: userInformation,
          friendInformation: friendInformation,
          eventModel: event,
        );
        postModels.add(post);
      }
      return postModels;
    } catch (e) {
      print('Postlar alınırken hata oluştu: $e');
      return [];
    }
  }


  Future<void> addEvent(EventModel event) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('events').add(event.toJson());
      print('Etkinlik başarıyla eklendi: ${docRef.id}');
    } catch (e) {
      print('Etkinlik eklenirken hata oluştu: $e');
      throw e;
    }
  }

  Future<List<UserAndFriendRequest>> getFriendsRequest(String uid) async {
    List<UserAndFriendRequest> friendList = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('status', isEqualTo: "1")
          .where('receiver_id', isEqualTo: uid)
          .get();

      for (var doc in querySnapshot.docs) {
        String senderId = doc['sender_id'];

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user_information')
            .doc(senderId)
            .get();

        if (userSnapshot.exists) {
          UserInformation userInformation = UserInformation.fromJson(userSnapshot.data()! as Map<String, dynamic>);
          FriendRequest friendRequest = FriendRequest.fromMap(doc.data()! as Map<String, dynamic>);
          UserAndFriendRequest userAndFriendRequest = UserAndFriendRequest(
            userInformation: userInformation,
            friendRequest: friendRequest,
          );
          friendList.add(userAndFriendRequest);
        }
      }
      return friendList;

    } catch (e) {
      // Hata durumunu işleyin
      print('Hata oluştu: $e');
      return [];
    }
  }

  Future<List<UserInformation>> getFriends(String uid) async {
    List<UserInformation> friendList = [];
    try {
      // Firestore sorgusu: Durumu 2 olan ve send_id'si kendisi olan friend_request belgelerini al
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('status', isEqualTo: "2")
          .where('sender_id', isEqualTo: uid) // Kendi kullanıcı kimliğinizi buraya ekleyin
          .get();
      print(querySnapshot.docs.length);
      // Belirtilen durumu ve send_id'yi taşıyan tüm belgeleri işleyin
      for (var doc in querySnapshot.docs) {
        String receiverId = doc['receiver_id'];

        // Kullanıcı bilgilerini almak için receiver_id'yi kullanarak user_information belgesini alın
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user_information')
            .doc(receiverId)
            .get();

        // Kullanıcı bilgilerini işleyin
        if (userSnapshot.exists) {
          // Kullanıcı bilgilerini UserInformation nesnesine dönüştürüp listeye ekleyin
          UserInformation userInformation = UserInformation.fromJson(userSnapshot.data()! as Map<String,dynamic>);
          friendList.add(userInformation);
        }
      }

      QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('status', isEqualTo: "2")
          .where('receiver_id', isEqualTo: uid) // Kendi kullanıcı kimliğinizi buraya ekleyin
          .get();
      print(querySnapshot2.docs.length);
      // Belirtilen durumu ve send_id'yi taşıyan tüm belgeleri işleyin
      for (var doc in querySnapshot2.docs) {
        String sender_id = doc['sender_id'];

        // Kullanıcı bilgilerini almak için receiver_id'yi kullanarak user_information belgesini alın
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user_information')
            .doc(sender_id)
            .get();

        // Kullanıcı bilgilerini işleyin
        if (userSnapshot.exists) {
          // Kullanıcı bilgilerini UserInformation nesnesine dönüştürüp listeye ekleyin
          UserInformation userInformation = UserInformation.fromJson(userSnapshot.data()! as Map<String,dynamic>);
          friendList.add(userInformation);
        }
      }


      return friendList;

    } catch (e) {
      // Hata durumunu işleyin
      print('Hata oluştu: $e');
      return [];
    }
  }

  Future<int?> getRequestCount(String sender_id, String receiver_id) async {
    try {
      // Firestore sorgusu: İstenen kullanıcılar için friend_request belgesini filtrele
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('sender_id', isEqualTo: sender_id)
          .where('receiver_id', isEqualTo: receiver_id)
          .where('status', isEqualTo: "2")
          .get();

      // Durumu döndür
      if (querySnapshot.docs.isNotEmpty) {
        // Belge bulunduysa status alanını döndür
        return querySnapshot.docs.length;
      } else {
        // Belge bulunamadıysa null döndür
        return null;
      }
    } catch (e) {
      // Hata durumunda null döndür
      print('Hata oluştu: $e');
      return null;
    }
  }

  Future<void> changeStatu(String senderId, String receiverId,int status) async {
    try {
      // Firestore sorgusu: İsteğin var olup olmadığını kontrol et
      QuerySnapshot querySnapshot = await _firestore
          .collection('friend_requests')
          .where('sender_id', isEqualTo: senderId)
          .where('receiver_id', isEqualTo: receiverId)
          .limit(1)
          .get();

      // İsteğin durumunu değiştir
      if (querySnapshot.docs.isNotEmpty) {
        // İsteğin bulunduğu belgeyi güncelle
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        String docId = docSnapshot.id;

        // Yeni durumu belirle
        int newStatus = status;

        // Firestore'da belgeyi güncelle
        await _firestore.collection('friend_requests').doc(docId).update({
          'status': newStatus.toString(),
        });
      } else {
        // İsteğin bulunmadığı durumda, yeni bir istek oluştur
        await _firestore.collection('friend_requests').add({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'status': status.toString(),
          'created_at': DateTime.now(),
          'updated_at': DateTime.now(),
        });
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }


  Future<String?> getRequestStatus(String senderId, String receiverId) async {
    try {
      // Firestore sorgusu: receiverId ve senderId'ye göre isteği filtrele
      QuerySnapshot querySnapshot = await _firestore
          .collection('friend_requests')
          .where('receiver_id', isEqualTo: receiverId)
          .where('sender_id', isEqualTo: senderId)
          .limit(1)
          .get();

      // İsteğin durumunu döndür
      if (querySnapshot.docs.isNotEmpty) {
        // Belge bulunduysa status alanını döndür
        return querySnapshot.docs.first.get('status');
      } else {
        // Belge bulunamadıysa null döndür
        return null;
      }
    } catch (e) {
      // Hata durumunda null döndür
      print('Hata oluştu: $e');
      return null;
    }
  }


  Future<int> getMatchingEventsCount(String uid) async {
    try {
      // Etkinlikler koleksiyonundan belgeleri al ve UID'ye göre filtrele
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .where('uid', isEqualTo: uid)
          .get();

      // Eşleşen etkinliklerin sayısını döndür
      return querySnapshot.size;
    } catch (e) {
      print('Etkinlikler alınırken hata oluştu: $e');
      return 0;
    }
  }

  Future<List<UserHobbyModel>> getUserHobbyCategoryIds(List<HobbyCategory> categories) async {
    List<UserHobbyModel> userHobbyCategoryIds = [];

    try {
      // UID'leri toplamak için bir harita kullanılacak
      Map<String, List<String>> uidCategoryMap = {};

      // Her bir kategori için user_hobby tablosundan veri çek
      for (var category in categories) {
        QuerySnapshot? querySnapshot = await _firestore
            .collection('user_hobby')
            .where('categoryId', isEqualTo: category.id)
            .get();

        if (querySnapshot != null) {
          // Bu kategoriye ait kullanıcıları döngüye al
          for (var doc in querySnapshot.docs) {
            String uid = doc['uid'];
            String categoryId = doc['categoryId'];

            // Eğer bu UID daha önce haritada varsa, kategori ID'sini ekleyelim
            if (uidCategoryMap.containsKey(uid)) {
              uidCategoryMap[uid]!.add(categoryId);
            } else {
              // Eğer yoksa, yeni bir listeye başlayalım
              uidCategoryMap[uid] = [categoryId];
            }
          }
        } else {
          // Hata durumunu işleyin
          print('user_hobby verileri alınırken bir hata oluştu');
        }
      }
      QuerySnapshot querySnapshot2 = await _firestore
          .collection('category')
          .get();

      // Haritadaki her bir öğeyi UserHobby nesnesine dönüştürerek listeye ekleyelim
      uidCategoryMap.forEach((uid, categoryIds) {
        List<HobbyCategory> categories = [];
        for (var cId in categoryIds) {
          for (var e in querySnapshot2.docs) {
            if(cId == e.id){
              categories.add(HobbyCategory(id: e.id, name: e['name']));
            }
          }
        }
        userHobbyCategoryIds.add(UserHobbyModel(uid: uid,categories: categories));
      });
      return userHobbyCategoryIds;
    } catch (e) {
      print('Kullanıcı hobileri alınırken hata oluştu: $e');
      return [];
    }
  }






  Future<UserInformation> getUserInformation(String uid) async {
    try {
      final userDoc = await _firestore.collection('user_information').doc(uid).get();

      if (userDoc.exists) {
        // Kullanıcı mevcut, bilgileri döndür
        return UserInformation.fromJson(userDoc.data()!);
      } else {
        // Kullanıcı yok, varsayılan bilgileri döndür
        return UserInformation(
          uid: uid,
          avatarId: 0, // Varsayılan avatar ID
          desc: '', // Boş açıklama
          fullName: '', // Boş tam isim
          gender: '', // Boş cinsiyet
          age: '', // Boş yaş
          rating: 0, // Varsayılan derecelendirme
        );
      }
    } catch (e) {
      print('Kullanıcı bilgileri alınırken hata oluştu: $e');
      // Hata durumunda varsayılan bilgileri döndür
      return UserInformation(
        uid: uid,
        avatarId: 0,
        desc: '',
        fullName: '',
        gender: '',
        age: '',
        rating: 0,
      );
    }
  }

  Future<UserInformation> addUserInformation(UserInformation user) async {
    try {
      final userDoc = await _firestore.collection('user_information').doc(user.uid).get();

      if (userDoc.exists) {
        // Kullanıcı zaten mevcut, güncelle
        await _firestore.collection('user_information').doc(user.uid).update(user.toJson());
        print('Kullanıcı bilgileri güncellendi.');
      } else {
        // Kullanıcı yok, ekle
        await _firestore.collection('user_information').doc(user.uid).set(user.toJson());
        print('Yeni kullanıcı bilgileri eklendi.');
      }

      // Ekleme veya güncelleme işlemi tamamlandıktan sonra kullanıcı bilgilerini döndür
      return user;
    } catch (e) {
      print('Kullanıcı bilgileri eklenirken veya güncellenirken hata oluştu: $e');
      // Hata durumunda boş bir UserInformation nesnesi döndür
      return UserInformation(
        uid: user.uid,
        avatarId: 0,
        desc: '',
        fullName: '',
        gender: '',
        age: '',
        rating: 0,
      );
    }
  }

  Future<List<HobbyCategory>> getUserHobbies(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user_hobby')
          .where('uid', isEqualTo: userId)
          .get();

      List<HobbyCategory> savedCategories = [];

      for (var doc in querySnapshot.docs) {
        String categoryId = doc['categoryId'];

        // Kategori adını almak için kategori ID'sini kullanarak Firestore'dan sorgu yap
        DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
            .collection('category')
            .doc(categoryId)
            .get();

        if (categoryDoc.exists) {
          String categoryName = categoryDoc['name'];
          savedCategories.add(HobbyCategory(
            id: categoryId,
            name: categoryName,
          ));
        }
      }

      return savedCategories;
    } catch (e) {
      print('Kullanıcı hobileri alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<void> createUserHobby(String uid, List<String> categoryIds) async {
    try {
      // Kullanıcının önceki hobilerini sil
      await _firestore
          .collection('user_hobby')
          .where('uid', isEqualTo: uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });

      print(categoryIds.length);
      // Seçilen kategori ID'leriyle user_hobby tablosuna veri ekle
      for (var categoryId in categoryIds) {
        await _firestore.collection('user_hobby').doc().set({
          'uid': uid,
          'categoryId': categoryId,
        });
      }
      print('Kullanıcı hobileri başarıyla eklendi.');
    } catch (e) {
      print('Kullanıcı hobileri eklenirken hata oluştu: $e');
    }
  }

  Future<bool> checkUserExists(String uid) async {
    try {
      var userDoc = await _firestore.collection('user_hobby').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      print('Kullanıcı var mı kontrol edilirken hata oluştu: $e');
      return false;
    }
  }

  Future<List<CategoryWithName>> getCategoryNames() async {
    List<CategoryWithName> categoryWithNameList = [];

    try {
      QuerySnapshot querySnapshot = await _firestore.collection('category').get();

      // Kategorileri gruplamak için bir harita kullanılacak
      Map<int, List<HobbyCategory>> groupedCategories = {};
      Map<int, String> categoryNameMap = {};

      for (var doc in querySnapshot.docs) {
        String id = doc.id;
        int categoryId = doc['categoryId'];
        String categoryName = await getCategoryNameById(categoryId);
        if (categoryName.isNotEmpty) {
          // Belgeyi bir Category nesnesine dönüştür
          HobbyCategory category = HobbyCategory(id: id, name: doc['name']);

          categoryNameMap[categoryId] = categoryName;


          // Kategori ID'sine göre gruplamak için kategoriye göre bir anahtar kullan
          if (!groupedCategories.containsKey(categoryId)) {
            groupedCategories[categoryId] = [];
          }
          groupedCategories[categoryId]!.add(category);
        }
      }

      // Gruplanmış kategorileri CategoryWithName nesnelerine dönüştür
      groupedCategories.forEach((categoryId, categories) {
        String categoryName = categoryNameMap[categoryId]!;
        CategoryWithName categoryWithName = CategoryWithName(
          categoryName: categoryName, // İlk kategorinin adını alıyoruz
          items: categories,
        );
        categoryWithNameList.add(categoryWithName);
      });

      return categoryWithNameList;
    } catch (e) {
      print('Kategoriler alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<String> getCategoryNameById(int categoryId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('hobby')
          .where('categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['name'];
      } else {
        return '';
      }
    } catch (e) {
      print('Kategori adı alınırken hata oluştu: $e');
      return '';
    }
  }

  Future<String> getCategoryName(String categoryId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('category')
          .where(FieldPath.documentId, isEqualTo: categoryId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['name'];
      } else {
        return '';
      }
    } catch (e) {
      print('Kategori adı alınırken hata oluştu: $e');
      return '';
    }
  }

  void addHobbiesAndCategories() async {
    //// Hobileri ekleyelim
    //await _firestore.collection('hobby').doc('1').set({
    //  'name': 'Spor',
    //  'categoryId': 1,
    //});
    //
    //await _firestore.collection('hobby').doc('2').set({
    //  'name': 'Bilgisayar Oyunları',
    //  'categoryId': 2,
    //});
    //
    //await _firestore.collection('hobby').doc('3').set({
    //  'name': 'Mobil Oyunları',
    //  'categoryId': 3,
    //});
    //
    //await _firestore.collection('hobby').doc('4').set({
    //  'name': 'Masa Oyunları',
    //  'categoryId': 4,
    //});

    //// Kategorileri ekleyelim
    //await _firestore.collection('category').doc('1').set({
    //  'name': 'Futbol',
    //  'categoryId': 1,
    //});
    //await _firestore.collection('category').doc('2').set({
    //  'name': 'Basketbol',
    //  'categoryId': 1,
    //});
    //await _firestore.collection('category').doc('3').set({
    //  'name': 'Voleybol',
    //  'categoryId': 1,
    //});
    //await _firestore.collection('category').doc('4').set({
    //  'name': 'Tenis',
    //  'categoryId': 1,
    //});
    //await _firestore.collection('category').doc('5').set({
    //  'name': 'Yüzme',
    //  'categoryId': 1,
    //});
    //// -------------
    //
    //
    //await _firestore.collection('category').doc('6').set({
    //  'name': 'Minecraft',
    //  'categoryId': 2,
    //});
    //await _firestore.collection('category').doc('7').set({
    //  'name': 'Fortnite',
    //  'categoryId': 2,
    //});
    //await _firestore.collection('category').doc('8').set({
    //  'name': 'League of Legends',
    //  'categoryId': 2,
    //});
    //await _firestore.collection('category').doc('9').set({
    //  'name': 'Counter-Strike 2',
    //  'categoryId': 2,
    //});
    //await _firestore.collection('category').doc('10').set({
    //  'name': 'Call Of Duty',
    //  'categoryId': 2,
    //});
    //// ------------
    //await _firestore.collection('category').doc('11').set({
    //  'name': 'Clash Royale',
    //  'categoryId': 3,
    //});
    //await _firestore.collection('category').doc('12').set({
    //  'name': 'Call Of Duty Mobile',
    //  'categoryId': 3,
    //});
    //await _firestore.collection('category').doc('13').set({
    //  'name': 'League of Legends',
    //  'categoryId': 3,
    //});
    //await _firestore.collection('category').doc('14').set({
    //  'name': 'Among Us',
    //  'categoryId': 3,
    //});
    //await _firestore.collection('category').doc('15').set({
    //  'name': 'Clash Of Clans',
    //  'categoryId': 3,
    //});
    //// -----
    await _firestore.collection('category').doc('21').set({
      'name': 'Vücüt Geliştirme',
      'categoryId': 1,
    });
    await _firestore.collection('category').doc('22').set({
      'name': 'Güreş',
      'categoryId': 1,
    });
    await _firestore.collection('category').doc('23').set({
      'name': 'Boks',
      'categoryId': 1,
    });
    await _firestore.collection('category').doc('24').set({
      'name': 'Bisiklet Sürme',
      'categoryId': 1,
    });
    await _firestore.collection('category').doc('25').set({
      'name': 'Hentbol',
      'categoryId': 1,
    });

    await _firestore.collection('category').doc('26').set({
      'name': 'Valorant',
      'categoryId': 2,
    });
    await _firestore.collection('category').doc('27').set({
      'name': 'Rainbow Six Siege',
      'categoryId': 2,
    });
    await _firestore.collection('category').doc('28').set({
      'name': 'Battifield',
      'categoryId': 2,
    });
    await _firestore.collection('category').doc('29').set({
      'name': 'GTA 5',
      'categoryId': 2,
    });
    await _firestore.collection('category').doc('30').set({
      'name': 'Wolfteam',
      'categoryId': 2,
    });


    await _firestore.collection('category').doc('31').set({
      'name': 'Roblox',
      'categoryId': 3,
    });
    await _firestore.collection('category').doc('32').set({
      'name': 'Tabu',
      'categoryId': 3,
    });
    await _firestore.collection('category').doc('33').set({
      'name': 'Kafa Topu 2',
      'categoryId': 3,
    });
    await _firestore.collection('category').doc('34').set({
      'name': 'Fifa',
      'categoryId': 3,
    });
    await _firestore.collection('category').doc('35').set({
      'name': 'Vector',
      'categoryId': 3,
    });

    await _firestore.collection('category').doc('36').set({
      'name': 'Jenga',
      'categoryId': 4,
    });
    await _firestore.collection('category').doc('37').set({
      'name': 'Tabu',
      'categoryId': 4,
    });
    await _firestore.collection('category').doc('38').set({
      'name': 'Risk',
      'categoryId': 4,
    });
    await _firestore.collection('category').doc('39').set({
      'name': 'Scrabble',
      'categoryId': 4,
    });
    await _firestore.collection('category').doc('40').set({
      'name': 'Upwords',
      'categoryId': 4,
    });


    //print('Hobiler ve kategoriler eklendi.');
  }

}
