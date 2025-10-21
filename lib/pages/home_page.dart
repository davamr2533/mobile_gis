import 'package:flutter/material.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/widgets/bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(

        //Background Maroon atas
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              color: AppColors.firstBase,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 40),
            child: Column(
              children: [
                Row(
                  children: [

                    Text(
                      "Anda Offline!",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600
                      ),

                    ),
                    Spacer(),

                    Icon(
                      Icons.signal_cellular_alt,
                      size: 30,
                      color: AppColors.signalOff,
                    )
                  ],
                ),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "GIS Mobile",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  Text(
                                    "Explore, locate, synchronize",
                                    style: GoogleFonts.poppins(
                                        color: AppColors.textSoftGray,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                  SizedBox(height: 10),

                                  //GPS Status
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.gpsOff,
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Center(
                                        child: Text(
                                          "GPS Offline",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textRed
                                          ),
                                        ),
                                      ),

                                    )

                                  )


                                ],

                              )
                          ),

                          SizedBox(width: 16),

                          Image.asset(
                            'assets/profil.png',
                            width: 80,
                            height: 80,
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),


                Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // === CARD ONT ===
                      InkWell(
                        onTap: () {

                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          color: AppColors.secondBase,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: SizedBox(
                            width: 120, //
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.router,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Form ONT",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // === CARD TIANG ===
                      InkWell(
                        onTap: () {

                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          color: AppColors.thirdBase,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: SizedBox(
                            width: 120, //
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.wifi,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Form Tiang",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )


                ),

                SizedBox(height: 30),

                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        "History",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                      ),

                      Spacer(),

                      Text(
                        "See All",
                        style: GoogleFonts.poppins(
                            color: AppColors.secondBase,
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                //History
                Stack(
                  children: [

                    Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white
                      ),

                      child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "GIS-ONT-2271",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSoftGray,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Yogyakarta",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 20,
                                  )
                                ),
                              ],
                            ),

                            Spacer(),

                            Text(
                              "Pending",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPending,
                                fontSize: 14,
                                fontStyle: FontStyle.italic
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: 10,
                      height: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16)
                          ),
                          color: AppColors.thirdBase
                      ),
                    ),

                  ],
                ),




                



              ],
            )
          )
        ],
      ),


      bottomNavigationBar: CustomBottomNav(),

    );
  }
}
