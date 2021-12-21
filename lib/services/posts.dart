// ignore_for_file: prefer_is_empty, unnecessary_null_in_if_null_operators

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/services/user.dart';
import 'package:quiver/iterables.dart';

class PostService {
  List<PostModel> _postLists(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return PostModel(
        id: doc.id,
        text: (doc.data() as Map)['text'] ?? '',
        creator: (doc.data() as Map)['creator'] ?? '',
        retweet: (doc.data() as Map)['retweet'] ?? false,
        originalId: (doc.data() as Map)['originalId'] ?? null,
        ref: doc.reference,
        timestamp: (doc.data() as Map)['timestamp'] ?? 0,
      );
    }).toList();
  }

  PostModel _postSnapshot(DocumentSnapshot snapshot) {
    return snapshot.exists
        ? PostModel(
            id: snapshot.id,
            text: (snapshot.data() as Map)['text'] ?? '',
            creator: (snapshot.data() as Map)['creator'] ?? '',
            retweet: (snapshot.data() as Map)['retweet'] ?? false,
            originalId: (snapshot.data() as Map)['originalId'] ?? null,
            ref: snapshot.reference,
            timestamp: (snapshot.data() as Map)['timestamp'] ?? 0,
          )
        : null as PostModel;
  }

  Future savePost(text) async {
    await FirebaseFirestore.instance.collection('posts').add({
      'text': text,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'retweet': false,
    });
  }

  Future reply(PostModel post, String text) async {
    if (text == '') {
      return;
    }
    await post.ref.collection('replies').add({
      'text': text,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'retweet': false,
    });
  }

  Future likePost(PostModel post, bool current) async {
    if (current) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .collection('likes')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
    }

    if (!current) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .collection('likes')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({});
    }
  }

  Future retweet(PostModel post, bool current) async {
    if (current) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .collection('retweets')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();

      await FirebaseFirestore.instance
          .collection('posts')
          .where('originalId', isEqualTo: post.id)
          .where('creator', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        if (value.docs.length == 0) {
          return;
        }
        FirebaseFirestore.instance
            .collection('posts')
            .doc(value.docs[0].id)
            .delete();
      });
    }

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .collection('retweets')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({});

    await FirebaseFirestore.instance.collection('posts').add({
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'retweet': true,
      'originalId': post.id,
    });
  }

  Stream<bool> getCurrentUserLike(PostModel post) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .collection('likes')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.exists;
    });
  }

  Stream<bool> getCurrentUserRetweet(PostModel post) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .collection('retweets')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.exists;
    });
  }

  Stream<List<PostModel>> getPosts(uid) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('creator', isEqualTo: uid)
        .snapshots()
        .map(_postLists);
  }

  Future<PostModel> getPostById(String id) async {
    DocumentSnapshot postSnap =
        await FirebaseFirestore.instance.collection('posts').doc(id).get();
    return _postSnapshot(postSnap);
  }

  Future<List<PostModel>> getReplies(PostModel post) async {
    QuerySnapshot querySnapshot = await post.ref
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .get();

    return _postLists(querySnapshot);
  }

  Future<List<PostModel>> getFeed() async {
    List<String> userFollowing = await UserService()
        .getUserFollowing(FirebaseAuth.instance.currentUser!.uid);

    var splitUserFollowing = partition<dynamic>(userFollowing, 10);

    List<PostModel> feedList = [];

    for (var i = 0; i < splitUserFollowing.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('creator', whereIn: splitUserFollowing.elementAt(i))
          .orderBy('timestamp', descending: true)
          .get();

      feedList.addAll(_postLists(querySnapshot));
    }

    feedList.sort((a, b) {
      var aDate = a.timestamp;
      var bDate = b.timestamp;
      return bDate.compareTo(aDate);
    });

    return feedList;
  }
}
