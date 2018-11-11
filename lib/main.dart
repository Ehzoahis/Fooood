import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'active_alert.dart';
import 'home_page.dart';
import 'friends_page.dart';
import 'presets_page.dart';
import 'user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fooood',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMainPage(title: 'Fooood'),
    );
  }
}

class MyMainPage extends StatefulWidget {
  MyMainPage({Key key, this.title}) : super(key: key);
  final String title;

  // TODO: Reduce Listeners
  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  // static const platform = const MethodChannel("NOTIFICATION_CHANNEL");
  // static final Firestore firestoreInstance = Firestore.instance;
  int _pageIndex = 0;
  List<Widget> _pages;
  List<IconButton> _actionButtons;
  List<FloatingActionButton> _floatingActionButtons;
  User _user = User(
      "user", "foo@madhacks.io", false); // TODO: Save/Load User on Exit/Startup
  //Future<SharedPreferences> _saveduser = SharedPreferences.getInstance();
  PresetsPage _presetsPage = PresetsPage([]);
  FriendsPage _friendsPage;
  HomePage _homePage;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  int _addFriend(String email) {
    Firestore.instance
        .collection("users")
        .document(email)
        .get()
        .then((userToAdd) {
      if (userToAdd.exists) {
        Firestore.instance
            .collection("users")
            .document(_user.email)
            .get()
            .then((userDoc) {
          List<dynamic> friendList = [];
          friendList.addAll(userDoc.data["friends"]);
          if (!friendList.contains(
              Firestore.instance.collection("users").document(email))) {
            friendList
                .add(Firestore.instance.collection("users").document(email));
            Firestore.instance
                .collection("users")
                .document(_user.email)
                .updateData({"friends": friendList});
          }
        });
        Firestore.instance
            .collection("users")
            .document(email)
            .get()
            .then((userDoc) {
          List<dynamic> friendList = [];
          friendList.addAll(userDoc.data["friends"]);
          if (!friendList.contains(
              Firestore.instance.collection("users").document(_user.email))) {
            friendList.add(
                Firestore.instance.collection("users").document(_user.email));
            Firestore.instance
                .collection("users")
                .document(email)
                .updateData({"friends": friendList});
          }
        });
        return 0;
      } else {
        return 1;
      }
    });
    return -1;
  }

  @override
  void initState() {
    // TODO: Foreground Notification

    Future onSelectNotification(String payload) async {
      if (payload != null) {
        debugPrint("payload : $payload");
      }

      setState(() {
        _pageIndex = 1;
      });
    }

    super.initState();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
    _friendsPage = FriendsPage(_user);
    _homePage = HomePage(_user, []);
    Firestore.instance
        .collection("users")
        .document(_user.email)
        .snapshots()
        .listen((user) {
      setState(() {
        _user.name = user.data["name"];
        _user.friends = user.data["friends"];
        _user.hasEvent = user.data["hasEvent"];
      });

      // TODO: Place resource app_icon
      user.data["friends"].forEach((friend) {
        friend.get().then((friendSnapshot) async {
          if (friendSnapshot.data["hasEvent"]) {
            AndroidNotificationDetails androidDetails =
                new AndroidNotificationDetails(
                    "channel_fooood", "Fooood", "Standard Channel");
            IOSNotificationDetails iOSDetails = new IOSNotificationDetails();
            NotificationDetails platformDetails =
                NotificationDetails(androidDetails, iOSDetails);
            await flutterLocalNotificationsPlugin.show(
                0, "New Acitivity", "You got a new message.", platformDetails);
          }
        });
      });

      // TODO: Background Notification
      // _firebaseMessaging.configure(
      //   onLaunch: (data) => null,
      //   onMessage: (data) => null,
      //   onResume: (data) => null,
      //   _firebaseMessaging.Token().then((token){
      //     TODO: sendToServer(token);
      //   });
      // );
    });
  }

// Future<Null> _memoryUser() async{
//   SharedPreferences saved = await _saveduser;
//   saved.setStringList("user",_user);
// };

// Future<SharedPreference> _loadUser() async{
//   SharedPreferences saved = await _saveduser;
//   _user=saved.setStringList("user");
// };

