import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flag/flag.dart';
import '../models/country.dart';

class TimezoneCard extends StatelessWidget {
  final Country country;
  final DateTime time;
  final Duration diff;

  const TimezoneCard({
    super.key,
    required this.country,
    required this.time,
    required this.diff,
  });

  @override
  Widget build(BuildContext context) {
    final isFuture = diff.inMinutes > 0;
    final isPast = diff.inMinutes < 0;
    final timeFormat = DateFormat('h:mm a');

    String diffStr = '';
    if (diff.inMinutes == 0) {
      diffStr = 'Same time';
    } else {
      final hours = diff.inHours.abs();
      final minutes = diff.inMinutes.remainder(60).abs();
      String sign = diff.isNegative ? '-' : '+';
      diffStr = '(\$sign\${hours}h\${minutes > 0 ? "\${minutes}m" : ""})';
    }
    
    // Check if tomorrow or yesterday
    final now = DateTime.now(); // We would need the reference time to be 100% accurate on dates, but this is a rough approx for the UI
    String dayDiffStr = diffStr; // Simplified

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flag.fromString(
            country.flagCode,
            height: 40,
            width: 40,
            borderRadius: 20,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            country.countryName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            country.cityName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            timeFormat.format(time),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            dayDiffStr,
            style: TextStyle(
              color: isFuture ? Colors.green : (isPast ? Colors.red : Colors.white54),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
