import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_cubit.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_state.dart';
import 'package:greenloop/src/pickup_request/presentation/widgets/pickup_request_list_item.dart';

class PickupRequestList extends StatelessWidget {
  final String recyclingCenterId;
  const PickupRequestList({super.key, required this.recyclingCenterId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickupRequestCubit, PickupRequestState>(
      builder: (context, state) {
        if (state is PickupRequestLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PickupRequestError) {
          return Center(child: Text(state.message));
        } else if (state is PickupRequestLoaded) {
          if (state.requests.isEmpty) {
            return const Center(child: Text('No pickup requests found.'));
          }
          return ListView.builder(
            itemCount: state.requests.length,
            itemBuilder: (context, index) {
              final request = state.requests[index];
              return PickupRequestListItem(
                request: request,
                recyclingCenterId: recyclingCenterId,
              );
            },
          );
        }
        return const Center(child: Text('No pickup requests found.'));
      },
    );
  }
} 