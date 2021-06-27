// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/profile_viewmodel.dart';

// WIDGETS
import 'package:notredame/ui/widgets/student_program.dart';
import 'package:notredame/ui/utils/loading.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ProfileViewModel>.reactive(
          viewModelBuilder: () => ProfileViewModel(intl: AppIntl.of(context)),
          builder: (context, model, child) {
            return RefreshIndicator(
              onRefresh: () => model.refresh(),
              child: Stack(
                children: [
                  ListView(padding: const EdgeInsets.all(0.0), children: [
                    ListTile(
                      title: Text(
                        AppIntl.of(context).profile_student_status_title,
                        style: const TextStyle(color: AppTheme.etsLightRed),
                      ),
                    ),
                    ListTile(
                      title: Text(AppIntl.of(context).profile_balance),
                      trailing: Text(model.profileStudent.balance),
                    ),
                    const Divider(
                      thickness: 2,
                      indent: 10,
                      endIndent: 10,
                    ),
                    ListTile(
                      title: Text(
                        AppIntl.of(context).profile_personal_information_title,
                        style: const TextStyle(color: AppTheme.etsLightRed),
                      ),
                    ),
                    ListTile(
                      title: Text(AppIntl.of(context).profile_first_name),
                      trailing: Text(model.profileStudent.firstName),
                    ),
                    ListTile(
                      title: Text(AppIntl.of(context).profile_last_name),
                      trailing: Text(model.profileStudent.lastName),
                    ),
                    ListTile(
                        title: Text(AppIntl.of(context).profile_permanent_code),
                        trailing: Text(model.profileStudent.permanentCode)),
                    ListTile(
                        title: Text(
                            AppIntl.of(context).login_prompt_universal_code),
                        trailing: Text(model.universalAccessCode)),
                    ListView.builder(
                      padding: const EdgeInsets.all(0.0),
                      shrinkWrap: true,
                      reverse: true,
                      physics: const ScrollPhysics(),
                      itemCount: model.programList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return StudentProgram(model.programList[index]);
                      },
                    ),
                  ]),
                  if (model.isBusy)
                    buildLoading(isInteractionLimitedWhileLoading: false)
                  else
                    const SizedBox()
                ],
              ),
            );
          });

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, List<String> tabs, int index) {
    final discovery =
        getDiscoveryByFeatureId(context, 'page_student_page_profile');

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      contentLocation: ContentLocation.below,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsDarkPurple,
      tapTarget: Tab(
        text: tabs[index],
      ),
      pulseDuration: const Duration(seconds: 5),
      child: Tab(
        text: tabs[index],
      ),
    );
  }
}
