import 'package:flutter/material.dart';
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

@deprecated
class ActiveAlert extends StatefulWidget {
  User user;
  ActiveAlert(this.user);
  @override
  _ActiveAlertState createState() => _ActiveAlertState();
}

class _ActiveAlertState extends State<ActiveAlert> {
  static const platform = const MethodChannel("NOTIFICATION_CHANNEL");
  static final Firestore firestoreInstance = Firestore.instance;
  Widget _alert;

  @override
  Widget build(BuildContext context) {
    firestoreInstance
        .collection("users")
        .where("friends", arrayContains: widget.user.email)
        .where("hasEvent", isEqualTo: true)
        .snapshots()
        .listen((activeFriendList) {
      String outputString = "";
      activeFriendList.documents.forEach((friend) {
        outputString += friend.data["name"] + ", ";
      });

      setState(() {
        _alert = outputString.length == 0
            ? null
            : Text(outputString.substring(0, outputString.length - 2) +
                " " +
                (activeFriendList.documents.length == 1 ? "is" : "are") +
                " eating.");
      });
    });
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.all(_alert != null ? 8.0 : 0.0),
            color: Colors.grey,
            child: _alert,
          ),
        ),
      ],
    );
  }
}
