import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_cubit.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_state.dart';
import 'package:greenloop/src/pickup_request/presentation/widgets/pickup_request_list_item.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';

class PickupRequestList extends StatelessWidget {
  final String recyclingCenterId;
  const PickupRequestList({super.key, required this.recyclingCenterId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocBuilder<PickupRequestCubit, PickupRequestState>(
      builder: (context, state) {
        if (state is PickupRequestLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading pickup requests...',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontFamily: Fonts.fontFamily,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        } else if (state is PickupRequestError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading requests',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: Fonts.fontFamilyBold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontFamily: Fonts.fontFamily,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PickupRequestCubit>().getPickupRequests(recyclingCenterId);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is PickupRequestLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Pickup Requests',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontFamily: Fonts.fontFamilyBold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You don\'t have any pickup requests yet.\nNew requests will appear here.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      fontFamily: Fonts.fontFamily,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundTwo,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: PickupRequestListItem(
                    request: request,
                    recyclingCenterId: recyclingCenterId,
                  ),
                );
              },
            ),
          );
        }
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No pickup requests found.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontFamily: Fonts.fontFamily,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 