<div align="center">
  <img src="https://raw.githubusercontent.com/ApplETS/Notre-Dame/master/docs/images/ETS_logo.png" alt="ETS"/>
  <p>
    <br /><strong>Projet Notre-Dame</strong>
    <br />
    <br />
    <a href="https://github.com/ApplETS/Notre-Dame/actions/workflows/master-workflow.yaml" style="text-decoration: none;">
      <img src="https://github.com/ApplETS/Notre-Dame/actions/workflows/master-workflow.yaml/badge.svg?branch=master" alt="Statut de la compilation"/>
    </a>
    <img src="https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/clubapplets-server/e51406de3b919a69f396642a2bcb413c/raw/notre_dame_master_badge_coverage.json" alt="Code coverage"/>
    <br />
    <img src="https://img.shields.io/endpoint?color=green&logo=google-play&logoColor=green&url=https%3A%2F%2Fplay.cuzi.workers.dev%2Fplay%3Fi%3Dca.etsmtl.applets.etsmobile%26l%3DPlay%2520Store%2520version%26m%3Dv%24version" alt="Play store version"/>
    <br />
    <img src="https://img.shields.io/itunes/v/557463461?label=App%20Store%20version&logo=appstore" alt="App store version"/>
    <br />
  </p>
</div>

Ce projet concrétise la quatrième version de l'application mobile ÉTSMobile pour Android et iOS. Il
s'agit du portail principal entre l'utilisateur et
l'[École de technologie supérieure (ÉTS)](https://www.etsmtl.ca/) sur appareils mobiles. ÉTSMobile
est un projet open-source développé par les membres du club
étudiant [ApplETS](https://clubapplets.ca/). L'application offre notamment :

* L'accès aux notes d'évaluations
* L'accès aux horaires de cours
* Et bien plus...

<ins>_Note: This guide is also available in: [English](README.md)_<ins/>

## Technologies utilisées

* Flutter [[Accueil](https://docs.flutter.dev) |
  [Téléchargement](https://docs.flutter.dev/get-started/install)]

## Requis

- Flutter SDK v3.32.0 ou supérieure
- Openssl v1.1.1g ou supérieure
- Java sdk 17

## Configuration de Flutter

- Télécharger le SDK Flutter à partir de la
  section ["Technologies utilisées"](#Technologies-utilisées)
  et suivre les instructions officielles.<br>
  (Il est recommandé d'utiliser 7-Zip pour l'extraction du fichier)
- Ouvrir le menu des paramètres et s'assurer que les extensions Flutter et Dart sont bien
  installées.
- Dans le menu des paramètres, se rendre dans la section "Languages & Frameworks".
    - <ins>Flutter</ins>: Ajouter le chemin vers le dossier Flutter.
    - <ins>Dart</ins>: Ajouter le chemin du dossier "flutter/bin/cache/dart-sdk" du dossier Flutter
      et cocher Notre-Dame comme projet supporté.

## Avant de démarrer le code

- Pour avoir accès à certaines fonctionnalités vous allez avoir besoin du certificat de SignetsAPI,
  la clef Google Drive, etc. Ces fichiers sont encryptés.
  Pour les décrypter, vous allez devoir exécuter le script `env_variables.sh` (disponible uniquement
  sur le Google Drive du club), puis exécuter les commandes suivantes à la racine du projet:

### Linux

```sh
chmod +x ./scripts/decrypt.sh
chmod +x ./env_variables.sh
./env_variables.sh
```

### Windows

Dans une invite de commande GitBash

```sh
sh "env_variables.sh"
```

## Démarrer le code

- Pour générer les classes pour l'internationalisation (l10n), exécuter les commandes suivantes:

```bash
flutter pub get
```

- Pour générer les mocks:

```bash
dart run build_runner build
```

## Git hooks

Vous pouvez trouver dans le dossier `.githooks` l'ensemble des hooks pour git. Pour configurer git
afin d'utiliser ce dossier, saisir la commande suivante:

```bash
git config core.hooksPath .githooks
```

## Comment renouveler les certificats Apple

Suivre la procédure de
ce [répertoire](https://github.com/ApplETS/fastlane-ios-certificates/blob/master/README.md),
accessible uniquement par les groupes admin et devops.

## Comment contribuer au projet

Vous pouvez contribuer au projet en suivant les instructions de ce [document](CONTRIBUTING.fr.md)
