import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flag/flag.dart';
import '../models/country.dart';
import '../providers/providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search countries or cities...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: countriesAsync.when(
        data: (countries) {
          final filteredCountries = countries.where((c) {
            return c.countryName.toLowerCase().contains(_searchQuery) ||
                   c.cityName.toLowerCase().contains(_searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredCountries.length,
            itemBuilder: (context, index) {
              final country = filteredCountries[index];
              return ListTile(
                leading: Flag.fromString(
                  country.flagCode,
                  height: 30,
                  width: 30,
                  borderRadius: 15,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  country.countryName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${country.cityName} (${country.utcOffset})',
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: IconButton(
                  icon: Icon(
                    country.isFavorite ? Icons.visibility : Icons.visibility_off,
                    color: country.isFavorite ? Colors.blue : Colors.white38,
                  ),
                  onPressed: () {
                    ref.read(countriesProvider.notifier).toggleVisibility(country);
                  },
                ),
                onTap: () {
                  ref.read(referenceProvider.notifier).setReferenceCountry(country);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
