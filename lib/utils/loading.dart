// Flutter imports:
import 'package:flutter/material.dart';

Widget buildLoading() => Stack(
      children: [
        const Center(child: CircularProgressIndicator())
      ],
    );
