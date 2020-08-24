import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notredame/core/models/quick_link_model.dart';

class WebLinkCard extends StatelessWidget {
  final QuickLink _links;

  const WebLinkCard(this._links);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                flex: 40,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Image.asset(_links.image),
                ),
              ),
              Text(
                _links.name,
                style: const TextStyle(color: Colors.red, fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
