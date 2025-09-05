// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/ets/quick_links/security_info/view_model/security_viewmodel.dart';
import 'package:notredame/ui/ets/quick_links/security_info/widgets/emergency_view.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  @override
  Widget build(BuildContext context) => ViewModelBuilder<SecurityViewModel>.reactive(
    viewModelBuilder: () => SecurityViewModel(intl: AppIntl.of(context)!),
    builder: (context, model, child) => BaseScaffold(
      appBar: AppBar(title: Text(AppIntl.of(context)!.ets_security_title)),
      showBottomBar: false,
      safeArea: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 32.0),
          child: Column(spacing: 12, children: [map(), joinSecurity(), emergencyProcedures(model)]),
        ),
      ),
    ),
  );

  Widget map() => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          color: context.theme.appColors.backgroundAlt,
          child: SvgPicture.asset(
            "assets/images/emergency_meeting_points_${context.theme.brightness.name}.svg",
            width: constraints.maxWidth,
          ),
        ),
      );
    },
  );

  Widget joinSecurity() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppIntl.of(context)!.security_reach_security,
        style: const TextStyle(color: AppPalette.etsLightRed, fontSize: 24),
      ),
      Card(
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          onTap: () {
            try {
              _launchUrlService.call(AppIntl.of(context)!.security_emergency_number);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          child: ListTile(
            leading: const Icon(Icons.phone, size: 30),
            title: Text(AppIntl.of(context)!.security_emergency_call),
            subtitle: Text(AppIntl.of(context)!.security_emergency_number),
          ),
        ),
      ),
      Card(
        elevation: 0,
        color: Colors.transparent,
        child: ListTile(
          leading: const Icon(Icons.phone, size: 30),
          title: Text(AppIntl.of(context)!.security_emergency_intern_call),
          subtitle: Text(AppIntl.of(context)!.security_emergency_intern_number),
        ),
      ),
    ],
  );

  Widget emergencyProcedures(SecurityViewModel model) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppIntl.of(context)!.security_emergency_procedures,
          style: const TextStyle(color: AppPalette.etsLightRed, fontSize: 24),
        ),
        for (int i = 0; i < model.emergencyProcedureList.length; i++)
          Card(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EmergencyView(model.emergencyProcedureList[i].title, model.emergencyProcedureList[i].detail),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
                    child: Text(model.emergencyProcedureList[i].title, style: const TextStyle(fontSize: 18)),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.arrow_forward_ios)),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
