part of 'tiang_cubit.dart';

abstract class TiangState {}

class TiangInitial extends TiangState {}

class TiangLoading extends TiangState {}

class TiangLoaded extends TiangState {
  final List<TiangModel> data;
  TiangLoaded(this.data);
}

class TiangEmpty extends TiangState {}

class TiangError extends TiangState {
  final String message;
  TiangError(this.message);
}
