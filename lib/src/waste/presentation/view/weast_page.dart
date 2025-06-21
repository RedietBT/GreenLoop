import 'package:flutter/material.dart';
import 'package:greenloop/src/waste/presentation/wedigit/weast_body.dart';

class WeastPage extends StatefulWidget{

  static const String routeName = '/weastPage';

  final String userId;
  final String userType;

  const WeastPage({
    required this.userId,
    required this.userType,
    super.key,
  });

  @override
  State<WeastPage> createState() => _WeastPageState();
}

class _WeastPageState extends State<WeastPage>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Waste Pickup'),
      ),
      body: WeastBody(userId: widget.userId)
    );
  }
}