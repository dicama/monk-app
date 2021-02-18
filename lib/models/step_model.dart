class StepModel {
  final int id;
  final String header;
  final String description;
  final List<String> choice;

  StepModel({this.id, this.header, this.description, this.choice});

  static List<StepModel> list = [
    StepModel(
        header: "Datenschutz",
        description: ""
    ),
    StepModel(
        header: "Fragebogen",
        description: "Um dein individuelles Dashboard zu gestalten helfe MONK dabei dich kennenzulernen\n\n Deine persönlichen Daten sind hierbei stets sicher und nur lokal sowie verschlüsselt auf deinem Smartphone hinterlegt.\n\n Du kannst den Fragebogen jederzeit überspringen und deine persönlichen Infos später über deine Profileinstellungen anpassen."
    ),
    StepModel(
      header: "Name",
      description: "Wir wollen dich in MONK persönlich ansprechen.\n\n Du kannst an dieser Stelle deinen echten Namen eingeben oder ein Pseudonym, mit dem du dich wohl fühlst.\n\n Falls du nichts eingeben möchtest, dann klicke einfach weiter.",
    ),
    StepModel(
      header: "Alter",
      description: "Dein Alter kann für unterschiedliche Module und Funktionen von MONK relevant sein.\n\n  Beispielsweise kann MONK für dich zukünftig alters-spezifische Informationen wie passende Studien bereitstellen.",
    ),
    StepModel(
      header: "Geschlecht",
      description: "MONK bietet dir die Möglichkeit unterschiedliche Module für deine persönliche App zu laden.\n\n Falls du passende Module von uns vorgeschlagen bekommen möchtest, hilft uns die Information deines Geschlechts dabei dir eine entsprechende Vorauswahl zu präsentieren.",
    ),
    StepModel(
        header: "Krebsart",
        description: "MONK bietet dir die Möglichkeit unterschiedliche Module für deine persönliche App zu laden. \n\n Falls du passende Module von uns vorgeschlagen bekommen möchtest, hilft uns die Information deiner Krebsart dir eine entsprechende Vorauswahl zu präsentieren.",
    ),
    StepModel(
      header: "Diagnosetag",
      description: "Um deine Diagnosedaten und alle weitere Daten chronologisch zu ordnen, kannst du den Tag deiner Diagnose angeben.",
    ),
    StepModel(
      header: "geschafft!",
        choice: ["Dokumentenverwaltung", "Stuhltracker",],
      description: "Vielen Dank für deine Angaben und dein Vertrauen in MONK!",
    ),
  ];
}
