import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';

class BroadcastMessageCard extends StatelessWidget {
  final DashboardViewModel _model;

  const BroadcastMessageCard({super.key, required DashboardViewModel model})
      : _model = model;

  @override
  Widget build(BuildContext context) {
    if (_model.broadcastMessage == "" ||
        _model.broadcastColor == "" ||
        _model.broadcastTitle == "") {
      return const SizedBox.shrink();
    }
    final broadcastMsgColor = Color(int.parse(_model.broadcastColor));
    final broadcastMsgType = _model.broadcastType;
    final broadcastMsgUrl = _model.broadcastUrl;
    return Card(
        key: UniqueKey(),
        color: broadcastMsgColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
          child: _model.busy(_model.broadcastMessage)
              ? const Center(child: CircularProgressIndicator())
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  // title row
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_model.broadcastTitle,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          child: getBroadcastIcon(
                              broadcastMsgType, broadcastMsgUrl),
                        ),
                      ),
                    ],
                  ),
                  // main text
                  Text(_model.broadcastMessage,
                    style: Theme.of(context).primaryTextTheme.bodyMedium)
                ]),
        ));
  }

  Widget getBroadcastIcon(String type, String url) {
    switch (type) {
      case "warning":
        return const Icon(
          Icons.warning_rounded,
          color: AppTheme.lightThemeBackground,
          size: 36.0,
        );
      case "alert":
        return const Icon(
          Icons.error,
          color: AppTheme.lightThemeBackground,
          size: 36.0,
        );
      case "link":
        return IconButton(
          onPressed: () {
            DashboardViewModel.launchBroadcastUrl(url);
          },
          icon: const Icon(
            Icons.open_in_new,
            color: AppTheme.lightThemeBackground,
            size: 30.0,
          ),
        );
    }
    return const Icon(
      Icons.campaign,
      color: AppTheme.lightThemeBackground,
      size: 36.0,
    );
  }
}