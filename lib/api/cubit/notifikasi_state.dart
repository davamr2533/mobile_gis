part of 'notifikasi_cubit.dart';

abstract class NotifikasiState extends Equatable {
  const NotifikasiState();

  @override
  List<Object?> get props => [];
}

class NotifikasiInitial extends NotifikasiState {}

class NotifikasiLoading extends NotifikasiState {}

class NotifikasiLoaded extends NotifikasiState {
  final List<dynamic> data;
  const NotifikasiLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class NotifikasiEmpty extends NotifikasiState {}

class NotifikasiError extends NotifikasiState {
  final String message;
  const NotifikasiError(this.message);

  @override
  List<Object?> get props => [message];
}
