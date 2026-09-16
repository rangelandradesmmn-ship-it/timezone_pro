import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flag/flag.dart';
import '../providers/providers.dart';
import 'timezone_card.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refState = ref.watch(referenceProvider);
    final timezoneList = ref.watch(timezoneListProvider);

    if (refState == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0B),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('EEEE, d MMMM');

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('TimeZone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Reference Header
            GestureDetector(
              onTap: () => _selectTime(context, ref, refState.time),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeFormat.format(refState.time),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(refState.time).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reference Time: ${refState.country.cityName} (${refState.country.utcOffset})',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Flag.fromString(
                        refState.country.flagCode,
                        height: 60,
                        width: 60,
                        borderRadius: 30,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        refState.country.cityName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Grid of other timezones
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: timezoneList.length,
                itemBuilder: (context, index) {
                  final item = timezoneList[index];
                  return TimezoneCard(
                    country: item['country'],
                    time: item['time'],
                    diff: item['diff'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, WidgetRef ref, DateTime initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF161616),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final now = DateTime.now();
      final newTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      ref.read(referenceProvider.notifier).setReferenceTime(newTime);
    }
  }
}
