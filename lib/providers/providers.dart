import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/country.dart';
import '../data/database_helper.dart';
import '../data/timezone_service.dart';

// Provides the SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Provides the list of all countries from the database
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  return await DatabaseHelper.instance.readAllCountries();
});

// StateNotifier for the reference time and country
class ReferenceState {
  final Country country;
  final DateTime time;

  ReferenceState({required this.country, required this.time});
}

class ReferenceNotifier extends StateNotifier<ReferenceState?> {
  final Ref ref;

  ReferenceNotifier(this.ref) : super(null) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final countryId = prefs.getInt('reference_country_id');
    
    Country? refCountry;
    if (countryId != null) {
      refCountry = await DatabaseHelper.instance.readCountry(countryId);
    }
    
    if (refCountry == null) {
      final countries = await ref.read(countriesProvider.future);
      if (countries.isNotEmpty) {
        refCountry = countries.firstWhere((c) => c.flagCode == 'BR', orElse: () => countries.first);
      }
    }

    if (refCountry != null) {
      final now = DateTime.now();
      state = ReferenceState(country: refCountry, time: now);
    }
  }

  void setReferenceCountry(Country country) {
    if (state != null) {
      state = ReferenceState(country: country, time: state!.time);
      ref.read(sharedPreferencesProvider).setInt('reference_country_id', country.id!);
    }
  }

  void setReferenceTime(DateTime time) {
    if (state != null) {
      state = ReferenceState(country: state!.country, time: time);
    }
  }
}

final referenceProvider = StateNotifierProvider<ReferenceNotifier, ReferenceState?>((ref) {
  return ReferenceNotifier(ref);
});

// Provider to compute all the other times based on the reference time
final timezoneListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final refState = ref.watch(referenceProvider);
  final countriesAsync = ref.watch(countriesProvider);

  if (refState == null || countriesAsync.value == null) {
    return [];
  }

  final refCountry = refState.country;
  final refTime = refState.time;
  final countries = countriesAsync.value!;

  return countries.where((c) => c.id != refCountry.id).map((country) {
    final convertedTime = TimezoneService.getConvertedTime(refTime, refCountry.timezone, country.timezone);
    
    final location = tz.getLocation(country.timezone);
    final refLocation = tz.getLocation(refCountry.timezone);
    
    final tzConvertedTime = tz.TZDateTime.from(convertedTime, location);
    final tzRefTime = tz.TZDateTime.from(refTime, refLocation);
    final diff = tzConvertedTime.difference(tzRefTime);

    return {
      'country': country,
      'time': convertedTime,
      'diff': diff,
    };
  }).toList();
});
