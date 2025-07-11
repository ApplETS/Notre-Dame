// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/ets/events/report_news/view_model/report_news.dart';
import 'package:notredame/ui/ets/events/report_news/view_model/report_news_viewmodel.dart';

class ReportNews extends StatefulWidget {
  final bool showHandle;
  final String newsId;

  const ReportNews({super.key, required this.newsId, this.showHandle = true});

  @override
  State<ReportNews> createState() => _ReportNewsState();
}

class _ReportNewsState extends State<ReportNews> {
  String _reason = "";
  bool clicked = false;
  int clickedIndex = -1;

  @override
  Widget build(BuildContext context) => ViewModelBuilder.reactive(
    viewModelBuilder: () => ReportNewsViewModel(),
    builder: (context, model, child) => SizedBox(
      height: 550,
      child: Column(
        children: [
          if (widget.showHandle) _buildHandle(context),
          if (!clicked) _buildTitle(context),
          Expanded(
            child: clicked && clickedIndex != -1
                ? Center(child: _buildReportView(context, clickedIndex, model))
                : ColoredBox(
                    color: context.theme.appColors.backgroundAlt,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 16, bottom: 32),
                      itemCount: getLocalizedReportNewsItems(context).length,
                      itemBuilder: (context, index) {
                        return _buildListTile(index);
                      },
                    ),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _buildHandle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.appColors.modalTitle,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: context.theme.appColors.modalHandle,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: context.theme.appColors.modalTitle),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 20, 20),
          child: Text(AppIntl.of(context)!.report_news, style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }

  Widget _buildListTile(int index) {
    final item = getLocalizedReportNewsItems(context)[index];
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(item.description),
          trailing: const Icon(Icons.navigate_next),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          onTap: () {
            setState(() {
              clicked = true;
              clickedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildReportView(BuildContext context, int index, ReportNewsViewModel model) {
    final String reportTitle = getLocalizedReportNewsItems(context)[index].title;
    final String reportCategory = getLocalizedReportNewsItems(context)[index].category;

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: AppPalette.grey.white),
              tooltip: AppIntl.of(context)!.go_back,
              onPressed: () {
                setState(() {
                  clicked = false;
                  clickedIndex = -1;
                });
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppIntl.of(context)!.report_as}\n${reportTitle.toLowerCase()}?',
                    style: TextStyle(color: AppPalette.grey.white, fontWeight: FontWeight.bold, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      decoration: InputDecoration(hintText: AppIntl.of(context)!.report_reason_hint),
                      minLines: 1,
                      onChanged: (reason) => _reason = reason,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(AppPalette.etsLightRed),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    ),
                    child: Text(AppIntl.of(context)!.report, style: TextStyle(color: AppPalette.grey.white)),
                    onPressed: () {
                      model.reportNews(widget.newsId, reportCategory, _reason);
                      Fluttertoast.showToast(msg: AppIntl.of(context)!.report_toast);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
