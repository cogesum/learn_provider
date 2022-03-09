import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "inherited Demo",
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<CountProvider>.value(value: CountProvider()),
          FutureProvider<List<User>>(
            create: (_) async => UserProvider().loadUserData(),
            initialData: [],
          ),
          StreamProvider(
              create: (_) => EventProvider().intStream(), initialData: 0),
        ],
        child: DefaultTabController(
            length: 3,
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                  appBar: AppBar(
                      title: const Text("Provider Demo"),
                      centerTitle: true,
                      bottom: const TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.add)),
                          Tab(icon: Icon(Icons.person)),
                          Tab(icon: Icon(Icons.message)),
                        ],
                      )),
                  body: TabBarView(
                    children: [
                      MyCountPage(),
                      MyUserPage(),
                      MyEventPage(),
                    ],
                  )),
            )),
      ),
    );
  }
}

class MyCountPage extends StatelessWidget {
  const MyCountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CountProvider _state = Provider.of<CountProvider>(context);
    return Scaffold(
      body: Center(
          child: Card(
        margin: EdgeInsets.symmetric(vertical: 150, horizontal: 10),
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ChangeNotifierProvider Example",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              "${_state.counterValue}",
              style: TextStyle(color: Colors.white, fontSize: 50),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _state._decrementCount(),
                  icon: Icon(
                    Icons.remove,
                    color: Colors.white,
                  ),
                ),
                Consumer<CountProvider>(builder: (context, value, child) {
                  return IconButton(
                    onPressed: () => value._incrementCount(),
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  );
                }),
              ],
            )
          ],
        ),
      )),
    );
  }
}

class CountProvider extends ChangeNotifier {
  int _count = 0;
  int get counterValue => _count;

  void _incrementCount() {
    _count++;
    notifyListeners();
  }

  void _decrementCount() {
    _count--;
    notifyListeners();
  }
}

class MyUserPage extends StatelessWidget {
  const MyUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("FutureProvider Example, users loaded from a File"),
        ),
        Consumer(builder: (context, List<User> users, _) {
          return Expanded(
            child: users.isEmpty
                ? Container(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return Container(
                          height: 50,
                          color: Colors.grey[(index * 200) % 400],
                          child: Center(
                            child: Text(
                                '${users[index].firstName} ${users[index].lastName} | ${users[index].website}'),
                          ));
                    }),
          );
        })
      ],
    );
  }
}

class MyEventPage extends StatelessWidget {
  const MyEventPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _value = Provider.of<int>(context);
    return Card(
      color: Colors.blue,
      margin: EdgeInsets.symmetric(vertical: 150, horizontal: 10),
      child: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "StreamProvider Example",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(
              height: 50,
            ),
            Text("${_value.toString()}",
                style: TextStyle(fontSize: 30, color: Colors.white)),
          ],
        )),
      ),
    );
  }
}

class EventProvider {
  Stream<int> intStream() {
    Duration interval = Duration(seconds: 2);
    return Stream<int>.periodic(interval, (int _count) => _count);
  }
}

class User {
  final String firstName, lastName, website;

  const User(this.firstName, this.lastName, this.website);

  User.fromJson(Map<String, dynamic> json)
      : this.firstName = json["first_name"],
        this.lastName = json["last_name"],
        this.website = json["website"];
}

class UserList {
  final List<User> users;
  UserList(this.users);

  UserList.fromJson(List<dynamic> usersJson)
      : users = usersJson.map((user) => User.fromJson(user)).toList();
}

class UserProvider {
  final String _dataPath = "assets/user.json";
  List<User> users = [];

  Future<String> loadAsset() async {
    return await Future.delayed(Duration(seconds: 3), () async {
      return await rootBundle.loadString(_dataPath);
    });
  }

  Future<List<User>> loadUserData() async {
    var dataString = await loadAsset();
    Map<String, dynamic> jsonUserData = jsonDecode(dataString);
    users = UserList.fromJson(jsonUserData['users']).users;
    //print("done loading user!" + jsonEncode(users));
    return users;
  }
}
