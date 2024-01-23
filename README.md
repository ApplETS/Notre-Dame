<div align="center">
  <img src="https://raw.githubusercontent.com/ApplETS/Notre-Dame/master/docs/images/ETS_logo.png" />
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

This project is the placeholder for the fourth version of ÉTSMobile, a mobile which application that is currently
available for Android and iOS. ÉTSMobile is the main gateway between the user and
the [École de technologie supérieure (ÉTS)](https://www.etsmtl.ca/) on mobile devices. ÉTSMobile is an open-source
project and is developped by members of the student club [ApplETS](https://clubapplets.ca/). It offers:

* Access to evaluation grades
* Access to the student's schedules
* And many more...

_Note: This guide is also available in: [Français](https://github.com/ApplETS/Notre-Dame/blob/master/README.fr.md)_

## Technologies used

* [Flutter](https://flutter.dev)

## Requirements

- Flutter SDK v3.3.10
```sh
# to downgrade flutter version to the required version, simply do theses steps:
$ cd /path/to/flutter
$ git checkout 3.3.10
$ flutter doctor
# Make sure the output of flutter doctor is alright
```
- Openssl v1.1.1g or higher
- Java sdk 11

## Before running the code

- To access some features you will need the SignetsAPI certificate, these files are encrypted. To decrypt them you will have to do two simple steps:

You need to copy the script `env_variables.sh` (only available on the Google Drive of the club) to the root folder of your project, then run:

```sh
chmod +x ./scripts/decrypt.sh
chmod +x ./env_variables.sh
./env_variables.sh
```

## Run the code

- After cloning the repo, you will have to get the packages and generate the l10n classes. To do that run the following
  command:

```
flutter pub get
```

## Add environment variable for API_KEY

- To add the Google Maps API TOKEN and the GitHub API TOKEN, you need to rename the file `.env.template` into `.env`. In
  the `.env` file, you need to paste the Google Maps API TOKEN and the GitHub API TOKEN.

## Git hooks

You can find under the folder `.githooks` all the hooks needed for this project. To configure git to use this folder
enter the following command:

```bash
git config core.hooksPath .githooks
```

## 📦 DevContainer

You can run the project in a container that has all the good versions of the libraries ready to go.
Steps tu run it:
1. Install Docker, VSCode and the Dev Containers extention for vscode.
2. Open the project with vscode a popup will suggest opening the project in a dev container.*
4. Once the container is up and running you will have a prompt in the vscode terminal to accept licenses.
5. Pair and connect your android phone using ADB wireless debugging to debug the app.

\* if you cannot see the popup suggesting the dev container environment try you can run the vscode command: `Dev Containers: Rebuild and Reopen in Container`

## ⚖️ License

This projet is licensed under the Apache License V2.0. See
the [LICENSE](https://github.com/ApplETS/Notre-Dame/blob/master/LICENSE) file for more info.
