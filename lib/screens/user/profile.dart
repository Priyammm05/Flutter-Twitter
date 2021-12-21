// ignore_for_file: prefer_const_constructors, prefer_final_fields, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/screens/posts/list_post.dart';
import 'package:twitter_clone/services/posts.dart';
import 'package:twitter_clone/services/user.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  PostService _postService = PostService();
  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final String uid = ModalRoute.of(context)!.settings.arguments as String;

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: _userService.isFollowing(
              FirebaseAuth.instance.currentUser!.uid, uid),
          initialData: null,
        ),
        StreamProvider.value(
          value: _postService.getPosts(uid),
          initialData: null,
        ),
        StreamProvider.value(
          value: _userService.getUserInfo(uid),
          initialData: null,
        ),
      ],
      child: Scaffold(
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) {
              return [
                SliverAppBar(
                  floating: false,
                  backgroundColor: Colors.green,
                  pinned: true,
                  expandedHeight: 130,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Provider.of<UserModel?>(context)
                                ?.profileImageUrl ==
                            null
                        ? Center(
                            child: Text(
                            'Wanna Add BG Image',
                            style: TextStyle(color: Colors.white),
                          ))
                        : Image.network(
                            Provider.of<UserModel?>(context)?.bannerImageUrl ??
                                '',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Provider.of<UserModel?>(context)
                                            ?.profileImageUrl ==
                                        null
                                    ? Center(
                                        child: CircleAvatar(
                                          radius: 35,
                                          child: Icon(Icons.people),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 35,
                                        backgroundImage: NetworkImage(
                                          Provider.of<UserModel?>(context)
                                                  ?.profileImageUrl ??
                                              '',
                                        ),
                                      ),
                                if (FirebaseAuth.instance.currentUser!.uid ==
                                    uid)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/edit');
                                    },
                                    child: Text('Edit Profile'),
                                  )
                                else if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        uid &&
                                    (Provider.of<bool?>(context) ?? true))
                                  TextButton(
                                    onPressed: () {
                                      _userService.unfollowUser(uid);
                                    },
                                    child: Text('Unfollow'),
                                  )
                                else
                                  TextButton(
                                    onPressed: () {
                                      _userService.followUser(uid);
                                    },
                                    child: Text('Follow'),
                                  ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  Provider.of<UserModel?>(context)?.name ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: ListPost(null),
          ),
        ),
      ),
    );
  }
}
