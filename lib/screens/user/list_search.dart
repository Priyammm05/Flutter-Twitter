// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone/models/user.dart';

class ListSearch extends StatefulWidget {
  const ListSearch({Key? key}) : super(key: key);

  @override
  _ListSearchState createState() => _ListSearchState();
}

class _ListSearchState extends State<ListSearch> {
  @override
  Widget build(BuildContext context) {
    final users = Provider.of<List<UserModel>?>(context) ?? [];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        final user = users[index];
        return InkWell(
          onTap: () =>
              Navigator.pushNamed(context, '/profile', arguments: user.id),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    user.profileImageUrl != ''
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(user.profileImageUrl as String),
                          )
                        : CircleAvatar(
                            child: Icon(
                              Icons.person,
                              size: 20,
                            ),
                          ),
                    SizedBox(width: 10),
                    Text(user.name as String),
                  ],
                ),
              ),
              Divider(thickness: 1),
            ],
          ),
        );
      },
    );
  }
}
