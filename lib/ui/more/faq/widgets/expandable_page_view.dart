import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/more/faq/widgets/size_reporting_widget.dart';

class ExpandablePageView extends StatefulWidget {
  final List<Widget> children;

  const ExpandablePageView({
    super.key,
    required this.children,
  });

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> with TickerProviderStateMixin {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage];

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        final newPage = _pageController.page?.round() ?? 0;
        if (_currentPage != newPage) {
          setState(() => _currentPage = newPage);
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: _heights[0], end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView(
        controller: _pageController,
        children: _sizeReportingChildren
            .asMap() //
            .map((index, child) => MapEntry(index, child))
            .values
            .toList(),
      ),
    );
  }

  List<Widget> get _sizeReportingChildren => widget.children
      .asMap() //
      .map(
        (index, child) => MapEntry(
          index,
          OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) => setState(() => _heights[index] = size.height),
              child: Container(
                  padding: EdgeInsets.all(20.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: context.theme.appColors.faqCarouselCard,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: child),
            ),
          ),
        ),
      )
      .values
      .toList();
}
