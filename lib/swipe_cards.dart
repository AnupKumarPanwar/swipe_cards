library swipe_cards;

import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';

class SwipeCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      DraggableCard(card: _buildFrontCard()),
    ]);
  }

  _buildFrontCard() {
    return Card(
        child: Container(height: 500, width: 400, child: Text("hello")));
  }
}
