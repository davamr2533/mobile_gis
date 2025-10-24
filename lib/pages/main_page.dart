import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gis_mobile/colors/app_colors.dart';
import 'package:gis_mobile/pages/history_page.dart';
import 'package:gis_mobile/pages/home_page.dart';
import 'package:gis_mobile/pages/notification_page.dart';
import 'package:google_fonts/google_fonts.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State <MainPage> createState() => _MainPage();
}


class _MainPage extends State<MainPage> {

  int _currentIndex = 1;

  final List<Widget> _pages = [
    NotificationPage(),
    HomePage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {

    //Icons untuk navigation BAR
    final items = <IconData> [
      Icons.notifications,
      Icons.home,
      Icons.history,
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.white,
        buttonBackgroundColor: AppColors.thirdBase,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        index: _currentIndex,
        items: items
            .asMap()
            .entries
            .map(
              (entry) {
            final isActive = _currentIndex == entry.key;
            final label = [
              "Notification",
              "Home",
              "History",
            ][entry.key];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  entry.value,
                  size: 30,
                  color: isActive ? Colors.white : AppColors.navBar,
                ),
                if (!isActive) //
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.navBar,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            );
          },
        ).toList(),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}








