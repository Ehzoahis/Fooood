import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name, email, sub = "";
  List<DocumentReference> friends;
  Key _key = UniqueKey();
  bool hasEvent;

  User(this.name, this.email, this.hasEvent);
}
