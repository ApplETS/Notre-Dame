// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:material_ui/material_ui.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/titled_card.dart';
import 'package:notredame/ui/ets/quick_links/view_model/quick_links_viewmodel.dart';
import 'package:notredame/ui/ets/quick_links/widgets/web_link_card.dart';

const _carouselMaxHeight = 160.0;

const _tileWidth = 95.0;
const _padding = 8.0;
const _tileSpacing = 2.0;

// Carousel timing
const _autoScrollInterval = Duration(seconds: 10);
const _pageAnimationDuration = Duration(milliseconds: 600);
const _dotAnimationDuration = Duration(milliseconds: 300);

// Dot indicators
const _dotActiveWidth = 12.0;
const _dotInactiveWidth = 6.0;
const _dotHeight = 6.0;
const _dotInactiveAlpha = 0.5;
const _dotsBottom = 4.0;
const _maxDots = 10;

class QuickLinksCard extends StatelessWidget {
  const QuickLinksCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QuickLinksViewModel>.reactive(
      viewModelBuilder: () => QuickLinksViewModel(AppIntl.of(context)!),
      builder: (context, model, child) => LayoutBuilder(
        builder: (context, cardConstraints) {
          final bool carousel = cardConstraints.maxHeight < _carouselMaxHeight;
          return TitledCard(
            title: AppIntl.of(context)!.useful_link_title,
            child: Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final int linksPerRow = max(1, (constraints.maxWidth / _tileWidth).floor());
                  return carousel
                      ? _QuickLinksCarousel(links: model.quickLinkList, linksPerPage: linksPerRow)
                      : _grid(model.quickLinkList, linksPerRow, context.theme.appColors.backgroundAlt);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _grid(List<QuickLink> links, int crossAxisCount, Color backgroundColor) {
    return GridView.count(
      padding: const EdgeInsets.all(_padding),
      mainAxisSpacing: _tileSpacing,
      crossAxisSpacing: _tileSpacing,
      crossAxisCount: crossAxisCount,
      children: links.map((link) => WebLinkCard(link, key: ValueKey(link.id), backgroundColor: backgroundColor)).toList(),
    );
  }
}

/// One row of links per page, auto-scrolling like the session reminder carousel.
class _QuickLinksCarousel extends StatefulWidget {
  final List<QuickLink> links;
  final int linksPerPage;

  const _QuickLinksCarousel({required this.links, required this.linksPerPage});

  int get pageCount => (links.length / linksPerPage).ceil();

  @override
  State<_QuickLinksCarousel> createState() => _QuickLinksCarouselState();
}

class _QuickLinksCarouselState extends State<_QuickLinksCarousel> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(_QuickLinksCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageCount != widget.pageCount) {
      _currentPage = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
      _startAutoScroll();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseAutoScroll();
    } else if (state == AppLifecycleState.resumed) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _pauseAutoScroll();
    if (widget.pageCount <= 1) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.pageCount;
        _pageController.animateToPage(nextPage, duration: _pageAnimationDuration, curve: Curves.easeInOut);
      }
    });
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool showDots = widget.pageCount > 1;
    return Stack(
      children: [
        Listener(
          onPointerDown: (_) => _pauseAutoScroll(),
          onPointerUp: (_) => _startAutoScroll(),
          onPointerCancel: (_) => _startAutoScroll(),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.pageCount,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.fromLTRB(
                _padding,
                _tileSpacing,
                _padding,
                showDots ? _dotsBottom + _dotHeight + _tileSpacing : _tileSpacing,
              ),
              child: _buildPage(index),
            ),
          ),
        ),
        if (showDots)
          Positioned(
            bottom: _dotsBottom,
            left: 0,
            right: 0,
            child: Center(child: _buildDotIndicators()),
          ),
      ],
    );
  }

  Widget _buildPage(int page) {
    final int start = page * widget.linksPerPage;
    final List<QuickLink> pageLinks = widget.links.sublist(
      start,
      min(start + widget.linksPerPage, widget.links.length),
    );
    return Row(
      spacing: _tileSpacing,
      children: [
        ...pageLinks.map((link) => Expanded(child: WebLinkCard(link, key: ValueKey(link.id), backgroundColor: context.theme.appColors.backgroundAlt))),
        // Keep tiles the same width on the last, partially filled page.
        for (int i = pageLinks.length; i < widget.linksPerPage; i++) const Expanded(child: SizedBox()),
      ],
    );
  }

  /// Shows at most [_maxDots] dots, in a window that follows the current page.
  Widget _buildDotIndicators() {
    final int dotCount = min(widget.pageCount, _maxDots);
    final int firstPage = (_currentPage - dotCount ~/ 2).clamp(0, widget.pageCount - dotCount);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (i) {
        final int index = firstPage + i;
        final isActive = index == _currentPage;
        return AnimatedContainer(
          key: ValueKey(index),
          duration: _dotAnimationDuration,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isActive ? _dotActiveWidth : _dotInactiveWidth,
          height: _dotHeight,
          decoration: BoxDecoration(
            color: isActive ? AppPalette.etsLightRed : AppPalette.etsLightRed.withValues(alpha: _dotInactiveAlpha),
            borderRadius: BorderRadius.circular(_dotHeight / 2),
          ),
        );
      }),
    );
  }
}
