import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wean_app/common/toastUtils.dart';
import 'package:wean_app/models/ConversationModel.dart';
import 'package:wean_app/models/appPreferencesModel.dart';
import 'package:wean_app/models/ratingsModel.dart';
import 'package:wean_app/models/userModel.dart';
import 'package:wean_app/models/yardItemModel.dart';

class FirebaseDBServices {
  static const USERS = 'users';
  static const REPORT_PRODUCT = 'report_product';
  static const CONVERSATIONS = 'conversations';
  FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference? yard;
  CollectionReference? filteredYard;
  CollectionReference? items;
  CollectionReference? preferences;
  CollectionReference? userDetails;
  CollectionReference? ratings;
  Stream<QuerySnapshot?>? yardDataStream;
  Stream<QuerySnapshot?>? filterDataStream;
  Stream<QuerySnapshot?>? itemDataStream;
  Stream<QuerySnapshot?>? ratingsDataStream;
  Stream<QuerySnapshot?>? userStream;

  loadYard() {
    yard = _db.collection('items');
    DateTime _limit = DateTime.now().subtract(Duration(hours: 24));
    yardDataStream = yard
        ?.where('updated_at',
            isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                _limit.millisecondsSinceEpoch))
        .orderBy('updated_at', descending: true)
        .snapshots();
  }

  loadYardBy(String userCountry, List<String> categories, String selectedCity) {
    // print("userCountry $userCountry");
    // print("categories ${categories.join(",")}");
    // print("selectedCity ${selectedCity}");
    //category empty and city all
    if (categories.isEmpty && selectedCity == 'All') {
      yard = _db.collection('items');
      DateTime _limit = DateTime.now().subtract(Duration(hours: 24));
      yardDataStream = yard
          ?.where('updated_at',
              isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                  _limit.millisecondsSinceEpoch))
          .where('country', isEqualTo: userCountry)
          .orderBy('updated_at', descending: true)
          .snapshots();
    }
    // category empty and city is somewhere
    else if (categories.isEmpty && selectedCity != 'All') {
      yard = _db.collection('items');
      DateTime _limit = DateTime.now().subtract(Duration(hours: 24));
      yardDataStream = yard
          ?.where('updated_at',
              isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                  _limit.millisecondsSinceEpoch))
          .where('country', isEqualTo: userCountry)
          .where('city', isEqualTo: selectedCity)
          .orderBy('updated_at', descending: true)
          .snapshots();
    }
    //category not empty and city all
    else if (categories.isNotEmpty && selectedCity == 'All') {
      yard = _db.collection('items');
      DateTime _limit = DateTime.now().subtract(Duration(hours: 24));
      yardDataStream = yard
          ?.where('updated_at',
              isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                  _limit.millisecondsSinceEpoch))
          .where('country', isEqualTo: userCountry)
          .where('category', whereIn: categories)
          .orderBy('updated_at', descending: true)
          .snapshots();
    }
    // category not empty and city somewhere
    else if (categories.isNotEmpty && selectedCity != 'All') {
      yard = _db.collection('items');
      DateTime _limit = DateTime.now().subtract(Duration(hours: 24));
      yardDataStream = yard
          ?.where('updated_at',
              isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                  _limit.millisecondsSinceEpoch))
          .where('country', isEqualTo: userCountry)
          .where('city', isEqualTo: selectedCity)
          .where('category', whereIn: categories)
          .orderBy('updated_at', descending: true)
          .snapshots();
    }
  }

  loadReview(String userId) {
    ratings = _db.collection('ratings');
    ratingsDataStream = ratings
        ?.where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Future<int>? getRatingLength(String userId) {
    ratings = _db.collection('ratings');
    return ratings
        ?.where('ownerId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .length;
  }

  Future<void> addOrder(YardItem item) async {
    yard = _db.collection('items');
    yard!.add(item.toJson()).then((value) {
      // print("item added");
      Toast.showSuccess('Successfully uploaded');
    }).catchError((error) {
      // print("error adding yard");
      Toast.showError("Error adding yard");
    });
  }

  Future<void> addReview(RatingsModel model) async {
    int ratingExist = await checkExist(model.ownerId!, model.buyerId!);
    if (ratingExist > 0) {
      Toast.showInfo('Your review has been updated.');
      updateRating(model);
    } else {
      ratings = _db.collection('ratings');
      ratings!.add(model.toJson()).then((value) {
        // print("review added");
        Toast.showSuccess('Thanks for your review.');
      }).catchError((error) {
        // print("error adding review");
      });
    }
  }

  Future checkExist(String ownerId, String buyerId) async {
    ratings = _db.collection('ratings');
    var streams = await ratings
        ?.where('ownerId', isEqualTo: ownerId)
        .where('buyerId', isEqualTo: buyerId)
        .get();
    return streams!.size;
  }

  Future updateRating(RatingsModel model) async {
    // print("updating rate");
    ratings = _db.collection('ratings');
    ratings
        ?.where('ownerId', isEqualTo: model.ownerId)
        .where('buyerId', isEqualTo: model.buyerId)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.update({
          'rating': model.rating,
          'buyerReview': model.buyerReview,
          'updatedAt': Timestamp.now()
        });
      });
    });
  }

  Future<void> moveToDeleteItem(YardItem item, String? index) async {
    yard = _db.collection('deleted_items');
    yard!.doc(index).set(item.toJson()).then((value) {
      // print("item added");
      deleteYardItem(index);
    }).catchError((error) {
      // print("error adding yard");
    });
  }

  deleteYardItem(String? index) async {
    await _db
        .collection('items')
        .doc(index)
        .delete()
        .then((value) => addDeleteFlagToConvo(index));
  }

  addDeleteFlagToConvo(String? productId) {
    if (productId != null && productId.isNotEmpty) {
      _db
          .collection(CONVERSATIONS)
          .where('productId', isEqualTo: productId)
          .get()
          .then((value) => value.docs.forEach((element) {
                element.reference
                    .set({'isProductDeleted': true}, SetOptions(merge: true));
              }));
    }
  }

  reappearYardItem(String? index) async {
    await _db
        .collection('items')
        .doc(index)
        .update({'updated_at': Timestamp.now()});
  }

  loadItemsByUserId(String ownerId) {
    items = _db.collection('items');
    itemDataStream = items
        ?.where("ownerId", isEqualTo: ownerId)
        .orderBy('updated_at', descending: true)
        .snapshots();
  }

  getCategories() {}

  filterByCategory(List<String> categories) {
    yard = _db.collection('items');
    DateTime _limit = DateTime.now().subtract(Duration(hours: 24));
    yardDataStream = yard
        ?.where('updated_at',
            isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                _limit.millisecondsSinceEpoch))
        .where('category', whereIn: categories)
        .orderBy('updated_at', descending: true)
        .snapshots();
  }

  static AppPreferences? appPreferences;

  Future<AppPreferences> loadPreferences() async {
    preferences = _db.collection('preferences');
    var data = await preferences?.doc('preferences').get();
    var map = data?.data() as Map<String, dynamic>;
    appPreferences = AppPreferences.fromJson(map);
    // print(map);
    return appPreferences ??
        AppPreferences(
            languages: [], categories: [], countries: [], reportReasons: []);
  }

  Future<UserModel> loadBusinessCard() async {
    UserModel user;
    //TODO:replace below code to fitch the real user data from users collection
    // var userId = FirebaseAuth.instance.currentUser?.uid;
    // var userDocunent =await _db.collection('users').doc(userId).get();
    var userDoc = await _db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    // print(user.uuid);
    return user;
  }

  Future<UserModel> loadUser(String userId) async {
    UserModel user;
    var userDoc = await _db.collection('users').doc(userId).get();
    user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    // print(user.uuid);
    return user;
  }

  Future updateBusinessCardInfo(UserModel? user) async {
    var jsonUser = user?.toJson();
    await _db.collection('users').doc(user?.uuid).set(jsonUser ?? {});
  }

  Future updateReadStatus(
    DocumentReference _docRef,
    String sentById,
  ) async {
    log('UpdateReadStatus getting invoked');
    try {
      _docRef
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('sentById', isEqualTo: sentById)
          .get()
          .then((value) {
        log(value.docs.toString());
        value.docs.forEach((element) {
          element.reference.update({'isRead': true});
          log(element.data().toString());
        });
      });
    } on FirebaseException catch (e) {
      log(e.message.toString());
    }
  }

  Future submitUserDetails(
      {/* required File image, */
      required Map<String, dynamic> data,
      required String uid}) async {
    // String url = await CloudStorageServices().uploadFile(image);
    // print("got the url : ${url}");
    // data.addAll({"photo_url": url});
    return _db.collection(USERS).doc(uid).set(data);
  }

  Future addEmptyDetails(
      {required Map<String, dynamic> data, required String uid}) async {
    return _db.collection(USERS).doc(uid).set(data);
  }

  Future<DocumentReference> createConversation(
      String productId,
      String ownerId,
      String senderId,
      String ownerName,
      String senderName,
      DocumentReference productReference) async {
    final response = await checkForChat(productId, senderId);
    if (response != null) {
      return response.reference;
    } else {
      return _db.collection(CONVERSATIONS).add({
        "productId": productId,
        "ownerId": ownerId,
        "ownerName": ownerName,
        "senderId": senderId,
        "senderName": senderName,
        "productReference": productReference,
        "lastMessageAt": Timestamp.now(),
      });
    }
  }

  Stream<QuerySnapshot> fetchChat(String chatRoomId) {
    return _db
        .collection(CONVERSATIONS)
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('dateTime', descending: false)
        .snapshots();
  }

  Future<DocumentReference> sendMessage(
      String chatRoomId, Map<String, dynamic> data) {
    return _db
        .collection(CONVERSATIONS)
        .doc(chatRoomId)
        .collection('messages')
        .add(data);
  }

  Future getNumberOfChat(String productId, String ownerId) async {
    var result = await _db
        .collection(CONVERSATIONS)
        .where(
          'ownerId',
          isEqualTo: ownerId,
        )
        .where('productId', isEqualTo: productId)
        .get();
    // print("${result.size}");
    return result.size;
  }

  saveLastMessage(String chatRoomId, String message) async {
    final dateTime = DateTime.now();
    await _db
        .collection(CONVERSATIONS)
        .doc(chatRoomId)
        .update({"lastMessage": message, "lastMessageAt": dateTime});
  }

  Future<QueryDocumentSnapshot?> checkForChat(
      String productId, String senderId) async {
    try {
      final response = await _db
          .collection(CONVERSATIONS)
          .get()
          .then<QueryDocumentSnapshot?>((value) => value.docs
              .where((element) => element.data()['productId'] == productId)
              .toList()
              .firstWhere((element) => element.data()['senderId'] == senderId));
      return response;
    } catch (e) {
      return null;
    }
  }

  Future getProfileImageUrl(String uid) async {
    DocumentSnapshot documentSnapshot =
        await _db.collection(USERS).doc(uid).get();
    Map user = documentSnapshot.data() as Map;
    return user['photo_url'];
  }

  Future updateFCMToken(String fcmToken, [bool toAdd = true]) async {
    try {
      await _db.collection(USERS).doc(_auth.currentUser!.uid).update({
        'FCM Tokens': toAdd
            ? FieldValue.arrayUnion([fcmToken])
            : FieldValue.arrayRemove([fcmToken]),
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Future<DocumentReference> reportProduct(Map<String, dynamic> data) async {
    return _db.collection(REPORT_PRODUCT).add(data);
  }

  Future<YardItemInfo> loadYardById(String id) async {
    var data = await _db.collection('items').doc(id).get();

    var item = YardItem.fromDocumentSnapshot(data);

    return YardItemInfo(item: item, isHistory: false);
  }

  Future<ConversationModel> getConversationModelById(String id) async {
    var data = await _db.collection(CONVERSATIONS).doc(id).get();
    var convoModel = ConversationModel.fromDocSnapshot(data);
    return convoModel;
  }
}
