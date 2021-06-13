import 'package:flutter/material.dart';

class ProfileCard extends StatefulWidget {
  final Widget? child;

  const ProfileCard({Key? key, this.child}) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}
