// ignore_for_file: unnecessary_null_comparison, prefer_final_fields, unused_local_variable

import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/image.dart';

class UserService {
  ImageService _imageService = ImageService();

  List<UserModel> _userFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModel(
        id: doc.id,
        name: (doc.data() as Map)['name'] ?? '',
        email: (doc.data() as Map)['email'] ?? '',
        profileImageUrl: (doc.data() as Map)['profileImageUrl'] ?? '',
        bannerImageUrl: (doc.data() as Map)['bannerImageUrl'] ?? '',
      );
    }).toList();
  }

  UserModel _userFromFirebaseSnapshot(DocumentSnapshot snapshot) {
    return snapshot != null
        ? UserModel(
            id: snapshot.id,
            name: (snapshot.data() as Map)['name'],
            email: (snapshot.data() as Map)['email'],
            profileImageUrl: (snapshot.data() as Map)['profileImageUrl'],
            bannerImageUrl: (snapshot.data() as Map)['bannerImageUrl'],
          )
        : null as UserModel;
  }

  Stream<UserModel> getUserInfo(uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(_userFromFirebaseSnapshot);
  }

  Stream<List<UserModel>> queryByName(search) {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .startAt([search])
        .endAt([search + '\uf8ff'])
        .limit(10)
        .snapshots()
        .map(_userFromQuerySnapshot);
  }

  Stream<bool> isFollowing(uid, otherId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(otherId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> followUser(uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(uid)
        .set({});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({});
  }

  Future<void> unfollowUser(uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(uid)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  }

  Future<List<String>> getUserFollowing(uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    final users = querySnapshot.docs.map((doc) => doc.id).toList();
    return users;    
  }

  Future<void> updateProfile(
      File _bannerImage, File _profileImage, String name) async {
    String profileImageUrl = '';
    String bannerImageUrl = '';

    if (_bannerImage != null) {
      bannerImageUrl = await _imageService.uploadFile(
        _bannerImage,
        'user/profile/${FirebaseAuth.instance.currentUser!.uid}/banner',
      );
    }
    if (_profileImage != null) {
      profileImageUrl = await _imageService.uploadFile(
        _profileImage,
        'user/profile/${FirebaseAuth.instance.currentUser!.uid}/profile',
      );
    }

    Map<String, Object> data = HashMap();
    if (name != '') data['name'] = name;
    if (profileImageUrl != '') data['profileImageUrl'] = profileImageUrl;
    if (bannerImageUrl != '') data['bannerImageUrl'] = bannerImageUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(data);
  }
}
