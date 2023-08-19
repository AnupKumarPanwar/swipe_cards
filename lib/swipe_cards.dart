// ignore_for_file: public_member_api_docs, sort_constructors_first
library swipe_cards;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/profile_card.dart';

class SwipeCards extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final Widget? likeTag;
  final Widget? nopeTag;
  final Widget? superLikeTag;
  final MatchEngine matchEngine;
  final Function onStackFinished;
  final Function(SwipeItem, int)? itemChanged;
  final bool fillSpace;
  final bool upSwipeAllowed;
  final bool leftSwipeAllowed;
  final bool rightSwipeAllowed;
  final double nopeTagAngle;
  final double likeTagAngle;

  /// Threshold for left swipe. The larger the number, the further the card needs to be dragged to activate the action. Must be less or equal to 0 to work correct.
  final double leftSwipeThreshold;

  /// Threshold for right swipe. The larger the number, the further the card needs to be dragged to activate the action. Must be bigger or equal to 0 to work correct.
  final double rightSwipeThreshold;

  /// Threshold for top swipe. The larger the number, the further the card needs to be dragged to activate the action.
  final double topSwipeThreshold;

  /// Triggered when user dragging the card
  final Function(SwipeItem item, SlideRegion? slideRegion)? onSwipeChange;

  /// Triggered when user releases the card
  final Function(SwipeItem item, SlideRegion? slideRegion)? onSwipeFinish;

  SwipeCards({
    Key? key,
    required this.itemBuilder,
    this.likeTag,
    this.nopeTag,
    this.superLikeTag,
    required this.matchEngine,
    required this.onStackFinished,
    this.itemChanged,
    this.fillSpace = true,
    this.upSwipeAllowed = false,
    this.leftSwipeAllowed = true,
    this.rightSwipeAllowed = true,
    this.leftSwipeThreshold = -0.45,
    this.rightSwipeThreshold = 0.45,
    this.topSwipeThreshold = -0.4,
    this.onSwipeChange,
    this.onSwipeFinish,
    this.nopeTagAngle = -12,
    this.likeTagAngle = 12,
  }) : super(key: key);

  @override
  _SwipeCardsState createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCards> {
  Key? _frontCard;
  SwipeItem? _currentItem;
  double _nextCardScale = 0.9;
  SlideRegion? slideRegion;

  @override
  void initState() {
    widget.matchEngine.addListener(_onMatchEngineChange);
    _currentItem = widget.matchEngine.currentItem;
    if (_currentItem != null) {
      _currentItem!.addListener(_onMatchChange);
    }
    int? currentItemIndex = widget.matchEngine._currentItemIndex;
    if (currentItemIndex != null) {
      _frontCard = Key(currentItemIndex.toString());
    }
    super.initState();
  }

  @override
  void dispose() {
    if (_currentItem != null) {
      _currentItem!.removeListener(_onMatchChange);
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
      _currentItem!.removeListener(_onMatchChange);
    }
    _currentItem = widget.matchEngine.currentItem;
    if (_currentItem != null) {
      _currentItem!.addListener(_onMatchChange);
    }
  }

  void _onMatchEngineChange() {
    setState(() {
      if (_currentItem != null) {
        _currentItem!.removeListener(_onMatchChange);
      }
      _currentItem = widget.matchEngine.currentItem;
      if (_currentItem != null) {
        _currentItem!.addListener(_onMatchChange);
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
      child: widget.itemBuilder(context, widget.matchEngine._currentItemIndex!),
      key: _frontCard,
    );
  }

  Widget _buildBackCard() {
    return Transform(
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: ProfileCard(
        child: widget.itemBuilder(context, widget.matchEngine._nextItemIndex!),
      ),
    );
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideFinish(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSwipeChange(SlideRegion? region) {
    final item = widget.matchEngine.currentItem;
    if (item != null) widget.onSwipeChange?.call(item, region);
  }

  void _onSwipeFinish(SlideRegion? region) {
    final item = widget.matchEngine.currentItem;
    if (item != null) widget.onSwipeFinish?.call(item, region);
  }

  void _onSlideRegion(SlideRegion? region) {
    setState(() {
      slideRegion = region;
      SwipeItem? currentMatch = widget.matchEngine.currentItem;
      if (currentMatch != null && currentMatch.onSlideUpdate != null) {
        currentMatch.onSlideUpdate!(region);
      }
    });
  }

  void _onSlideOutComplete(SlideDirection? direction) {
    SwipeItem? currentMatch = widget.matchEngine.currentItem;
    switch (direction) {
      case SlideDirection.left:
        currentMatch?.nope();
        break;
      case SlideDirection.right:
        currentMatch?.like();
        break;
      case SlideDirection.up:
        currentMatch?.superLike();
        break;
      case null:
        break;
    }

    if (widget.matchEngine._nextItemIndex! < widget.matchEngine._swipeItems!.length) {
      widget.itemChanged?.call(widget.matchEngine.nextItem!, widget.matchEngine._nextItemIndex!);
    }

    widget.matchEngine.cycleMatch();
    if (widget.matchEngine.currentItem == null) {
      widget.onStackFinished();
    }
  }

  SlideDirection? _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentItem!.decision) {
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
      fit: widget.fillSpace == true ? StackFit.expand : StackFit.loose,
      children: <Widget>[
        if (widget.matchEngine.nextItem != null)
          DraggableCard(
            isDraggable: false,
            card: _buildBackCard(),
            upSwipeAllowed: widget.upSwipeAllowed,
            leftSwipeAllowed: widget.leftSwipeAllowed,
            rightSwipeAllowed: widget.rightSwipeAllowed,
            isBackCard: true,
          ),
        if (widget.matchEngine.currentItem != null)
          DraggableCard(
            card: _buildFrontCard(),
            likeTag: widget.likeTag,
            nopeTag: widget.nopeTag,
            superLikeTag: widget.superLikeTag,
            slideTo: _desiredSlideOutDirection(),
            onSlideUpdate: _onSlideUpdate,
            onSwipeChange: _onSwipeChange,
            onSwipeFinish: _onSwipeFinish,
            onSlideRegionUpdate: _onSlideRegion,
            onSlideOutComplete: _onSlideOutComplete,
            upSwipeAllowed: widget.upSwipeAllowed,
            leftSwipeAllowed: widget.leftSwipeAllowed,
            rightSwipeAllowed: widget.rightSwipeAllowed,
            isBackCard: false,
            leftSwipeThreshold: widget.leftSwipeThreshold,
            rightSwipeThreshold: widget.rightSwipeThreshold,
            topSwipeThreshold: widget.topSwipeThreshold,
            nopeTagAngle: widget.nopeTagAngle,
            likeTagAngle: widget.likeTagAngle,
          )
      ],
    );
  }
}

class MatchEngine extends ChangeNotifier {
  final List<SwipeItem>? _swipeItems;
  int? _currentItemIndex;
  int? _nextItemIndex;

  MatchEngine({
    List<SwipeItem>? swipeItems,
  }) : _swipeItems = swipeItems {
    _currentItemIndex = 0;
    _nextItemIndex = 1;
  }

  SwipeItem? get currentItem => _currentItemIndex! < _swipeItems!.length ? _swipeItems![_currentItemIndex!] : null;

  SwipeItem? get nextItem => _nextItemIndex! < _swipeItems!.length ? _swipeItems![_nextItemIndex!] : null;

  void cycleMatch() {
    if (currentItem!.decision != Decision.undecided) {
      currentItem!.resetMatch();
      _currentItemIndex = _nextItemIndex;
      _nextItemIndex = _nextItemIndex! + 1;
      notifyListeners();
    }
  }

  void rewindMatch() {
    if (_currentItemIndex != 0) {
      currentItem!.resetMatch();
      _nextItemIndex = _currentItemIndex;
      _currentItemIndex = _currentItemIndex! - 1;
      currentItem!.resetMatch();
      notifyListeners();
    }
  }
}

class SwipeItem extends ChangeNotifier {
  final dynamic content;
  final Function? likeAction;
  final Function? superlikeAction;
  final Function? nopeAction;
  final Future Function(SlideRegion? slideRegion)? onSlideUpdate;
  final Future Function(SlideRegion? slideRegion)? onSlideFinish;
  Decision decision = Decision.undecided;

  SwipeItem({
    this.content,
    this.likeAction,
    this.superlikeAction,
    this.nopeAction,
    this.onSlideUpdate,
    this.onSlideFinish,
  });

  void slideUpdateAction(SlideRegion? slideRegion) async {
    try {
      await onSlideUpdate!(slideRegion);
    } catch (e) {}
    notifyListeners();
  }

  void like() {
    if (decision == Decision.undecided) {
      decision = Decision.like;
      try {
        likeAction?.call();
      } catch (e) {}
      notifyListeners();
    }
  }

  void nope() {
    if (decision == Decision.undecided) {
      decision = Decision.nope;
      try {
        nopeAction?.call();
      } catch (e) {}
      notifyListeners();
    }
  }

  void superLike() {
    if (decision == Decision.undecided) {
      decision = Decision.superLike;
      try {
        superlikeAction?.call();
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
