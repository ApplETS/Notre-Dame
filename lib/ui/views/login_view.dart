// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/generated/l10n.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
          body: Container(
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 60.0, bottom: 60.0),
        color: const Color.fromRGBO(239, 62, 69, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white70)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: AppIntl.of(context).login_prompt_universal_code,
                  hintStyle: TextStyle(color: Colors.white54)),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white70)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: AppIntl.of(context).login_prompt_password,
                  hintStyle: TextStyle(color: Colors.white54)),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 30.0,
            ),
            SizedBox(
              width: double.infinity,
              child: FlatButton(
                onPressed: () {},
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text(
                  AppIntl.of(context).login_title,
                  style: const TextStyle(
                      color: Color.fromRGBO(239, 62, 69, 1), fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ));
}
