import 'package:example/content.dart';
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
  List<SwipeItem> _swipeItems = List<SwipeItem>();
  MatchEngine _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    _swipeItems.add(SwipeItem(content: Content(text: "1", color: Colors.red)));
    _swipeItems.add(SwipeItem(content: Content(text: "2", color: Colors.blue)));
    _swipeItems
        .add(SwipeItem(content: Content(text: "3", color: Colors.green)));
    _swipeItems
        .add(SwipeItem(content: Content(text: "4", color: Colors.yellow)));
    _swipeItems
        .add(SwipeItem(content: Content(text: "5", color: Colors.orange)));

    _matchEngine = MatchEngine(matches: _swipeItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            child: Column(children: [
          Container(
            height: 400,
            child: SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    color: _swipeItems[index].content.color,
                    child: Text(
                      _swipeItems[index].content.text,
                      style: TextStyle(fontSize: 100),
                    ),
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                  onPressed: () {
                    _matchEngine.currentItem.nope();
                  },
                  child: Text("Nope")),
              RaisedButton(
                  onPressed: () {
                    _matchEngine.currentItem.superLike();
                  },
                  child: Text("Superlike")),
              RaisedButton(
                  onPressed: () {
                    _matchEngine.currentItem.like();
                  },
                  child: Text("Like"))
            ],
          )
        ])));
  }

  _likeAction() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Liked"),
    ));
  }
}
