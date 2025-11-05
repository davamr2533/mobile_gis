part of 'ont_cubit.dart';

abstract class OntState {}

class OntInitial extends OntState {}

class OntLoading extends OntState {}

class OntLoaded extends OntState {
  final List<OntModel> data;
  OntLoaded(this.data);
}

class OntEmpty extends OntState {}

class OntError extends OntState {
  final String message;
  OntError(this.message);
}
