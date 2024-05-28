import '../entities/beachsection.dart';
import '../services/beachsection_service.dart';

class ManageBeachSection {
  List<BeachSection> beachSections = [];
  final BeachSectionService beachSectionService;

  ManageBeachSection(this.beachSectionService);

  void addBeachSection(BeachSection section) {
    beachSectionService.distributeSpotsForBeachSection(section);
    beachSections.add(section);
  }

  void updateBeachSection(BeachSection section) {
    beachSectionService.distributeSpotsForBeachSection(section);
    int index = beachSections.indexWhere((s) => s.startPoint == section.startPoint && s.endPoint == section.endPoint);
    if (index != -1) {
      beachSections[index] = section;
    }
  }

  void deleteBeachSection(BeachSection section) {
    beachSections.remove(section);
  }
}
