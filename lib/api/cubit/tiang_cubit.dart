import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_mobile/api/models/tiang_model.dart';
import 'package:gis_mobile/api/services/get/get_data_tiang.dart';

part 'tiang_state.dart';

class TiangCubit extends Cubit<TiangState> {
  TiangCubit() : super(TiangInitial());

  Future<void> fetchTiangData() async {
    try {
      emit(TiangLoading());
      final data = await TiangService.fetchDataTiang();
      if (data.isEmpty) {
        emit(TiangEmpty());
      } else {
        emit(TiangLoaded(data));
      }
    } catch (e) {
      emit(TiangError(e.toString()));
    }
  }
}
