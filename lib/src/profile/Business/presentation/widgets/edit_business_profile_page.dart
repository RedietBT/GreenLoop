import 'package:flutter/material.dart';

class EditBusinessProfilePage extends StatelessWidget {
  const EditBusinessProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Profile'),
      ),
      body: const Center(
        child: Text('This is where you will edit the business profile!'),
      ),
    );
  }
}
