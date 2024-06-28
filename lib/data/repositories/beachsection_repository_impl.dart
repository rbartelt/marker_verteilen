import '../../domain/entities/beachsection.dart';
import '../../domain/repositories/beachsection_repository.dart';
import '../datasources/supabase_beachsection_datasource.dart';

class BeachSectionRepositoryImpl implements BeachSectionRepository {
  final SupabaseBeachSectionDataSource dataSource;

  BeachSectionRepositoryImpl(this.dataSource);

  @override
  Future<void> addBeachSection(BeachSection section) {
    return dataSource.addBeachSection(section);
  }

  @override
  Future<void> updateBeachSection(BeachSection section) {
    return dataSource.updateBeachSection(section);
  }

  @override
  Future<void> deleteBeachSection(BeachSection section) {
    return dataSource.deleteBeachSection(section);
  }

  @override
  Future<List<BeachSection>> getBeachSections() {
    return dataSource.getBeachSections();
  }
}
