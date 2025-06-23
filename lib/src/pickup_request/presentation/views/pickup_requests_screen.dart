import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/services/injection_container.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_cubit.dart';
import 'package:greenloop/src/pickup_request/presentation/widgets/pickup_request_list.dart';

class PickupRequestsScreen extends StatelessWidget {
  static const routeName = '/pickup-requests';
  final String recyclingCenterId;

  const PickupRequestsScreen({super.key, required this.recyclingCenterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PickupRequestCubit>()
        ..getPickupRequests(recyclingCenterId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pickup Requests'),
        ),
        body: PickupRequestList(
          recyclingCenterId: recyclingCenterId,
        ),
      ),
    );
  }
} 