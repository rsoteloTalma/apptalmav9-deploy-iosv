import 'package:flutter/material.dart';

import 'package:apptalma_v9/core/models/session.dart';

class ProfileMain extends StatefulWidget {
  final Session sessionData;
  const ProfileMain({super.key, required this.sessionData});

  @override
  State<ProfileMain> createState() => _ProfileMainState();
}

class _ProfileMainState extends State<ProfileMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Profile: ${widget.sessionData.user.name}',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
