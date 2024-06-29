part of 'beachsection_bloc.dart';

abstract class BeachSectionState extends Equatable {
  final List<BeachSection> beachSections;

  const BeachSectionState(this.beachSections);

  @override
  List<Object> get props => [beachSections];
}

class BeachSectionInitial extends BeachSectionState {
  BeachSectionInitial() : super([]);
}

class BeachSectionAdded extends BeachSectionState {
  const BeachSectionAdded(List<BeachSection> beachSections) : super(beachSections);
}

class BeachSectionUpdated extends BeachSectionState {
  const BeachSectionUpdated(List<BeachSection> beachSections) : super(beachSections);
}

class BeachSectionDeleted extends BeachSectionState {
  const BeachSectionDeleted(List<BeachSection> beachSections) : super(beachSections);
}

class BeachSectionLoading extends BeachSectionState {
  const BeachSectionLoading(List<BeachSection> beachSections) : super(beachSections);
}

class BeachSectionError extends BeachSectionState {
  final String errorMessage;

  const BeachSectionError(this.errorMessage, List<BeachSection> beachSections) : super(beachSections);

  @override
  List<Object> get props => [errorMessage, beachSections];
}
