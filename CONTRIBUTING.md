# 🤝 Contribuer à ÉTS Mobile

Merci de votre intérêt pour contribuer à **ÉTS Mobile** ! Ce guide explique comment participer au projet.

> **Important** : Avant de soumettre une contribution, veuillez d'abord discuter du changement désiré via une issue, email, ou toute autre méthode avec les mainteneurs du dépôt.

**Table des matières**
- [Conventions de Code](#Conventions-de-Code)
- [Processus de Contribution](#processus-de-contribution)
- [Signaler des Bugs](#signaler-des-bugs)
- [Processus de Pull Request](#processus-de-pull-request)
- [Standards de Qualité](#Standards-de-qualité)
- [Code de conduite](#code-de-conduite)

---

## 💻 Conventions de Code

Consultez le **[Guide des Conventions de Code](https://github.com/ApplETS/Notre-Dame/wiki/Convention-de-code)** pour les détails complets.

### Vue d'Ensemble Rapide

#### Formatage
- **Indentation** : 2 espaces
- **Longueur de ligne** : Max 100 caractères
- **Utiliser** `dart format lib test` et `dart run import_sorter:main` avant de committer

#### Nommage
- **Classes** : `PascalCase` (ex: `CourseViewModel`)
- **Variables/Fonctions** : `camelCase` (ex: `getSchedule()`)
- **Constantes** : `camelCase` (ex: `maxRetries`)
- **Fichiers** : `snake_case` (ex: `schedule_view.dart`)

#### Organisation du Code
```dart
class MyClass {
  // 1. Variables finales / static
  // 2. Propriétés
  // 3. Constructeur
  // 4. Getters / Setters
  // 5. Méthodes public
  // 6. Méthodes private
}
```

#### Documentation
```dart
/// Docstring avec trois slashes
/// Explique le rôle de la fonction
String getFullName(String firstName, String lastName) => '$firstName $lastName';
```

#### Null Safety
- Utiliser `?` pour les types nullable
- Préférer les valeurs par défaut
- Utiliser `??` et `?.` quand approprié

#### Exception Handling
```dart
// ✅ BON : Attraper les exceptions spécifiques
try {
  await repository.getData();
} on NetworkException catch (e) {
  handleNetworkError(e);
} on ParseException catch (e) {
  handleParseError(e);
}

// ❌ MAUVAIS : Attraper toutes les exceptions
try {
  await repository.getData();
} catch (e) {
  print(e);
}
```

Pour plus de détails, consultez [Conventions de Code](https://github.com/ApplETS/Notre-Dame/wiki/Convention-de-code).

---

## 🐛 Signaler des Bugs

### Créer une Issue de Bug

1. Allez sur **[GitHub Issues](https://github.com/ApplETS/Notre-Dame/issues)**
2. Cliquez **"New Issue"** → **"Bug Report"**
3. Remplissez le formulaire avec :
   - **Titre** : Description courte et claire (ex: "L'horaire n'affiche pas les cours du vendredi")
   - **Description** : Explique le bug détaillé
   - **Reproduire** : Étapes pour reproduire le bug
   - **Comportement attendu** : Ce qui devrait se passer
   - **Environnement** : OS, version Flutter, device

---

## 🔄 Processus de Contribution

### 1. Choisir ou Créer une Issue

- Consultez les [issues ouvertes](https://github.com/ApplETS/Notre-Dame/issues)
- Assignez-vous à une issue existante ou créez-en une nouvelle
- Attendez la confirmation d'un mainteneur avant de commencer

### 2. Forker et Cloner

```bash
# Forker le dépôt (via GitHub)
# Cloner votre fork
git clone https://github.com/VOTRE-USERNAME/Notre-Dame.git
cd Notre-Dame

# Ajouter le dépôt upstream
git remote add upstream https://github.com/ApplETS/Notre-Dame.git
```

### 3. Créer une Branche

```bash
# Format: {type}/{issue-number}-{description}
# Types: feature, bugfix, refactor, chore

git checkout -b feature/#123-add-schedule-filters
git checkout -b bugfix/#456-fix-null-crash
```

### 4. Développer et Tester

```bash
# Installer les dépendances
flutter pub get

# Générer le code (mocks, modèles, etc.)
dart run build_runner build --delete-conflicting-outputs

# Développer votre feature
# ...

# Tester localement
flutter test
flutter analyze

# Formatter le code
dart format .
```

### 5. Committer les Changements

```bash
# Ajouter les fichiers modifiés
git add .

# Committer avec un message clair
git commit -m "feature: add schedule filters (#123)"

# Formats acceptés:
# feature: Nouvelle fonctionnalité
# bugfix: Correction de bug
# refactor: Refactorisation
# docs: Changements de documentation
# test: Ajout/modification de tests
# chore: Changements de configuration
```

### 6. Pousser et Créer une Pull Request

```bash
# Mettre à jour avec upstream
git fetch upstream
git rebase upstream/develop  # Si vous travaillez sur develop

# Pousser votre branche
git push origin feature/#123-add-schedule-filters
```

Allez sur [GitHub](https://github.com/ApplETS/Notre-Dame) et cliquez **"Compare & pull request"**.

### 7. Versioning Automatique

Le CI met à jour automatiquement la version dans `pubspec.yaml` via le label de la PR :

- **`version: Major`** : Redesign complet ou réécriture majeure
- **`version: Minor`** : Ajout de fonctionnalité
- **`version: Patch`** : Bugfix, refactoring, tests, docs (défaut)

Ajoutez le label approprié à votre PR.

---

## 📋 Processus de Pull Request

### Avant de Créer une PR

✅ **Checklist**

- [ ] Code conforme aux [conventions](https://github.com/ApplETS/Notre-Dame/wiki/Convention-de-code)
- [ ] `flutter analyze` sans erreurs
- [ ] `dart format` appliqué
- [ ] Tests unitaires passent (`flutter test`)
- [ ] Widget tests ajoutés pour l'UI
- [ ] Couverture de code ≥ 70%
- [ ] Git hooks configurés (`git config core.hooksPath .githooks`)
- [ ] Branche à jour avec `main` ou `develop`
- [ ] Pas de commits merge non nécessaires
- [ ] Messages de commit clairs et informatifs

## 📚 Ressources

- Docs: [Architecture](https://github.com/ApplETS/Notre-Dame/wiki/Architecture-(haut-niveau))

#### 3. Labels Obligatoires

Ajoutez l'un des labels de version :
- `version: Major` - Redesign/réécriture
- `version: Minor` - Nouvelle fonctionnalité
- `version: Patch` - Bugfix, refactoring, tests

Et d'autres labels si pertinent :
- `type: feature`, `type: bugfix`, `type: docs`
- `area: ui`, `area: api`, `area: testing`
- `priority: high`, `priority: medium`, `priority: low`

#### 4. Assignation

Assignez-vous à la PR pour montrer que vous y travaillez.

### Après la Création

1. **Le CI s'exécutera automatiquement** :
   - Tests unitaires
   - Analyse statique (`flutter analyze`)
   - Génération de builds Android/iOS
   - Couverture de code

2. **Attendez les retours** des reviewers

3. **Répondez aux commentaires** :
   - Apportez les modifications demandées
   - Poussez les changements à la même branche
   - Répondez aux commentaires pour montrer que c'est résolu
   - Évitez de forcer un push (`git push --force`) sauf si nécessaire

4. **Approbations** :
   - Au moins 1 approval avant merge (de préférence 2 pour les features importantes)
   - Tous les CI checks doivent passer
   - Branche doit être à jour

---

## ✅ Standards de Qualité

### Couverture de Code

- **Minimum** : 70% de couverture
- **Cible** : 85-90% pour les features
- Vérifier avec : `flutter test --coverage`

### Testing

Consultez le [Guide de Testing](https://github.com/ApplETS/Notre-Dame/wiki/Tests) :

- **Unit tests** : 70% du code
- **Widget tests** : 20% pour l'UI
- **E2E tests** : 10% pour les flows critiques


### Performance

- Pas de jank (`flutter run` puis regarder le FPS)
- Pas de memory leaks (DevTools)
- Temps de startup < 3 secondes
- Taille APK < 50 MB (non compressé)

### Sécurité

- Pas de hardcoding de secrets (API keys, tokens)
- Utiliser `FlutterSecureStorage` pour données sensibles
- Valider toutes les entrées utilisateur
- HTTPS pour toutes les requêtes API

## 🆘 Besoin d'Aide?

- **Wiki Technique** : [wiki](https://github.com/ApplETS/Notre-Dame/wiki)
- **Troubleshooting** : [troubleshooting.md](https://github.com/ApplETS/Notre-Dame/wiki/Troubleshooting)
- **Email** : [applets@etsmtl.ca](mailto:applets@etsmtl.ca)
- **Discord/Slack** : Demandez au club ApplETS

---

## Code de conduite

### Notre engagement

Dans le but de favoriser un environnement ouvert et accueillant, nous, en tant que contributeurs et responsables du projet, nous engageons à faire de la participation à notre projet et à notre communauté une expérience sans harcèlement pour tous,
indépendamment de l’âge, de la corpulence, du handicap, de l’origine ethnique, de
l’identité et de l’expression de genre, du niveau d’expérience, de la nationalité,
de l’apparence physique, de la race, de la religion ou de l’orientation sexuelle.

### Nos standards

Exemples de comportements contribuant à créer un environnement positif :

* Utiliser un langage accueillant et inclusif  
* Faire preuve de respect envers les opinions et expériences différentes  
* Accepter avec bienveillance les critiques constructives  
* Se concentrer sur ce qui est le mieux pour la communauté  
* Faire preuve d’empathie envers les autres membres de la communauté  

Exemples de comportements inacceptables de la part des participants :

* L’utilisation de propos ou d’images à caractère sexuel, ainsi que toute attention ou avance sexuelle non sollicitée  
* Le trolling, les commentaires insultants ou dégradants, et les attaques personnelles ou politiques  
* Le harcèlement public ou privé  
* La publication d’informations privées d’autrui, telles qu’une adresse physique ou électronique, sans autorisation explicite  
* Tout autre comportement pouvant raisonnablement être considéré comme inapproprié dans un cadre professionnel  

### Nos responsabilités

Les responsables du projet sont chargés de clarifier les standards de comportement
acceptable et sont tenus de prendre des mesures correctives appropriées et équitables
en réponse à tout comportement inacceptable.

Les responsables du projet ont le droit et la responsabilité de supprimer, modifier
ou rejeter des commentaires, commits, code, modifications du wiki, issues et autres
contributions qui ne respectent pas ce Code de conduite, ou de bannir temporairement
ou définitivement tout contributeur pour d’autres comportements jugés inappropriés,
menaçants, offensants ou nuisibles.

### Portée

Ce Code de conduite s’applique à la fois dans les espaces du projet et dans les espaces
publics lorsqu’une personne représente le projet ou sa communauté. Des exemples de
représentation incluent l’utilisation d’une adresse e-mail officielle du projet, la
publication via un compte officiel sur les réseaux sociaux ou le fait d’agir en tant
que représentant désigné lors d’un événement en ligne ou hors ligne. La représentation
du projet peut être précisée davantage par les responsables du projet.

### Application

Les cas de comportement abusif, de harcèlement ou autrement inacceptables peuvent être
signalés en contactant l’équipe du projet à [applets@etsmtl.ca](mailto:applets@etsmtl.ca).
Toutes les plaintes seront examinées et feront l’objet d’une enquête, donnant lieu à
une réponse jugée nécessaire et appropriée aux circonstances. L’équipe du projet est
tenue de préserver la confidentialité de la personne ayant signalé un incident.
Des détails supplémentaires concernant les politiques d’application spécifiques peuvent
être publiés séparément.

Les responsables du projet qui n’appliquent pas ou ne respectent pas le Code de conduite
de bonne foi peuvent faire l’objet de sanctions temporaires ou permanentes, déterminées
par les autres membres de la direction du projet.

### Attribution

Ce Code de conduite est adapté du [Contributor Covenant][homepage], version 1.4,
disponible à l’adresse [http://contributor-covenant.org/version/1/4][version].

---

**Merci de votre contribution! 🎉**

Pour toute question, ouvrez une discussion ou contactez l'équipe ApplETS.
