import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/beachsection.dart';
import '../../domain/usecases/manage_beachsection.dart';

part 'beachsection_event.dart';
part 'beachsection_state.dart';

class BeachSectionBloc extends Bloc<BeachSectionEvent, BeachSectionState> {
  final ManageBeachSection manageBeachSection;

  BeachSectionBloc(this.manageBeachSection) : super(BeachSectionInitial()) {
    on<LoadBeachSectionsEvent>((event, emit) async {
      try {
        final beachSections = await manageBeachSection.getBeachSections();
        emit(BeachSectionAdded(beachSections));
      } catch (e) {
        emit(BeachSectionInitial());
      }
    });

    on<BeachSectionLoadingEvent>((event, emit) {
      emit(BeachSectionLoading(state.beachSections));
    });

    on<AddBeachSectionEvent>((event, emit) async {
      await manageBeachSection.addBeachSection(event.section);
      final beachSections = await manageBeachSection.getBeachSections();
      emit(BeachSectionAdded(beachSections));
    });

    on<UpdateBeachSectionEvent>((event, emit) async {
      await manageBeachSection.updateBeachSection(event.section);
      final beachSections = await manageBeachSection.getBeachSections();
      emit(BeachSectionUpdated(beachSections));
    });

    on<DeleteBeachSectionEvent>((event, emit) async {
      // Emittiere zuerst den Ladezustand
      emit(BeachSectionLoading(state.beachSections));

      try {
        // Führe die Löschoperation durch
        await manageBeachSection.deleteBeachSection(event.section);

        // Hole die aktualisierte Liste der BeachSections
        final updatedBeachSections = await manageBeachSection.getBeachSections();

        // Emittiere den erfolgreichen Zustand
        emit(BeachSectionDeleted(updatedBeachSections));
      } catch (error) {
        // Behandle Fehler hier
        emit(BeachSectionError("Fehler beim Löschen der BeachSection: $error", state.beachSections));
      }
    });

    // Initialer Ladevorgang
    add(const LoadBeachSectionsEvent());
  }
}
