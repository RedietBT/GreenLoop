import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'package:greenloop/src/pickup_request/domain/entities/pickup_request.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_cubit.dart';
import 'package:intl/intl.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/core/res/fonts.dart';

class PickupRequestListItem extends StatelessWidget {
  final PickupRequest request;
  final String recyclingCenterId;

  const PickupRequestListItem({
    super.key,
    required this.request,
    required this.recyclingCenterId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PickupRequestCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: request.userAvatar != null
                        ? NetworkImage(request.userAvatar!)
                        : null,
                    child: request.userAvatar == null
                        ? const Icon(Icons.person, size: 32, color: AppColors.primary)
                        : null,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontFamily: Fonts.fontFamilyBold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Requested on: ${DateFormat.yMMMd().format(request.createdAt)}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: Fonts.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    request.requestStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: Fonts.fontFamilyBold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(request.requestStatus),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildInfoRow(Icons.category, 'Waste Type', request.wasteType ?? 'N/A', isDark),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.production_quantity_limits, 'Quantity',
                '${request.wasteQuantity?.toString() ?? 'N/A'} kg', isDark),
            const SizedBox(height: 16),
            if (request.wasteLocation != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: LocationMapPreview(location: request.wasteLocation),
              ),
            const SizedBox(height: 16),
            if (request.requestStatus.toUpperCase() == 'PENDING')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      cubit.updateStatus(
                          request.id, 'REJECTED', recyclingCenterId);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      cubit.updateStatus(
                          request.id, 'APPROVED', recyclingCenterId);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: Fonts.fontFamilyBold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: isDark ? Colors.white54 : Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: Fonts.fontFamily)),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary)),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 