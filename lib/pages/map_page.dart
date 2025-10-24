import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  final MapController _mapController = MapController();
  double? latitude;
  double? longitude;
  LatLng? _selectedLocation; // 🔹 Titik dari pin tengah

  //fungsi untuk ambil lokasi GPS
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi permanen ditolak')),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      _mapController.move(LatLng(position.latitude, position.longitude), 17);
    } catch (e) {
      print("Error ambil lokasi: $e");
    }
  }

  // 🔹 Pindahkan map ke posisi GPS terakhir
  void _goToMyLocation() {
    if (latitude != null && longitude != null) {
      _mapController.move(LatLng(latitude!, longitude!), 17);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Belum ada data lokasi")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedLocation = _mapController.camera.center;
      });
    });


    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((Position position) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      final currentZoom = _mapController.camera.zoom;
      _mapController.move(LatLng(position.latitude, position.longitude), currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Koordinat",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.firstBase,
      ),
      body: Stack(
        children: [
          // 🌍 Tampilan Peta
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(-7.7956, 110.3695),
              initialZoom: 17.0,
              onMapEvent: (event) {
                // Ambil posisi tengah map setiap user geser
                setState(() {
                  _selectedLocation = _mapController.camera.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gis_mobile',
              ),
              if (latitude != null && longitude != null)
                MarkerLayer(
                  markers: [
                    // 🔵 Marker Lokasi Saya
                    Marker(
                      point: LatLng(latitude!, longitude!),
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Icon(
                            Icons.circle,
                            color: Colors.blue,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 📍 Pin di tengah layar (penentu lokasi)
          const Center(
            child: IgnorePointer(
              ignoring: true,
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 50,
              ),
            ),
          ),

          // 🧭 Tombol Lokasi Saya
          Positioned(
            bottom: 250,
            right: 16,
            child: FloatingActionButton(
              heroTag: "btn_location",
              backgroundColor: AppColors.secondBase,
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // 🗺️ Card bawah tetap sama
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Koordinat",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.explore_outlined,
                          color: AppColors.secondBase,
                          size: 30,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCoordRow("Latitude", _selectedLocation?.latitude),
                            const SizedBox(height: 8),
                            _buildCoordRow("Longitude", _selectedLocation?.longitude),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tombol pilih titik koordinat
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Ambil titik tengah map (pin)
                        final center = _mapController.camera.center;
                        setState(() {
                          _selectedLocation = center;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Titik dipilih: "
                                  "${center.latitude.toStringAsFixed(6)}, "
                                  "${center.longitude.toStringAsFixed(6)}",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFFF8C61),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Pilih titik koordinat",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordRow(String label, double? value) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.textSoftGray,
                width: 1,
              ),
            ),
            child: Text(
              value != null ? value.toStringAsFixed(6) : "-",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
