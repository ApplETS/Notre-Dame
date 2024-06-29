import 'package:flutter/material.dart';

class ClassInfo extends StatelessWidget {
  final String info;

  const ClassInfo({required this.info});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            info,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
}
