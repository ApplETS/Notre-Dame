import 'package:flutter/material.dart';

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
  /// Direct Figma Colors 1=1
  static const Color etsV5DarkGrey = Color.fromARGB(255, 71, 70, 70);
  static const Color etsV5DarkRed = Color.fromARGB(255, 224, 19, 19);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        /// TODO add the logic
        onRefresh: () async {},
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child:

              /// Scroll view
              SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(alignment: Alignment.centerLeft, children: [
                  /// Circle
                  ClipPath(
                    clipper: TopWaveClipper(),
                    child: Container(
                      height: 360,
                      width: double.infinity,
                      color: etsV5DarkRed,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 100, left: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                height: 145,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: etsV5DarkGrey,
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
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                height: 145,
                                alignment: Alignment.bottomCenter,
                                decoration: BoxDecoration(
                                  color: etsV5DarkGrey,
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),

                /// Temp widgets
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
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
                              color: etsV5DarkGrey,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                              color: etsV5DarkRed,
                              height: 35,
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
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                            width: double.infinity,
                            height: 135,
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              color: etsV5DarkGrey,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                              color: etsV5DarkRed,
                              height: 35,
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
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                            width: double.infinity,
                            height: 350,
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              color: etsV5DarkGrey,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                              color: etsV5DarkRed,
                              height: 35,
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
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
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
                              color: etsV5DarkGrey,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Container(
                              color: etsV5DarkRed,
                              height: 35,
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
        ),
      ),
    );
  }
}
