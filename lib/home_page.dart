import 'package:flutter/material.dart';
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  dynamic actionSelected = "Eat", hallSelected = "Carson's Market";
  List<String> actionsLets;
  User user;
  HomePage(this.user, this.actionsLets);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isActive = false;
  String allAttending = "loading...";

  List<DropdownMenuItem> _hallMenuBuilder(List<String> list) {
    List<DropdownMenuItem> halls = [];
    list.forEach((hall) {
      halls.add(
        DropdownMenuItem(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(hall),
          ),
          value: hall,
        ),
      );
    });
    return halls;
  }

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection("users")
        .document(widget.user.email)
        .snapshots()
        .listen((userEventDoc) {
      setState(() {
        isActive = userEventDoc.data["hasEvent"];
      });
    });
    Firestore.instance
        .collection("events")
        .document(widget.user.email)
        .snapshots()
        .listen((userEventDoc) {
      String attending = "Active: " +
          userEventDoc.data["action"] +
          " at " +
          userEventDoc.data["location"] +
          " with you: ";
      setState(() {
        allAttending = attending + "none";
      });
      userEventDoc.data["attending"].forEach((friend) {
        friend.get().then((friendSnapshot) {
          attending += (friendSnapshot.data["name"] + ", ");
          debugPrint(attending);
          setState(() {
            allAttending = attending.substring(0, attending.length - 2);
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> dropdownOptions = ["Eat"];
    widget.actionsLets.forEach((option) {
      dropdownOptions.add(option);
    });

    return Container(
      key: Key("Home"),
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(isActive ? 4.0 : 0.0),
                    child: isActive
                        ? Column(children: <Widget>[
                            Container(
                              child: Text(
                                allAttending,
                                maxLines: null,
                                softWrap: true,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ])
                        : null,
                  ),
                  Container(padding: EdgeInsets.all(8.0)),
                  Text("Let's"),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Let's"),
                          items: dropdownOptions
                              .map<DropdownMenuItem<String>>((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(option),
                              ),
                            );
                          }).toList(),
                          onChanged: (newSelected) {
                            setState(() {
                              widget.actionSelected = newSelected;
                            });
                          },
                          value: widget.actionSelected,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: null,
                  ),
                  Text("At"),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: Text("At"),
                          // TODO: Implement Google Places for Location Selection
                          items: <String>[
                            "Carson's Market",
                            "Four Lakes Market",
                            "Gordon Avenue Market",
                            "Liz's Market",
                            "Newell's Deli",
                            "Rheta's Market",
                          ].map((String hall) {
                            return DropdownMenuItem<String>(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(hall),
                              ),
                              value: hall,
                            );
                          }).toList(),
                          value: widget.hallSelected,
                          onChanged: (newSelected) {
                            setState(() {
                              widget.hallSelected = newSelected;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
