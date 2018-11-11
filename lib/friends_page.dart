import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class FriendsPage extends StatefulWidget {
  User user;
  FriendsPage(this.user);
  @override
  _FriendsPageStates createState() => _FriendsPageStates();
}

class _FriendsPageStates extends State<FriendsPage> {
  List<User> friends = [User("LOADING...", "", false)];

  @override
  void initState() {
    // TODO: Improve Loading Consitency (Possibly by unifying listeners)
    super.initState();
    Firestore.instance
        .collection("users")
        .document(widget.user.email)
        .snapshots()
        .listen((userDocSnapshot) {
      List<User> updatedFriends = [];
      setState(() { // TODO: Fix Memory Leak Risk
        friends = [User("LOADING...", "", false)];
      });
      userDocSnapshot.data["friends"].forEach((friend) {
        friend.snapshots().listen((friendDocSnapshot) {
          User newFriend = User(
              friendDocSnapshot.data["name"],
              friendDocSnapshot.data["email"],
              friendDocSnapshot.data["hasEvent"]);
          Firestore.instance
              .collection("events")
              .document(friendDocSnapshot.data["email"])
              .snapshots()
              .listen((eventDocSnapshot) {
            newFriend.sub = "Let's " +
                eventDocSnapshot.data["action"] +
                " at " +
                eventDocSnapshot.data["location"];
          });
          friends.add(newFriend);
        });
        setState(() {
          friends = updatedFriends;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index >= friends.length * 2 - 1) {
            return null;
          } else {
            return index % 2 == 0
                ? ListTile(
                    title: Text(friends[index ~/ 2].name),
                    subtitle: Text(friends[index ~/ 2].hasEvent
                        ? friends[index ~/ 2].sub
                        : friends[index ~/ 2].email),
                    trailing: friends[index ~/ 2].hasEvent
                        ? FlatButton(
                            child: Text(
                              "I'LL GO",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                            onPressed: () {
                              Firestore.instance
                                  .collection("events")
                                  .document(friends[index ~/ 2].email)
                                  .get()
                                  .then((eventDoc) {
                                List<DocumentReference> newAttending =
                                    <DocumentReference>[];
                                newAttending
                                  ..addAll(eventDoc.data["attending"])
                                  ..add(Firestore.instance
                                      .collection("events")
                                      .document(widget.user.email));
                                Firestore.instance
                                    .collection("events")
                                    .document(friends[index ~/ 2].email)
                                    .updateData({"attending": newAttending});
                              });
                            })
                        : null,
                  )
                : Divider();
          }
        },
      ),
    );
  }
}
