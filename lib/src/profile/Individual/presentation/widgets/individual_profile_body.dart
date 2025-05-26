import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_cubit.dart';
import 'package:greenloop/src/profile/Individual/presentation/cubits/individual_profile_state.dart';


class IndividualProfileBody extends StatelessWidget {
  const IndividualProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndividualProfileCubit, IndividualProfileState>(
      builder: (context, state) {
        if (state is IndividualProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is IndividualProfileError) {
          return Center(child: Text(state.message));
        } else if (state is IndividualProfileLoaded) {
          final user = state.user;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 10),
                Text("${user.first_name} ${user.last_name}",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                const SizedBox(height: 10),
                Text("Points: ${user.points ?? 'N/A'}"),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
