import 'package:f1_drivers/utils/f1_scroll_physics.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:f1_drivers/model/driver.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Colors.black,
        fontFamily: "PTMono",
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

const String ALL_CHARS =
    "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ";

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController _scrollController = ScrollController();
  double pageFraction = 0.0;

  int driverNumber = 0;
  String firstName = "";
  String lastName = "";
  String team = "";

  @override
  void initState() {
    super.initState();

    driverNumber = drivers[0].driverNumber;
    team = drivers[0].team;
    firstName = drivers[0].firstName;
    lastName = drivers[0].lastName;

    _scrollController.addListener(() {
      setState(() {
        pageFraction =
            _scrollController.offset / (MediaQuery.of(context).size.width * 2);

        driverNumber = _calculateDriverNumber();
        firstName = _calculateCharacters(StringType.FIRST_NAME);
        lastName = _calculateCharacters(StringType.LAST_NAME);
        team = _calculateCharacters(StringType.TEAM);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: MediaQuery.of(context).size.width * 2,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            overflow: Overflow.visible,
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              ListView.builder(
                  controller: _scrollController,
                  physics: F1ScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: drivers.length,
                  itemBuilder: (context, position) {
                    return _getImage(position);
                  }),
              _getInfo()
            ],
          ),
        ));
  }

  Widget _getInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                  width: 30,
                  child: Text(
                    driverNumber.toString(),
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  )),
              SizedBox(
                width: 16,
              ),
              Image.asset(
                "assets/${drivers[pageFraction.round()].nationality}.png",
                height: 32,
                width: 32,
              )
            ],
          ),
          Text(
            firstName,
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          Text(
            lastName,
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          Text(
            team,
            style: TextStyle(fontSize: 20, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _getImage(int position) {
    return Image.asset(
      "assets/${drivers[position].image}.jpg",
      width: MediaQuery.of(context).size.width * 2,
      fit: BoxFit.cover,
    );
  }

  int _calculateDriverNumber() {
    int lastDriverNumber = drivers[pageFraction.floor()].driverNumber;
    int nextDriverNumber = drivers[pageFraction.ceil()].driverNumber;

    double currentFraction = pageFraction % 1;
    int current = lastDriverNumber -
        ((lastDriverNumber - nextDriverNumber) * currentFraction).round();

    return current;
  }

  String _calculateCharacters(StringType stringType) {
    String last = "";
    String next = "";

    switch (stringType) {
      case StringType.FIRST_NAME:
        {
          last = drivers[pageFraction.floor()].firstName;
          next = drivers[pageFraction.ceil()].firstName;
          break;
        }
      case StringType.LAST_NAME:
        {
          last = drivers[pageFraction.floor()].lastName;
          next = drivers[pageFraction.ceil()].lastName;
          break;
        }
      default:
        {
          last = drivers[pageFraction.floor()].team;
          next = drivers[pageFraction.ceil()].team;
          break;
        }
    }

    int longestTeam = max(last.length, next.length);

    String currentTeam = "";

    for (var i = 0; i < longestTeam; i++) {
      String lastTeamChar = " ";
      String nextTeamChar = " ";

      try {
        lastTeamChar = last[i];
      } catch (e) {}
      try {
        nextTeamChar = next[i];
      } catch (e) {}

      int lastIndex = ALL_CHARS.indexOf(lastTeamChar);
      int nextIndex = ALL_CHARS.indexOf(nextTeamChar);

      double currentFraction = pageFraction % 1;

      int currentIndex =
          lastIndex - ((lastIndex - nextIndex) * currentFraction).round();

      currentTeam = currentTeam + ALL_CHARS[currentIndex];
    }

    return currentTeam;
  }
}
