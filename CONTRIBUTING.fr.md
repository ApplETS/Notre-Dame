# Contribuer

Lors de la contribution à ce répertoire, veuillez commencer par discuter des changements que vous
souhaitez appliquer par le biais d'un "_issue_", email, ou tout autre moyen avec le propriétaire de ce
répertoire.

Prendre note que nous avons un code de conduite, veuillez le suivre pour toutes vos interactions
avec ce projet.

## Processus de codage

1. Nommer votre branche en suivant le format suivant:
   `{feature/patch/bugfix}/#{issue number}-{issue description}`
    - Exemple: `feature/#68-migration-to-null-safety`
2. Laisser le code dans un meilleur état qu’avant vos modifications. Cela signifie effectuer une
   refactoring dans les zones autour du code modifié.
3. Testez vos modifications à l’aide de tests unitaires.
4. Exécutez `flutter analyze` avant de soumettre une demande d’extraction et corrigez les problèmes
   découverts.

### Contrôle de version

Le CI met automatiquement à jour la version dans le fichier `pubspec.yaml` en ouvrant une "
pull request" en utilisant les étiquettes: `version: Major`,`version: Minor` ou `version: Patch`.

- `version: Major`: utilisé lorsqu'un changement complet de UI est effectué ou lorsqu'un changement
  majeur dans le fonctionnement du projet.
- `version: Minor`: utilisé lorsqu'une nouvelle fonctionnalité est ajouté dans l'application
- `version: Patch`: utilisé lorsque aucune fonctionnalité a été ajouté au prjet. Cela inclut le
  formatage, patches, réglage de bug, etc.

## Processus des "Pull Request"

1. **Définir un problème relié**

Si vous voulez suggérer des modification, svp faire un `Issue` pour en discuter.
<br/>Pour plus d'information:
[Lien de la documentation sur les "GitHub Issues"](https://docs.github.com/fr/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword)
<br/>SVP inscrire le `Issue` ici: (utiliser le mot-clé `closes: #12345`)

2. **Description**

Décrire vos changements en détails.

3. **Est-ce que cela a été testé ?**

S'il vous plait, décrire comment vous avez testé vos changements.
Inclure les détails de vos tests unitaires ansi que les tests manuel effectués, comment vos
changement ont affecté le code de d'autre fichiers, etc.

4. **Liste à remplir avant de demander un révision de code**

Assurer vous de bien remplir ces critère selon la nature de vos modifications:

- [ ] J'ai performé une auto-révision de mon code
- [ ] Si c'est une fonctionnalité mère, j'ai ajouté des tests approfondis.
- [ ] Devons-nous mettre en œuvre des analyses?
- [ ] Assurez-vous d’ajouter l’une des étiquettes suivantes: `version: Major`,`version: Minor` ou
  `version: Patch`.

5. **Capture d'écran (si nécessaire)**

Si c’est un changement visuel, veuillez fournir une capture d’écran.

## Code de Conduite

### Notre Engagement

Afin de favoriser un environnement ouvert et accueillant, nous les contributeurs et mainteneurs
s’engagent à participer à notre projet et notre communauté une expérience sans harcèlement pour tout
le monde, peu importe l’âge, condition physique, handicap, origine ethnique, identité et expression
de genre, niveau d’expérience, nationalité, apparence personnelle, race, religion ou identité
sexuelle et orientation.

### Nos Standards

Voici des exemples de comportements qui contribuent à la création d’un environnement positif:

* Utiliser un langage accueillant et inclusif
* Respecter les points de vue et les expériences différents
* Accepter gracieusement les critiques constructives
* Se concentrer sur ce qui est le mieux pour la collectivité
* Faire preuve d’empathie envers les autres membres de la communauté

Voici des exemples de comportements inacceptables:

* L’utilisation d’un langage ou d’images sexualisés et une attention sexuelle ou des avances non
  désirée
* Trolling, insultes/commentaires désobligeants et attaques personnelles ou politiques
* Harcèlement public ou privé
* Publier les renseignements personnels d’autrui, comme une adresse physique ou électronique, sans
  autorisation explicite
* Autres comportements qui pourraient raisonnablement être considérés comme inappropriés dans un
  contexte professionnel

### Nos Responsabilités

Les responsables du projet sont chargés de clarifier les normes de comportement acceptable et
doivent prendre des mesures correctives appropriées et équitables en réponse à tout cas de
comportement inacceptable.

Les responsables du projet ont le droit et la responsabilité de supprimer, modifier ou rejeter des
commentaires, des confirmations, du code, des modifications au wiki, des problèmes et d’autres
contributions qui ne sont pas alignées sur ce code de conduite, ou d’interdire temporairement ou
définitivement tout contributeur pour d’autres comportements qu’ils jugent inappropriés, menaçants,
offensants ou nuisibles.

### Champ d'Application

Ce code de conduite s’applique aussi bien dans les espaces du projet que dans les espaces publics
lorsqu’une personne représente le projet ou sa communauté. Les exemples de représentation d’un
projet ou d’une communauté comprennent l’utilisation d’une adresse électronique officielle du
projet, la publication par l’intermédiaire d’un compte officiel sur les médias sociaux ou le fait
d’agir en tant que représentant désigné à un événement en ligne ou hors ligne. La représentation
d’un projet peut être définie et clarifiée par les responsables du projet.

### Application des Règlement

Les cas de comportement abusif, harcelant ou inacceptable peuvent être signalés en communiquant avec
l’équipe du projet à [applets@etsmtl.ca](mailto:applets@etsmtl.ca). Toutes les plaintes feront
l’objet d’un examen et d’une enquête, et donneront lieu à une réponse jugée nécessaire et appropriée
aux circonstances. L’équipe de projet est tenue de respecter la confidentialité à l’égard du
déclarant d’un incident. De plus amples détails sur les politiques d’application spécifiques peuvent
être affichés séparément.

Les responsables du projet qui ne suivent pas ou n’appliquent pas le code de bonne foi peuvent être
confrontés à des répercussions temporaires ou permanentes déterminées par d’autres membres de la
direction du projet.

### Attribution

Le présent code de conduite est une adaptation du [Contributor Covenant](http://contributor-covenant.org), version 1.4,
disponible à l’adresse suivante: [http://contributor-covenant.org/version/1/4](http://contributor-covenant.org/version/1/4/)
