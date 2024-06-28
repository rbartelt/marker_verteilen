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
      await manageBeachSection.deleteBeachSection(event.section);
      final beachSections = await manageBeachSection.getBeachSections();
      emit(BeachSectionDeleted(beachSections));
    });

    // Initialer Ladevorgang
    add(const LoadBeachSectionsEvent());
  }
}
