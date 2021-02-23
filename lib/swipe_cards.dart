library swipe_cards;

import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/profile_card.dart';

class SwipeCards extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MatchEngine matchEngine;
  final Function onStackFinished;

  const SwipeCards(
      {Key key, this.matchEngine, this.onStackFinished, this.itemBuilder})
      : super(key: key);

  @override
  _SwipeCardsState createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards> {
  Key _frontCard;
  SwipeItem _currentItem;
  double _nextCardScale = 0.9;
  SlideRegion slideRegion;

  @override
  void initState() {
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentItem = widget.matchEngine.currentItem;
    _currentItem.addListener(_onMatchChange);
    _frontCard = Key(widget.matchEngine._currentItemIndex.toString());
    super.initState();
  }

  @override
  void dispose() {
    if (_currentItem != null) {
      _currentItem.removeListener(_onMatchChange);
    }
    widget.matchEngine.removeListener(_onMatchEngineChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matchEngine != oldWidget.matchEngine) {
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);
    }
    if (_currentItem != null) {
      _currentItem.removeListener(_onMatchChange);
    }
    _currentItem = widget.matchEngine.currentItem;
    if (_currentItem != null) {
      _currentItem.addListener(_onMatchChange);
    }
  }

  void _onMatchEngineChange() {
    setState(() {
      if (_currentItem != null) {
        _currentItem.removeListener(_onMatchChange);
      }
      _currentItem = widget.matchEngine.currentItem;
      if (_currentItem != null) {
        _currentItem.addListener(_onMatchChange);
      }
      _frontCard = Key(widget.matchEngine._currentItemIndex.toString());
    });
  }

  void _onMatchChange() {
    setState(() {
      //match has been changed
    });
  }

  Widget _buildFrontCard() {
    return ProfileCard(
      child: widget.itemBuilder(context, widget.matchEngine._currentItemIndex),
      key: _frontCard,
    );
  }

  Widget _buildBackCard() {
    return Transform(
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: ProfileCard(
        child: widget.itemBuilder(context, widget.matchEngine._nextItemIndex),
      ),
    );
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideRegion(SlideRegion region) {
    setState(() {
      slideRegion = region;
    });
  }

  void _onSlideOutComplete(SlideDirection direction) {
    SwipeItem currentMatch = widget.matchEngine.currentItem;
    switch (direction) {
      case SlideDirection.left:
        currentMatch.nope();
        break;
      case SlideDirection.right:
        currentMatch.like();
        break;
      case SlideDirection.up:
        currentMatch.superLike();
        break;
    }

    widget.matchEngine.cycleMatch();
    if (widget.matchEngine.currentItem == null) {
      widget.onStackFinished();
    }
  }

  SlideDirection _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentItem.decision) {
      case Decision.nope:
        return SlideDirection.left;
      case Decision.like:
        return SlideDirection.right;
      case Decision.superLike:
        return SlideDirection.up;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (widget.matchEngine.nextItem != null)
          DraggableCard(
            isDraggable: false,
            card: _buildBackCard(),
          ),
        if (widget.matchEngine.currentItem != null)
          DraggableCard(
            card: _buildFrontCard(),
            slideTo: _desiredSlideOutDirection(),
            onSlideUpdate: _onSlideUpdate,
            onSlideRegionUpdate: _onSlideRegion,
            onSlideOutComplete: _onSlideOutComplete,
          )
      ],
    );
  }
}

class MatchEngine extends ChangeNotifier {
  final List<SwipeItem> _swipeItems;
  int _currentItemIndex;
  int _nextItemIndex;

  MatchEngine({
    List<SwipeItem> swipeItems,
  }) : _swipeItems = swipeItems {
    _currentItemIndex = 0;
    _nextItemIndex = 1;
  }

  SwipeItem get currentItem => _currentItemIndex < _swipeItems.length
      ? _swipeItems[_currentItemIndex]
      : null;

  SwipeItem get nextItem =>
      _nextItemIndex < _swipeItems.length ? _swipeItems[_nextItemIndex] : null;

  void cycleMatch() {
    if (currentItem.decision != Decision.undecided) {
      currentItem.resetMatch();
      _currentItemIndex = _nextItemIndex;
      _nextItemIndex = _nextItemIndex + 1;
      notifyListeners();
    }
  }

  void rewindMatch() {
    if (_currentItemIndex != 0) {
      currentItem.resetMatch();
      _nextItemIndex = _currentItemIndex;
      _currentItemIndex = _currentItemIndex - 1;
      currentItem.resetMatch();
      notifyListeners();
    }
  }
}

class SwipeItem extends ChangeNotifier {
  final dynamic content;
  final Function likeAction;
  final Function superlikeAction;
  final Function nopeAction;
  Decision decision = Decision.undecided;

  SwipeItem(
      {this.content, this.likeAction, this.superlikeAction, this.nopeAction});

  void like() {
    if (decision == Decision.undecided) {
      decision = Decision.like;
      try {
        likeAction();
      } catch (e) {}
      notifyListeners();
    }
  }

  void nope() {
    if (decision == Decision.undecided) {
      decision = Decision.nope;
      try {
        nopeAction();
      } catch (e) {}
      notifyListeners();
    }
  }

  void superLike() {
    if (decision == Decision.undecided) {
      decision = Decision.superLike;
      try {
        superlikeAction();
      } catch (e) {}
      notifyListeners();
    }
  }

  void resetMatch() {
    if (decision != Decision.undecided) {
      decision = Decision.undecided;
      notifyListeners();
    }
  }
}

enum Decision { undecided, nope, like, superLike }
