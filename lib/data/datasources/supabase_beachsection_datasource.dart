import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/beachsection.dart';
import '../models/beachsection_dto.dart';

class SupabaseBeachSectionDataSource {
  final SupabaseClient client;

  SupabaseBeachSectionDataSource(this.client);

  Future<void> addBeachSection(BeachSection section) async {
    final dto = BeachSectionDTO.fromDomain(section);
    final response = await client.from('beachsections').insert(dto.toJson());
    if (response is PostgrestException) {
      throw Exception('Failed to add beach section: ${response.message}');
    }
  }

  Future<void> updateBeachSection(BeachSection section) async {
    final dto = BeachSectionDTO.fromDomain(section);
    final response = await client.from('beachsections').update(dto.toJson()).eq('id', dto.id);
    if (response is PostgrestException) {
      throw Exception('Failed to update beach section: ${response.message}');
    }
  }

  Future<void> deleteBeachSection(BeachSection section) async {
    final dto = BeachSectionDTO.fromDomain(section);
    final response = await client.from('beachsections').delete().eq('id', dto.id);
    if (response is PostgrestException) {
      throw Exception('Failed to delete beach section: ${response.message}');
    }
  }

  Future<List<BeachSection>> getBeachSections() async {
    final response = await client.from('beachsections').select();
    if (response is PostgrestException) {
      throw Exception('Failed to fetch beach sections: ${response.first.entries}');
    }
    return (response).map((json) => BeachSectionDTO.fromJson(json).toDomain()).toList();
  }
}
