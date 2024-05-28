import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/beachsection.dart';
import '../../domain/usecases/manage_beachsection.dart';

part 'beachsection_event.dart';
part 'beachsection_state.dart';

class BeachSectionBloc extends Bloc<BeachSectionEvent, BeachSectionState> {
  final ManageBeachSection manageBeachSection;

  BeachSectionBloc(this.manageBeachSection) : super(BeachSectionInitial()) {
    on<AddBeachSectionEvent>((event, emit) {
      manageBeachSection.addBeachSection(event.section);
      emit(BeachSectionAdded(manageBeachSection.beachSections));
    });

    on<UpdateBeachSectionEvent>((event, emit) {
      manageBeachSection.updateBeachSection(event.section);
      emit(BeachSectionUpdated(manageBeachSection.beachSections));
    });

    on<DeleteBeachSectionEvent>((event, emit) {
      manageBeachSection.deleteBeachSection(event.section);
      emit(BeachSectionDeleted(manageBeachSection.beachSections));
    });
  }
}
