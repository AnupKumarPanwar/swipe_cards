import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe Cards Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Swipe Cards Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DateMatch> data = List<DateMatch>();
  MatchEngine _matchEngine;

  @override
  void initState() {
    data.add(DateMatch(profile: "1"));
    data.add(DateMatch(profile: "2"));
    data.add(DateMatch(profile: "3"));
    data.add(DateMatch(profile: "4"));
    data.add(DateMatch(profile: "5"));

    _matchEngine = MatchEngine(matches: data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SwipeCards(
            matchEngine: _matchEngine,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Text(data[index].profile),
              );
            }));
  }
}
