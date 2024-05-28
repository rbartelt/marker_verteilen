part of 'beachsection_bloc.dart';

abstract class BeachSectionState extends Equatable {
  const BeachSectionState();

  @override
  List<Object> get props => [];
}

class BeachSectionInitial extends BeachSectionState {}

class BeachSectionAdded extends BeachSectionState {
  final List<BeachSection> beachSections;

  const BeachSectionAdded(this.beachSections);

  @override
  List<Object> get props => [beachSections];
}

class BeachSectionUpdated extends BeachSectionState {
  final List<BeachSection> beachSections;

  const BeachSectionUpdated(this.beachSections);

  @override
  List<Object> get props => [beachSections];
}

class BeachSectionDeleted extends BeachSectionState {
  final List<BeachSection> beachSections;

  const BeachSectionDeleted(this.beachSections);

  @override
  List<Object> get props => [beachSections];
}
