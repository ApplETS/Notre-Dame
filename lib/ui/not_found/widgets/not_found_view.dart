// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/theme/app_palette.dart';
import 'package:notredame/ui/not_found/view_model/not_found_viewmodel.dart';

class NotFoundView extends StatefulWidget {
  final String? pageName;

  const NotFoundView({super.key, this.pageName});

  @override
  State<NotFoundView> createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFoundView> {
  late NotFoundViewModel viewModel;

  _NotFoundState();

  @override
  void initState() {
    viewModel = NotFoundViewModel(pageName: widget.pageName ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NotFoundViewModel>.nonReactive(
          viewModelBuilder: () => viewModel,
          builder: (context, model, child) => Scaffold(
                body: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 80,
                          ),
                          child: Text(
                            AppIntl.of(context)!.not_found_title,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 70,
                          ),
                          child: Text(
                            AppIntl.of(context)!
                                .not_found_message(model.notFoundPageName),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.etsLightRed,
                          ),
                          onPressed: () {
                            model.navigateToDashboard();
                          },
                          child: Text(AppIntl.of(context)!.go_to_dashboard),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
}
