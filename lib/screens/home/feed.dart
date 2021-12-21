// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/screens/posts/list_post.dart';
import 'package:twitter_clone/services/posts.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return FutureProvider.value(
      value: _postService.getFeed(),
      initialData: null,
      child: Scaffold(
        body: ListPost(null),
      ),
    );
  }
}
