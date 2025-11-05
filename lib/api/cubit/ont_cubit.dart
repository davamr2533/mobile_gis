import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_mobile/api/models/ont_model.dart';
import 'package:gis_mobile/api/services/get/get_data_ont.dart';

part 'ont_state.dart';

class OntCubit extends Cubit<OntState> {
  OntCubit() : super(OntInitial());

  Future<void> fetchOntData() async {
    try {
      emit(OntLoading());
      final data = await OntService.fetchDataOnt();
      if (data.isEmpty) {
        emit(OntEmpty());
      } else {
        emit(OntLoaded(data));
      }
    } catch (e) {
      emit(OntError(e.toString()));
    }
  }
}
