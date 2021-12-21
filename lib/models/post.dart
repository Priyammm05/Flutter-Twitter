import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String creator;
  final String text;
  final String? originalId;
  final bool retweet;
  DocumentReference ref;
  final Timestamp timestamp;

  PostModel({
    required this.id,
    required this.creator,
    required this.text,
    required this.originalId,
    required this.retweet,
    required this.ref, 
    required this.timestamp,
  });
}
