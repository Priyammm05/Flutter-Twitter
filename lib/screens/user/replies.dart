// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_final_fields, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/post.dart';
import 'package:twitter_clone/screens/posts/list_post.dart';
import 'package:twitter_clone/services/posts.dart';

class Replies extends StatefulWidget {
  const Replies({Key? key}) : super(key: key);

  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  PostService _postService = PostService();
  String text = "";
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    PostModel args = ModalRoute.of(context)!.settings.arguments as PostModel;

    return FutureProvider.value(
      initialData: null,
      value: _postService.getReplies(args),
      child: Container(
        child: Scaffold(
          body: Container(
            child: Column(
              children: [
                Expanded(
                  child: ListPost(args),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    children: [
                      Form(
                        child: TextFormField(
                          controller: _textController,
                          onChanged: (val) {
                            setState(() {
                              text = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Reply',
                            fillColor: Colors.black12,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green,
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            await _postService.reply(args, text);
                            _textController.text = '';
                            setState(() {
                              text = '';
                            });
                          },
                          child: Text(
                            'REPLY',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
