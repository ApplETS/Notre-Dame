import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/dashboard/view_model/event_viewmodel.dart';
import '../../core/themes/app_palette.dart';

class EventItemWidget extends StatelessWidget {
  final SessionEvent event;

  const EventItemWidget({
    super.key,
    required this.event,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date not available';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Color _getEventColor() {
    return AppPalette.grey.white;
  }

  Widget _buildTimeLeftIndicator() {
    if (event.date == null) return const SizedBox.shrink();
    
    final now = DateTime.now();
    final difference = event.date!.difference(now).inDays + 1;
    
    if (difference <= 4) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppPalette.etsLightRed.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '${difference}d left',
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(event.icon, size: 16, color: _getEventColor()),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _buildTimeLeftIndicator(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(event.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
