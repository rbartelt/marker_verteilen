part of 'beachsection_bloc.dart';

abstract class BeachSectionEvent extends Equatable {
  const BeachSectionEvent();

  @override
  List<Object> get props => [];
}

class LoadBeachSectionsEvent extends BeachSectionEvent {
  const LoadBeachSectionsEvent();

  @override
  List<Object> get props => [];
}

class AddBeachSectionEvent extends BeachSectionEvent {
  final BeachSection section;

  const AddBeachSectionEvent(this.section);

  @override
  List<Object> get props => [section];
}

class UpdateBeachSectionEvent extends BeachSectionEvent {
  final BeachSection section;

  const UpdateBeachSectionEvent(this.section);

  @override
  List<Object> get props => [section];
}

class DeleteBeachSectionEvent extends BeachSectionEvent {
  final BeachSection section;

  const DeleteBeachSectionEvent(this.section);

  @override
  List<Object> get props => [section];
}
