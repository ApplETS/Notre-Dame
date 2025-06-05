<div align="center">
  <img src="https://raw.githubusercontent.com/ApplETS/Notre-Dame/master/docs/images/ETS_logo.png"  alt="ETS"/>
  <p>
    <br /><strong>Notre-Dame Project</strong>
    <br />
    <br />
    <a href="https://github.com/ApplETS/Notre-Dame/actions/workflows/master-workflow.yaml" style="text-decoration: none;">
        <img src="https://github.com/ApplETS/Notre-Dame/actions/workflows/master-workflow.yaml/badge.svg?branch=master" alt="Build Status"/>
    </a>
    <img src="https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/clubapplets-server/e51406de3b919a69f396642a2bcb413c/raw/notre_dame_master_badge_coverage.json" alt="Code coverage"/>
    <br />
    <img src="https://img.shields.io/endpoint?color=green&logo=google-play&logoColor=green&url=https%3A%2F%2Fplay.cuzi.workers.dev%2Fplay%3Fi%3Dca.etsmtl.applets.etsmobile%26l%3DPlay%2520Store%2520version%26m%3Dv%24version" alt="Play store version"/>
    <br />
    <img src="https://img.shields.io/itunes/v/557463461?label=App%20Store%20version&logo=appstore" alt="App store version"/>
    <br />
  </p>
</div>

This project is the placeholder for the fourth version of ÉTSMobile, a mobile application that
is currently available for Android and iOS. ÉTSMobile is the main gateway between the user and
the [École de technologie supérieure (ÉTS)](https://www.etsmtl.ca/) on mobile devices. ÉTSMobile is
an open-source project and is developped by members of the student
club [ApplETS](https://clubapplets.ca/). It offers:

* Access to evaluation grades
* Access to the student's schedules
* And many more...

<ins>_Note: Ce guide est aussi disponible en: [Français](README.fr.md)_<ins/>

## Technologies used

* Flutter [[Home](https://docs.flutter.dev) |
  [Download](https://docs.flutter.dev/get-started/install)]

## Requirements

- Flutter SDK v3.24.3 or higher
- Openssl v1.1.1g or higher
- Java sdk 17

## Setting up Flutter (Android Studio)

- Download the Flutter SDK bundle from the ["Technologies used"](#technologies-used) section and
  follow the official guide.<br>
  (It is recommended to use 7-zip to extract the file)
- Open the settings menu and make sure that both the Flutter and Dart plugins are
  installed.
- Open the settings menu and navigate to "Languages & Frameworks".
  - <ins>Flutter</ins>: Add the path of the Flutter folder.
  - <ins>Dart</ins>: Add the path of the folder "flutter/bin/cache/dart-sdk" from the Flutter folder
    and add Notre-Dame as a supported project.

## Before running the code

- To access some features you will need the SignetsAPI certificate, these files are encrypted. To
  decrypt them you will have to do two simple steps:

You need to copy the script `env_variables.sh` (only available on the Google Drive of the club) to
the root folder of your project, then run:

### Linux and MacOS

```sh
chmod +x ./scripts/decrypt.sh
chmod +x ./env_variables.sh
./env_variables.sh
```

### Windows

In a GitBash command prompt
```sh
sh "env_variables.sh"
```

## Run the code

- After cloning the repo, you will have to get the packages and generate the l10n classes. To do
  that run the following command:

```
flutter pub get
```

- To generate the mocks:
```
dart run build_runner build
```

## Git hooks

You can find under the folder `.githooks` all the hooks needed for this project. To configure git to
use this folder enter the following command:

```bash
git config core.hooksPath .githooks
```

## How to renew apple certificates:

Follow the procedure in
this [repo](https://github.com/ApplETS/fastlane-ios-certificates/blob/master/README.md) available
only by admin group and devops group:

## How to contribute to the project

You can contribute to the project by following these [instructions](CONTRIBUTING.md)
