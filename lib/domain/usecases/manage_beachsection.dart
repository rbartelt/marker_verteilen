import '../entities/beachsection.dart';
import '../repositories/beachsection_repository.dart';

class ManageBeachSection {
  final BeachSectionRepository repository;

  ManageBeachSection(this.repository);

  Future<void> addBeachSection(BeachSection section) {
    return repository.addBeachSection(section);
  }

  Future<void> updateBeachSection(BeachSection section) {
    return repository.updateBeachSection(section);
  }

  Future<void> deleteBeachSection(BeachSection section) {
    return repository.deleteBeachSection(section);
  }

  Future<List<BeachSection>> getBeachSections() {
    return repository.getBeachSections();
  }
}
