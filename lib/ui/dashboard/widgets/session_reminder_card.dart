// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/view_model/cards/session_reminder_card_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_bottom_sheet.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_utils.dart';

class SessionReminderCard extends StatelessWidget {
  const SessionReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SessionReminderCardViewmodel>.reactive(
      viewModelBuilder: () => SessionReminderCardViewmodel(intl: AppIntl.of(context)!),
      builder: (context, model, child) {
        return SessionReminderCardContent(
          reminder: model.sessionReminder,
          loading: model.isBusy,
          allReminders: model.allSessionReminders,
          carouselReminders: model.carouselReminders,
        );
      },
    );
  }
}

class SessionReminderCardContent extends StatefulWidget {
  final SessionReminder? reminder;
  final bool loading;
  final List<SessionReminder> allReminders;
  final List<SessionReminder> carouselReminders;

  const SessionReminderCardContent({
    super.key,
    required this.reminder,
    required this.loading,
    this.allReminders = const [],
    this.carouselReminders = const [],
  });

  @override
  State<SessionReminderCardContent> createState() => _SessionReminderCardContentState();
}

class _SessionReminderCardContentState extends State<SessionReminderCardContent> with WidgetsBindingObserver {
  PageController? _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  bool get _isCarousel => widget.carouselReminders.length > 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_isCarousel) {
      _initCarousel();
    }
  }

  @override
  void didUpdateWidget(SessionReminderCardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carouselReminders.length != widget.carouselReminders.length) {
      _disposeCarousel();
      if (_isCarousel) {
        _currentPage = 0;
        _initCarousel();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseAutoScroll();
    } else if (state == AppLifecycleState.resumed && _isCarousel) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCarousel();
    super.dispose();
  }

  void _initCarousel() {
    _pageController = PageController();
    _startAutoScroll();
  }

  void _disposeCarousel() {
    _pauseAutoScroll();
    _pageController?.dispose();
    _pageController = null;
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_pageController != null && _pageController!.hasClients) {
        final nextPage = (_currentPage + 1) % widget.carouselReminders.length;
        _pageController!.animateToPage(nextPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.reminder != null && widget.allReminders.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: context.theme.appColors.dashboardCard,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: tappable
              ? () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  builder: (_) => SessionReminderBottomSheet(reminders: widget.allReminders),
                )
              : null,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final intl = AppIntl.of(context)!;

    if (widget.loading) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Skeletonizer(
          enabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Bone.icon(size: 24),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [Bone.text(words: 2), SizedBox(height: 6), Bone.text(words: 3)],
              ),
            ],
          ),
        ),
      );
    }

    if (widget.reminder == null) {
      return Center(
        child: Text(
          intl.session_reminder_none,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
      );
    }

    if (_isCarousel) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 20.0),
            child: Listener(
              onPointerDown: (_) => _pauseAutoScroll(),
              onPointerUp: (_) => _startAutoScroll(),
              onPointerCancel: (_) => _startAutoScroll(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.carouselReminders.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildReminderContent(context, intl, widget.carouselReminders[index]);
                },
              ),
            ),
          ),
          Positioned(bottom: 8, left: 0, right: 0, child: Center(child: _buildDotIndicators())),
        ],
      );
    }

    return Padding(padding: const EdgeInsets.all(16.0), child: _buildReminderContent(context, intl, widget.reminder!));
  }

  Widget _buildReminderContent(BuildContext context, AppIntl intl, SessionReminder reminder) {
    const iconSize = 24.0;
    const iconPadding = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(color: AppPalette.etsLightRed.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(reminder.type.icon, size: iconSize, color: AppPalette.etsLightRed),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: AutoSizeText(
            sessionReminderEventName(intl, reminder.type),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
            minFontSize: 10,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sessionReminderTimingText(intl, context, reminder),
          style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.carouselReminders.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isActive ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppPalette.etsLightRed : AppPalette.etsLightRed.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
