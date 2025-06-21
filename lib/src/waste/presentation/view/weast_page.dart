import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_cubit.dart';
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

  late WeastCubit _weastCubit;

  @override
  void initState() {
    super.initState();
    _weastCubit = context.read<WeastCubit>();
    _weastCubit.fetchRecyclingProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weast Page'),
      ),
      body: WeastBody()
    );
  }
}