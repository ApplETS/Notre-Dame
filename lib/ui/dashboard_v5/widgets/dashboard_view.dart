import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashboardViewV5 extends StatefulWidget {
  const DashboardViewV5({super.key});

  @override
  State<DashboardViewV5> createState() => _DashboardViewStateV5();
}

class _DashboardViewStateV5 extends State<DashboardViewV5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        /// TODO add the logic
        onRefresh: () async {},
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: Stack(
            children: [
              /// Circle
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: TopWaveClipper(),
                  child: Container(
                    height: 310,
                    width: double.infinity,
                    color: AppPalette.etsLightRed,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 90),
                    Text(
                      'Accueil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Bonjour, John Doe!',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),

              /// Scroll view
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Temp widgets
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 12.5),
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 15,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            width: 175,
                            height: 150,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 85, 85, 85),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              "Encore 4 jours et c'est fini !",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(20),
                            width: 175,
                            height: 150,
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 85, 85, 85),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              'Progression',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 12.5, 15, 12.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                                width: double.infinity,
                                height: 300,
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 85, 85, 85),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
                                  height: 40,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Horaire - Aujourd'hui",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 12.5, 15, 12.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                                width: double.infinity,
                                height: 150,
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 85, 85, 85),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
                                  height: 40,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Notes",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 12.5, 15, 12.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                                width: double.infinity,
                                height: 250,
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 85, 85, 85),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
                                  height: 40,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Moodle",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 12.5, 15, 12.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                                width: double.infinity,
                                height: 200,
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 85, 85, 85),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
                                  height: 40,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Évenements",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
