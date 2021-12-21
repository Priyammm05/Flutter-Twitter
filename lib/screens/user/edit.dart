// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, deprecated_member_use, prefer_final_fields

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitter_clone/services/user.dart';

class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  UserService _userService = UserService();

  String? name;

  File? _profileImage;
  File? _bannerImage;
  final picker = ImagePicker();

  Future getImage(int type) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null && type == 0) {
        _profileImage = File(pickedFile.path);
      }
      if (pickedFile != null && type == 1) {
        _bannerImage = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [
          FlatButton(
            onPressed: () async {
              await _userService.updateProfile(
                _bannerImage as File,
                _profileImage as File,
                name as String,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Form(
          child: Column(
            children: [
              Card(
                child: FlatButton(
                  onPressed: () => getImage(0),
                  child: _profileImage == null
                      ? Icon(Icons.person)
                      : Image.file(
                          _profileImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 15),
              Card(
                child: FlatButton(
                  onPressed: () => getImage(1),
                  child: _bannerImage == null
                      ? Icon(Icons.person)
                      : Image.file(
                          _bannerImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Username',
                  fillColor: Colors.black12,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    name = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
