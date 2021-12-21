// ignore_for_file: prefer_const_constructors, avoid_print, unnecessary_null_comparison, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/user.dart';
import 'package:twitter_clone/screens/user/edit.dart';
import 'package:twitter_clone/screens/user/home.dart';
import 'package:twitter_clone/screens/posts/add_post.dart';
import 'package:twitter_clone/screens/signup.dart';
import 'package:twitter_clone/screens/user/profile.dart';
import 'package:twitter_clone/screens/user/replies.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    print(user);
    if (user == null) {
      //show auth system routes
      return Signup();
    }

    //show main system routes
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Signup(),
        '/home': (context) => Home(),
        '/add': (context) => Add(),
        '/profile': (context) => Profile(),
        '/edit': (context) => Edit(),
        '/replies': (context) => Replies(),
      },
    );
  }
}
