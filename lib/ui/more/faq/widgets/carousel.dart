import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notredame/ui/more/faq/models/faq.dart';
import 'package:notredame/ui/more/faq/models/faq_questions.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.controller,
  });

  final PageController controller;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final _sizes = <int, Size>{};
  final faq = Faq();

  @override
  void didUpdateWidget(Carousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    _sizes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) => _SizingContainer(
        sizes: _sizes,
        page: widget.controller.hasClients ? widget.controller.page ?? 0 : 0,
        child: child!,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => PageView(
          controller: widget.controller,
          children: [
            for (final (i, questionItem) in faq.questions.indexed)
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.hardEdge,
                children: [
                  SizedBox.fromSize(size: _sizes[i]),
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: _SizeAware(
                      child: _card(questionItem),
                      // don't setState, we'll use it in the layout phase
                      onSizeLaidOut: (size) {
                        _sizes[i] = size;
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _card(QuestionItem questionItem) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.0,
            children: <Widget>[
              Text(
                questionItem.title,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 20,
                    ),
              ),
              Text(
                questionItem.description,
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
            ],
          ),
        ));
  }
}

typedef _OnSizeLaidOutCallback = void Function(Size);

class _SizingContainer extends SingleChildRenderObjectWidget {
  const _SizingContainer({
    super.child,
    required this.sizes,
    required this.page,
  });

  final Map<int, Size> sizes;
  final double page;

  @override
  _RenderSizingContainer createRenderObject(BuildContext context) {
    return _RenderSizingContainer(
      sizes: sizes,
      page: page,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizingContainer renderObject,
  ) {
    renderObject
      ..sizes = sizes
      ..page = page;
  }
}

class _RenderSizingContainer extends RenderProxyBox {
  _RenderSizingContainer({
    RenderBox? child,
    required Map<int, Size> sizes,
    required double page,
  })  : _sizes = sizes,
        _page = page,
        super(child);

  Map<int, Size> _sizes;

  Map<int, Size> get sizes => _sizes;

  set sizes(Map<int, Size> value) {
    if (_sizes == value) return;
    _sizes = value;
    markNeedsLayout();
  }

  double _page;

  double get page => _page;

  set page(double value) {
    if (_page == value) return;
    _page = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child case final child?) {
      child.layout(
        constraints.copyWith(
          minWidth: constraints.maxWidth,
          minHeight: 0,
          maxHeight: constraints.hasBoundedHeight ? null : double.maxFinite,
        ),
        parentUsesSize: true,
      );

      final a = sizes[page.floor()]!;
      final b = sizes[page.ceil()]!;

      final height = lerpDouble(a.height, b.height, page - page.floor());

      child.layout(
        constraints.copyWith(minHeight: height, maxHeight: height),
        parentUsesSize: true,
      );
      size = child.size;
    } else {
      size = computeSizeForNoChild(constraints);
    }
  }
}

class _SizeAware extends SingleChildRenderObjectWidget {
  const _SizeAware({
    required Widget child,
    required this.onSizeLaidOut,
  }) : super(child: child);

  final _OnSizeLaidOutCallback onSizeLaidOut;

  @override
  _RenderSizeAware createRenderObject(BuildContext context) {
    return _RenderSizeAware(
      onSizeLaidOut: onSizeLaidOut,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSizeAware renderObject) {
    renderObject.onSizeLaidOut = onSizeLaidOut;
  }
}

class _RenderSizeAware extends RenderProxyBox {
  _RenderSizeAware({
    RenderBox? child,
    required _OnSizeLaidOutCallback onSizeLaidOut,
  })  : _onSizeLaidOut = onSizeLaidOut,
        super(child);

  _OnSizeLaidOutCallback? _onSizeLaidOut;

  _OnSizeLaidOutCallback get onSizeLaidOut => _onSizeLaidOut!;

  set onSizeLaidOut(_OnSizeLaidOutCallback value) {
    if (_onSizeLaidOut == value) return;
    _onSizeLaidOut = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();

    onSizeLaidOut(
      getDryLayout(
        constraints.copyWith(maxHeight: double.infinity),
      ),
    );
  }
}
