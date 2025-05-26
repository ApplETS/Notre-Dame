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
      return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(
          '${difference}d left',
          style: const TextStyle(color: Color(0xff807f83), fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(event.icon, size: 17, color: _getEventColor()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(event.date),
                        style: TextStyle(
                          color: AppPalette.grey.lightGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTimeLeftIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
