import '../entities/beachsection.dart';

abstract class BeachSectionRepository {
  Future<void> addBeachSection(BeachSection section);
  Future<void> updateBeachSection(BeachSection section);
  Future<void> deleteBeachSection(BeachSection section);
  Future<List<BeachSection>> getBeachSections();
}
