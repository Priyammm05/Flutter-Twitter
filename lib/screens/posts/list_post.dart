// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unused_local_variable, prefer_final_fields, unnecessary_null_comparison, must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/services/posts.dart';
import 'package:twitter_clone/services/user.dart';

class ListPost extends StatefulWidget {
  PostModel? post;
  ListPost(this.post);

  @override
  _ListPostState createState() => _ListPostState();
}

class _ListPostState extends State<ListPost> {
  UserService _userService = UserService();
  PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    List<PostModel> posts = Provider.of<List<PostModel>?>(context) ?? [];

    if (widget.post != null) {
      posts.insert(0, widget.post as PostModel);
    }
    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          final post = posts[index];
          if (post.retweet) {
            return FutureBuilder(
                future: _postService.getPostById(post.originalId as String),
                builder: (BuildContext context,
                    AsyncSnapshot<PostModel> snapshotPost) {
                  if (!snapshotPost.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return MainPost(
                    userService: _userService,
                    post: snapshotPost.data as PostModel,
                    postService: _postService,
                    retweet: true,
                  );
                });
          }
          return MainPost(
            userService: _userService,
            post: post,
            postService: _postService,
            retweet: false,
          );
        });
  }
}

class MainPost extends StatelessWidget {
  const MainPost({
    Key? key,
    required UserService userService,
    required this.post,
    required PostService postService,
    required this.retweet,
  })  : _userService = userService,
        _postService = postService,
        super(key: key);

  final UserService _userService;
  final PostModel post;
  final PostService _postService;
  final bool retweet;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _userService.getUserInfo(post.creator),
        builder: (BuildContext context, AsyncSnapshot<UserModel> snapshotUser) {
          if (!snapshotUser.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return StreamBuilder(
            stream: _postService.getCurrentUserLike(post),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshotLike) {
              if (!snapshotLike.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return StreamBuilder(
                  stream: _postService.getCurrentUserRetweet(post),
                  builder: (BuildContext context,
                      AsyncSnapshot<bool> snapshotRetweet) {
                    if (!snapshotRetweet.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Card(
                      child: ListTile(
                        title: Padding(
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (snapshotRetweet.data! || retweet)
                                Text('Retweet'),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  snapshotUser.data!.profileImageUrl != ''
                                      ? CircleAvatar(
                                          radius: 25,
                                          backgroundImage: NetworkImage(
                                              snapshotUser.data!.profileImageUrl
                                                  as String),
                                        )
                                      : CircleAvatar(
                                          radius: 25,
                                          child: Icon(Icons.person, size: 30),
                                        ),
                                  SizedBox(width: 10),
                                  Text(snapshotUser.data!.name as String),
                                ],
                              ),
                            ],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.text,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    post.timestamp.toDate().toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/replies',
                                              arguments: post);
                                        },
                                        icon: Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _postService.retweet(
                                              post, snapshotRetweet.data!);
                                        },
                                        icon: Icon(
                                          snapshotRetweet.data!
                                              ? Icons.cancel
                                              : Icons.repeat,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _postService.likePost(
                                              post, snapshotLike.data as bool);
                                        },
                                        icon: Icon(
                                          snapshotLike.data!
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_alt_outlined,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            },
          );
        });
  }
}
