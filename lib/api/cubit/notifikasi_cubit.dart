import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gis_mobile/api/services/get/get_notifikasi.dart';

part 'notifikasi_state.dart';

class NotifikasiCubit extends Cubit<NotifikasiState> {
  NotifikasiCubit() : super(NotifikasiInitial());

  Future<void> fetchNotifikasi() async {
    try {
      emit(NotifikasiLoading());
      final data = await NotifikasiService.fetchDataNotifikasi();

      if (data.isEmpty) {
        emit(NotifikasiEmpty());
      } else {
        // Urutkan dari terbaru
        data.sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt) ?? DateTime(0);
          final dateB = DateTime.tryParse(b.createdAt) ?? DateTime(0);
          return dateB.compareTo(dateA);
        });
        emit(NotifikasiLoaded(data));
      }
    } catch (e) {
      emit(NotifikasiError(e.toString()));
    }
  }
}
