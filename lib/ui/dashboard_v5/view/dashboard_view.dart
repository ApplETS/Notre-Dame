import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import '../clipper/circle_clipper.dart';
import '../view_model/dashboard_viewmodel.dart';

class DashboardViewV5 extends StatefulWidget {
  const DashboardViewV5({super.key});

  @override
  State<DashboardViewV5> createState() => _DashboardViewStateV5();
}

class _DashboardViewStateV5 extends State<DashboardViewV5> with SingleTickerProviderStateMixin {
  late final DashboardViewModelV5 viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DashboardViewModelV5();
    viewModel.init(this);
  }

  @override
  void dispose() {
    viewModel.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // L'animation builder pour le cercle
          AnimatedBuilder(
            animation: viewModel.heightAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: viewModel.opacityAnimation.value,
                child: ClipPath(
                  clipper: CircleClipper(),
                  child: Container(
                    height: viewModel.heightAnimation.value,
                    width: double.infinity,
                    color: AppPalette.etsLightRed,
                  ),
                ),
              );
            },
          ),
          RefreshIndicator(
            onRefresh: () async {},
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Padding entre le top du screen et du texte
                    SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accueil',

                            /// TODO Changer pour le Theme.of(context).text ...
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.normal,
                              color: AppPalette.grey.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Bonjour, John Doe!',
                            style: TextStyle(fontSize: 16, color: AppPalette.grey.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              height: 145,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppPalette.grey.darkGrey,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                "Encore 4 jours et c'est fini !",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppPalette.grey.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              height: 145,
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                color: AppPalette.grey.darkGrey,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Progression',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppPalette.grey.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// TODO Wrapper le container dans une classe Card ...
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
                                  color: AppPalette.grey.darkGrey,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
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
                                  color: AppPalette.grey.darkGrey,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
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
                                  color: AppPalette.grey.darkGrey,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
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
                                  color: AppPalette.grey.darkGrey,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  color: AppPalette.etsLightRed,
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
        ],
      ),
    );
  }
}
