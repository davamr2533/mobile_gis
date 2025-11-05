import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gis_mobile/colors/app_colors.dart';

class AppWidget {
  Widget loadingWidget() {
    return Center(
      child: SpinKitWaveSpinner(
        color: AppColors.secondBase,
        size: 50.0,
        waveColor: AppColors.secondBase,
      ),
    );
  }
}
