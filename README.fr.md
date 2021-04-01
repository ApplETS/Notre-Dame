<div align="center">
  <img src="https://raw.githubusercontent.com/ApplETS/Notre-Dame/master/docs/images/ETS_logo.png" />
  <p>
    <br /><strong>Projet Notre-Dame</strong>
    <br />
    <a href="https://travis-ci.org/ApplETS/Notre-Dame" style="text-decoration: none;">
        <img src="https://travis-ci.com/ApplETS/Notre-Dame.svg?branch=master" alt="Build Status"/>
    </a>
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

- Flutter SDK v1.17.4 ou supérieure
- Openssl v1.1.1g ou supérieure

## Avant de démarrer le code

- Pour avoir accès a certaines fonctionnalités vous allez avoir besoin du certificat de SignetsAPI, ces fichiers sont encrypté.
  Pour les décrypter vous allez devoir exécuter le script `env_variables.sh` (disponible uniquement sur le Google Drive du club), puis exécuter les commandes suivantes:
```
chmod +x ./scripts/decrypt.sh
./scripts/decrypt.sh
```

## Démarrer le code

- Pour générer les classes pour l'internationalisation, exécuter les commandes suivantes:
```
flutter pub get
```
## Ajouter la variable d'environnement pour GITHUB_API_KEY

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
