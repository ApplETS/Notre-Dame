# Contribuer

Lors de la contribution à ce répertoire, veuillez commencer par discuter des changements que vous
souhaitez appliquer par le biais d'un "issue", email, ou tout autre moyen avec le propriétaire de ce
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
Pour plus d'information:
[Lien de la documentation sur les "GitHub Issues"](https://docs.github.com/fr/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword)

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

In the interest of fostering an open and welcoming environment, we as
contributors and maintainers pledge to making participation in our project and
our community a harassment-free experience for everyone, regardless of age, body
size, disability, ethnicity, gender identity and expression, level of experience,
nationality, personal appearance, race, religion, or sexual identity and
orientation.

Afin de favoriser un environnement ouvert et accueillant, nous les contributeurs et mainteneurs
s’engagent à participer à notre projet et notre communauté une expérience sans harcèlement pour tout
le monde, peu importe l’âge, condition physique, handicap, origine ethnique, identité et expression
de
genre, niveau d’expérience, nationalité, apparence personnelle, race, religion ou identité sexuelle
et orientation.

### Nos Standards

Examples of behavior that contributes to creating a positive environment
include:

* Using welcoming and inclusive language
* Being respectful of differing viewpoints and experiences
* Gracefully accepting constructive criticism
* Focusing on what is best for the community
* Showing empathy towards other community members

Examples of unacceptable behavior by participants include:

* The use of sexualized language or imagery and unwelcome sexual attention or advances
* Trolling, insulting/derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information, such as a physical or electronic address, without explicit
  permission
* Other conduct which could reasonably be considered inappropriate in a professional setting

### Our Responsibilities

Project maintainers are responsible for clarifying the standards of acceptable
behavior and are expected to take appropriate and fair corrective action in
response to any instances of unacceptable behavior.

Project maintainers have the right and responsibility to remove, edit, or
reject comments, commits, code, wiki edits, issues, and other contributions
that are not aligned to this Code of Conduct, or to ban temporarily or
permanently any contributor for other behaviors that they deem inappropriate,
threatening, offensive, or harmful.

### Scope

This Code of Conduct applies both within project spaces and in public spaces
when an individual is representing the project or its community. Examples of
representing a project or community include using an official project e-mail
address, posting via an official social media account, or acting as an appointed
representative at an online or offline event. Representation of a project may be
further defined and clarified by project maintainers.

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be
reported by contacting the project team at applets@etsmtl.ca. All
complaints will be reviewed and investigated and will result in a response that
is deemed necessary and appropriate to the circumstances. The project team is
obligated to maintain confidentiality with regard to the reporter of an incident.
Further details of specific enforcement policies may be posted separately.

Project maintainers who do not follow or enforce the Code of Conduct in good
faith may face temporary or permanent repercussions as determined by other
members of the project's leadership.

### Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage], version 1.4,
available at [http://contributor-covenant.org/version/1/4][version]

[homepage]: http://contributor-covenant.org

[version]: http://contributor-covenant.org/version/1/4/
