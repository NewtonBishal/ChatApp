import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var isLoading = false;

  void _submitForm(String email, String password, String username, File image,
      bool isLogin, BuildContext ctx) async {
    UserCredential _authResult;
    try {
      setState(() {
        isLoading = true;
      });
      if (isLogin) {
        _authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        _authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(_authResult.user.uid + '.jpg');

        await ref.putFile(image);

        final image_url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_authResult.user.uid)
            .set(
                {'username': username, 'email': email, 'image_url': image_url});
      }
    } on FirebaseAuthException catch (err) {
      var message = 'An error occured,please check your credentials';

      if (err.message != null) {
        message = err.message;
        Scaffold.of(ctx).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ));
      }
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: AuthForm(_submitForm, isLoading));
  }
}
