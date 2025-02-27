import 'package:flutter/material.dart';
import 'package:notredame/domain/broadcast_icon_type.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';

class BroadcastMessageCard extends StatelessWidget {
  final DashboardViewModel _model;

  const BroadcastMessageCard({super.key, required DashboardViewModel model})
    : _model = model;

  @override
  Widget build(BuildContext context) {
    return Card(
        key: UniqueKey(),
        color: _model.broadcastMessage!.color,
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
                          child: Text(_model.broadcastMessage!.title,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          child: getBroadcastIcon(
                              _model.broadcastMessage!.type, _model.broadcastMessage!.url, context),
                        ),
                      ),
                    ],
                  ),
                  // main text
                  Text(_model.broadcastMessage!.message,
                    style: Theme.of(context).primaryTextTheme.bodyMedium)
                ]),
        ));
  }

  Widget getBroadcastIcon(BroadcastIconType type, String url, BuildContext context) {
    switch (type) {
      case BroadcastIconType.warning:
        return Icon(
          Icons.warning_rounded,
          color: context.theme.primaryTextTheme.titleLarge!.color,
          size: 36.0,
        );
      case BroadcastIconType.alert:
        return Icon(
          Icons.error,
          color: context.theme.primaryTextTheme.titleLarge!.color,
          size: 36.0,
        );
      case BroadcastIconType.link:
        return IconButton(
          onPressed: () => DashboardViewModel.launchBroadcastUrl(url),
          icon: Icon(
            Icons.open_in_new,
            color: context.theme.primaryTextTheme.titleLarge!.color,
            size: 30.0,
          ),
        );
      case BroadcastIconType.other:
        return Icon(
          Icons.campaign,
          color: context.theme.primaryTextTheme.titleLarge!.color,
          size: 36.0,
        );
    }
  }
}