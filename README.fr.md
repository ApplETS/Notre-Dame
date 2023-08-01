<div align="center">
  <img src="https://raw.githubusercontent.com/ApplETS/Notre-Dame/master/docs/images/ETS_logo.png" />
  <p>
    <br /><strong>Projet Notre-Dame</strong>
    <br />
    <br />
    <a href="https://github.com/ApplETS/Notre-Dame/actions/workflows/master-workflow.yaml" style="text-decoration: none;">
      <img src="https://github.com/ApplETS/Notre-Dame/actions/workflows/master-workflow.yaml/badge.svg?branch=master" alt="Statut de la compilation"/>
    </a>
    <img src="https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/clubapplets-server/e51406de3b919a69f396642a2bcb413c/raw/notre_dame_master_badge_coverage.json" alt="Code coverage"/>
    <br />
    <img src="https://img.shields.io/endpoint?color=green&logo=google-play&logoColor=green&url=https%3A%2F%2Fplayshields.herokuapp.com%2Fplay%3Fi%3Dca.etsmtl.applets.etsmobile%26l%3DPlay%2520Store%2520version%26m%3D%24version" alt="Play store version"/>
    <br />
    <img src="https://img.shields.io/itunes/v/557463461?label=App%20Store%20version&logo=appstore" alt="App store version"/>
    <br />
  </p>
</div>

Ce projet concrétise la quatrième version de l'application mobile ÉTSMobile pour Android et iOS. Il s'agit de portail principal entre l'utilisateur et l'École de technologie supérieure (ÉTS) sur appareils mobiles. ÉTSMobile est un projet open-source développé par les membres du club étudiant ApplETS. L'application offre notamment :

* L'accès aux notes d'évaluations
*  L'accès aux horaires de cours
*  Et bien plus...

_Note: Ce guide est aussi disponible en: [English](https://github.com/ApplETS/Notre-Dame/blob/master/README.md)_

## Technologies utilisées

* [Flutter](https://flutter.dev)

## Requis

- Flutter SDK v3.3.10
```sh
# pour rétrograder la version de flutter à la version requise, il suffit de faire :
$ flutter downgrade 3.3.10
```
- Openssl v1.1.1g ou supérieure
- Java sdk 11

## Avant de démarrer le code

- Pour avoir accès a certaines fonctionnalités vous allez avoir besoin du certificat de SignetsAPI, la clef Google Drive., etc. , ces fichiers sont encrypté.
  Pour les décrypter vous allez devoir exécuter le script `env_variables.sh` (disponible uniquement sur le Google Drive du club), 
- puis exécuter les commandes suivantes à la racine du projet:
```sh
chmod +x ./scripts/decrypt.sh
chmod +x ./env_variables.sh
./env_variables.sh
```

## Démarrer le code

- Pour générer les classes pour l'internationalisation, exécuter les commandes suivantes:
```bash
flutter pub get
```

## Ajouter une variable d'environnement pour une API_KEY
- Pour ajouter le Google Maps API TOKEN et le GitHub API TOKEN, vous devez renommer le fichier `.env.template` en `.env`.
Dans le fichier `.env` , vous devez ajouter le Google Maps API TOKEN et le GitHub API TOKEN.


## Git hooks

Vous pouvez trouver dans le dossier `.githooks` l'ensemble des hooks pour git. Pour configurer git afin d'utiliser ce dossier, saisir la commande suivante:
```bash
git config core.hooksPath .githooks
```

## ⚖️ License
Ce projet est licencié selon la licence Apache V2.0. Voir le fichier [LICENSE](https://github.com/ApplETS/Notre-Dame/blob/master/LICENSE) pour plus d'informations.
