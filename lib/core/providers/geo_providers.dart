import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wilaya.dart';
import '../models/commune.dart';
import 'core_providers.dart';

/// Fetches all wilayas from GET /geo/wilayas.
/// Cached at app level — only fetched once per session.
final wilayasProvider = FutureProvider<List<Wilaya>>((ref) async {
  return ref.watch(apiServiceProvider).getWilayas();
});

/// Fetches communes for a given wilaya from GET /geo/wilayas/:id/communes.
/// Keyed by wilayaId — auto-refreshes when the key changes.
final communesProvider =
    FutureProvider.family<List<Commune>, int>((ref, wilayaId) async {
  return ref.watch(apiServiceProvider).getCommunes(wilayaId);
});
