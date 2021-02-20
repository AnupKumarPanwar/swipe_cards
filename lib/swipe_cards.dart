library swipe_cards;

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';

class SwipeCards extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  const SwipeCards({Key key, this.itemCount, this.itemBuilder})
      : super(key: key);

  @override
  _SwipeCardsState createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards> {
  int currentIndex = 0;

  double _nextCardScale = 0.9;

  @override
  Widget build(BuildContext context) {
    log("message");
    return Stack(children: [
      DraggableCard(card: _buildBackCard(context)),
      DraggableCard(
        card: _buildFrontCard(context),
        onSlideUpdate: _onSlideUpdate,
        onSlideOutComplete: _onSlideOutComplete,
      ),
    ]);
  }

  _buildFrontCard(BuildContext context) {
    return Card(
        child: Container(child: widget.itemBuilder(context, currentIndex)));
  }

  _buildBackCard(BuildContext context) {
    return Transform(
        transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
        child: Card(
            child: Container(
                child: widget.itemBuilder(context, currentIndex + 1))));
  }

  _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  _onSlideOutComplete(SlideDirection direction) {
    setState(() {
      currentIndex += 1;
    });
  }
}
