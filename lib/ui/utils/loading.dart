import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';

Widget buildLoading({bool isInteractionLimitedWhileLoading = true}) => Stack(
      children: [
        if (isInteractionLimitedWhileLoading)
          const Opacity(
            opacity: 0.5,
            child: ModalBarrier(dismissible: false, color: Colors.grey),
          ),
        const Center(
            child: CircularProgressIndicator(
          color: AppTheme.etsLightRed,
        ))
      ],
    );
