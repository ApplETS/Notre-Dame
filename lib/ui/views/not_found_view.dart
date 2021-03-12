// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:rive/rive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/not_found_viewmodel.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class NotFoundView extends StatefulWidget {
  final String pageName;

  const NotFoundView({this.pageName});

  @override
  _NotFoundState createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFoundView> {
  NotFoundViewModel viewModel;

  _NotFoundState();

  @override
  void initState() {
    viewModel = NotFoundViewModel(widget.pageName);
    viewModel
        .loadRiveAnimation()
        .then((_) => setState(() => viewModel.startRiveAnimation()));

    super.initState();
  }

  Widget _buildAnimatedWidget() {
    return viewModel.artboard != null
        ? Rive(
            artboard: viewModel.artboard,
            fit: BoxFit.scaleDown,
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<NotFoundViewModel>.nonReactive(
          viewModelBuilder: () => NotFoundViewModel(widget.pageName),
          builder: (context, model, child) => Scaffold(
                body: SafeArea(
                  minimum: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 40,
                              ),
                              child: _buildAnimatedWidget()),
                        ),
                        Text(
                          AppIntl.of(context).not_found_title,
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 80,
                            bottom: 60,
                          ),
                          child: Text(
                            AppIntl.of(context)
                                .not_found_message(model.notFoundPageName),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: AppTheme.primary,
                            ),
                            onPressed: () {
                              model.navigateToDashboard();
                            },
                            child: Text(AppIntl.of(context).go_to_dashboard),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
}