  @override
  Widget build(BuildContext context) {
    _floatingActionButtons = [
      FloatingActionButton(
        onPressed: () {
          if (!_user.hasEvent) {
            Firestore.instance
                .collection("events")
                .document(_user.email)
                .setData({
              "action": _homePage.actionSelected,
              "location": _homePage.hallSelected,
              "attending": <DocumentReference>[],
            });
          } else {
            Firestore.instance
                .collection("events")
                .document(_user.email)
                .delete();
          }
          setState(() {
            _user.hasEvent = !_user.hasEvent;
          });
          Firestore.instance
              .collection("users")
              .document(_user.email)
              .updateData({"hasEvent": _user.hasEvent});
        },
        tooltip: _user.hasEvent ? 'End Acitivity' : 'Send to Friends',
        child: Icon(_user.hasEvent ? Icons.cancel : Icons.send),
      ),
      FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          TextEditingController _controllerFriends = TextEditingController();
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _controllerFriends,
                            autofocus: true,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              hintText: _user.email,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SimpleDialogOption(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_addFriend(_controllerFriends.text) == 0) {
                                  _friendsPage.user = _user;
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Invalid Email"),
                                          content: Text(
                                              // TODO: Email Error Checking
                                              "Please input a valid registered email"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Okay"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        );
                                      });
                                }
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        },
      ),
      FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          TextEditingController _controllerLets = TextEditingController();
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _controllerLets,
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Let's ...?", hintText: "Eat"),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SimpleDialogOption(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              List<String> newActionsLets =
                                  _presetsPage.actionsLets;
                              newActionsLets.add(_controllerLets.text);
                              setState(() {
                                _presetsPage = PresetsPage(newActionsLets);
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        },
      ),
    ];
    _homePage.actionsLets = _presetsPage.actionsLets;
    _pages = [
      _homePage,
      _friendsPage,
      _presetsPage,
    ];
    _actionButtons = [
      IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: () {
          TextEditingController _controllerName = TextEditingController(),
              _controllerEmail = TextEditingController();
          FocusNode _nodeEmail = FocusNode(), _nodeName = FocusNode();
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            autofocus: true,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: "Email", hintText: _user.email),
                            focusNode: _nodeEmail,
                            onSubmitted: (email) {
                              FocusScope.of(context).requestFocus(_nodeName);
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                                labelText: "Name", hintText: _user.name),
                            focusNode: _nodeName,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          SimpleDialogOption(
                            child: Text(
                              "Set",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              // TODO: Fix Switch/Register User
                              bool hasEvent = false;
                              Firestore.instance.collection("users").document(
                                  _controllerEmail.text)
                                ..setData({
                                  "email": _controllerEmail.text,
                                  "name": _controllerName.text,
                                }, merge: true)
                                ..get().then((docSnap) {
                                  if (!docSnap.data.containsKey("hasEvent")) {
                                    Firestore.instance
                                        .collection("users")
                                        .document(_controllerEmail.text)
                                        .setData({"hasEvent": false},
                                            merge: true);
                                    hasEvent = false;
                                  } else {
                                    hasEvent = docSnap.data["hasEvent"];
                                  }
                                  if (!docSnap.data.containsKey("friends")) {
                                    Firestore.instance
                                        .collection("users")
                                        .document(_controllerEmail.text)
                                        .setData(
                                            {"friends": <DocumentReference>[]},
                                            merge: true);
                                  }
                                  if (!docSnap.data.containsKey("event")) {
                                    Firestore.instance
                                        .collection("users")
                                        .document(_controllerEmail.text)
                                        .setData({
                                      "event": Firestore.instance
                                          .collection("events")
                                          .document(_controllerEmail.text)
                                    }, merge: true);
                                  }
                                });
                              setState(() {
                                _user = User(_controllerName.text,
                                    _controllerEmail.text, hasEvent);
                                _homePage.user = _user;
                                _friendsPage.user = _user;
                              });
                              _nodeEmail.dispose();
                              _nodeName.dispose();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        },
      ),
      IconButton(
        // ACTION BUTTON FRIENDS
        icon: Icon(Icons.clear_all),
        onPressed: () => null,
      ),
      IconButton(
        // ACTION BUTTON FRIENDS
        icon: Icon(Icons.clear_all),
        onPressed: () => null,
      ), // ACTION BUTTONS
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[_actionButtons[_pageIndex]],
      ),
      body: Column(
        children: <Widget>[
          // ActiveAlert(_user),
          Expanded(
            child: _pages[_pageIndex],
          ),
        ],
      ),
      floatingActionButton: _floatingActionButtons[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text("Friends"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text("Presets"),
          )
        ],
        currentIndex: _pageIndex,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
