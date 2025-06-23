import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/location_map_preview.dart';
import 'package:greenloop/src/pickup_request/domain/entities/pickup_request.dart';
import 'package:greenloop/src/pickup_request/presentation/cubit/pickup_request_cubit.dart';
import 'package:intl/intl.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: request.userAvatar != null
                      ? NetworkImage(request.userAvatar!)
                      : null,
                  child: request.userAvatar == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName ?? 'N/A',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Requested on: ${DateFormat.yMMMd().format(request.createdAt)}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    request.requestStatus,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _getStatusColor(request.requestStatus),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
                Icons.category, 'Waste Type', request.wasteType ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.production_quantity_limits, 'Quantity',
                '${request.wasteQuantity?.toString() ?? 'N/A'} kg'),
            const SizedBox(height: 16),
            if (request.wasteLocation != null)
              LocationMapPreview(location: request.wasteLocation),
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14)),
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