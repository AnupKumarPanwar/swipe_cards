library swipe_cards;

import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/profile_card.dart';

class SwipeCards extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MatchEngine matchEngine;
  final bool unlimitedSwipes;
  final Function fetchCards;

  const SwipeCards(
      {Key key,
      this.matchEngine,
      this.unlimitedSwipes,
      this.fetchCards,
      this.itemBuilder})
      : super(key: key);

  @override
  _SwipeCardsState createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards> {
  Key _frontCard;
  DateMatch _currentMatch;
  double _nextCardScale = 0.9;
  SlideRegion slideRegion;

  @override
  void initState() {
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentMatch = widget.matchEngine.currentMatch;
    _currentMatch.addListener(_onMatchChange);
    _frontCard = Key(_currentMatch.profile.toString());
    super.initState();
  }

  @override
  void dispose() {
    if (_currentMatch != null) {
      _currentMatch.removeListener(_onMatchChange);
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
    if (_currentMatch != null) {
      _currentMatch.removeListener(_onMatchChange);
    }
    _currentMatch = widget.matchEngine.currentMatch;
    if (_currentMatch != null) {
      _currentMatch.addListener(_onMatchChange);
    }
  }

  void _onMatchEngineChange() {
    setState(() {
      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }
      _currentMatch = widget.matchEngine.currentMatch;
      if (_currentMatch != null) {
        _currentMatch.addListener(_onMatchChange);
      }
      _frontCard = Key(_currentMatch.profile.toString());
    });
  }

  void _onMatchChange() {
    setState(() {
      //match has been changed
    });
  }

  Widget _buildFrontCard() {
    return ProfileCard(
      child: widget.itemBuilder(context, widget.matchEngine._currentMatchIndex),
      key: _frontCard,
    );
  }

  Widget _buildBackCard() {
    return Transform(
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: ProfileCard(
        child: widget.itemBuilder(context, widget.matchEngine._nextMatchIndex),
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
    DateMatch currentMatch = widget.matchEngine.currentMatch;
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
    if (widget.matchEngine.currentMatch == null) {
      widget.fetchCards();
    }
  }

  SlideDirection _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentMatch.decision) {
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
        if (widget.matchEngine.nextMatch != null)
          DraggableCard(
            isDraggable: false,
            card: _buildBackCard(),
          ),
        if (widget.matchEngine.currentMatch != null)
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
  final List<DateMatch> _matches;
  int _currentMatchIndex;
  int _nextMatchIndex;

  MatchEngine({
    List<DateMatch> matches,
  }) : _matches = matches {
    _currentMatchIndex = 0;
    _nextMatchIndex = 1;
  }

  DateMatch get currentMatch => _currentMatchIndex < _matches.length
      ? _matches[_currentMatchIndex]
      : null;

  DateMatch get nextMatch =>
      _nextMatchIndex < _matches.length ? _matches[_nextMatchIndex] : null;

  void cycleMatch() {
    if (currentMatch.decision != Decision.undecided) {
      currentMatch.resetMatch();
      _currentMatchIndex = _nextMatchIndex;
      _nextMatchIndex = _nextMatchIndex + 1;
      notifyListeners();
    }
  }

  void rewindMatch() {
    if (_currentMatchIndex != 0) {
      currentMatch.resetMatch();
      _nextMatchIndex = _currentMatchIndex;
      _currentMatchIndex = _currentMatchIndex - 1;
      currentMatch.resetMatch();
      notifyListeners();
    }
  }
}

class DateMatch extends ChangeNotifier {
  final dynamic profile;
  Decision decision = Decision.undecided;

  DateMatch({this.profile});

  void like() {
    if (decision == Decision.undecided) {
      decision = Decision.like;
      try {} catch (e) {}
      notifyListeners();
    }
  }

  void nope() {
    if (decision == Decision.undecided) {
      decision = Decision.nope;
      try {} catch (e) {}
      notifyListeners();
    }
  }

  void superLike() {
    if (decision == Decision.undecided) {
      decision = Decision.superLike;
      try {} catch (e) {}
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
