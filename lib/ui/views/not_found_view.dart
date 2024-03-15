// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rive/rive.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/viewmodels/not_found_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class NotFoundView extends StatefulWidget {
  final String? pageName;

  const NotFoundView({this.pageName});

  @override
  _NotFoundState createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFoundView> {
  late NotFoundViewModel viewModel;

  _NotFoundState();

  @override
  void initState() {
    viewModel = NotFoundViewModel(pageName: widget.pageName ?? '');
    viewModel
        .loadRiveAnimation()
        .then((_) => setState(() => viewModel.startRiveAnimation()));

    super.initState();
  }

  Widget _buildAnimatedWidget() {
    return viewModel.artboard != null
        ? SizedBox(
            width: 100,
            height: 80,
            child: Rive(
              artboard: viewModel.artboard!,
              fit: BoxFit.fitWidth,
            ))
        : Container();
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
                            bottom: 60,
                          ),
                          child: _buildAnimatedWidget(),
                        ),
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
                              backgroundColor: AppTheme.primary,
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
