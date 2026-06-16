# Changelog

## [2.0.0] — 2026-06-16

Überarbeitung der drei PDF-Formate `reader` / `handout` / `tutorial`. **`moodle-html` unverändert.**
Wird per `quarto add c-kraus/thws_quarto` ausgeliefert. Rückfall auf v1:
`quarto add c-kraus/thws_quarto@v1.0.0`.

### ⚠️ Breaking
- **Logo nicht mehr über `logo:`.** Der Key ist von Quartos Brand-System reserviert (kam nur als
  `"true"` an → Build-Fehler). **Migration:** `logo:`-Zeile **entfernen** (das THWS-Logo wird
  automatisch eingebunden) oder durch den format-eigenen Key ersetzen:
  `reader-logo:` / `handout-logo:` / `tutorial-logo:` (+ `…-logo-en:` für Englisch).

### Fixes
- **Bibliography unter Quarto ≥ 1.8.** Quarto erzeugt den `#bibliography(...)`-Call jetzt selbst;
  die Templates taten das zusätzlich → Typst-Fehler „multiple bibliographies are not yet supported".
  Behoben in allen drei Formaten: `bib_file` wird nicht mehr ans Template übergeben, ein
  `show bibliography`-Hook fängt Quartos Call ab und stylt ihn (Überschrift, Schrift, Abstände).

### reader / handout
- THWS-Logo **automatisch** aufgelöst (kein Pfad nötig), **horizontal**, per `lang` de/en.
- Robustes Recolor (weiß auf Cover, orange im Kopf), auch bei SVGs mit eigenem `<style>`.
- Box-Labels folgen `lang` (z. B. „Fallstudie" / „Case Study").
- Neue Inline-Boxen `::: {.merksatz}` und `::: {.begriff title="…"}`; `.flip-card`/`.details`
  farbcodiert. Zitate mit Einzelstrich; kurze Boxen brechen nicht über Seiten.
- Cover/Datum: Blocksatz-Fix, sprachabhängiges Datum (de `16.06.2026` / en `June 16, 2026`).
- Inhaltsverzeichnis: H1-Nummerierung in CI-Orange (reader an handout angeglichen).

### tutorial (Übungsblatt) — neu aufgebaut
- **Lösungen nativ** über `::: {.content-visible when-meta="show_solutions"}` (`show_solutions`-
  Schalter) statt Filter — der Filter ist auf Logo-Auto-Resolve eingedampft.
- **Heading-basiert:** `## Label N: Titel` → Nummern-Badge + Kicker + Seitenumbruch;
  `#### Task N: Titel` → Teilaufgabe (Label folgt `lang`); optional Punkte `[N P]`.
  Voraussetzung: erste Zeile `# Titel` (verankert die Level). Siehe `docs/tutorial/README.md`.
- Masthead nur Modul · Dozent · Ausgabe.

### Aufräumen
- Totes Root-`_extensions/_extension.yml` (verwies auf nicht existierende Templates) und leeres
  `_extensions/logo/` entfernt. Entwickler-Docs nach `docs/` ausgelagert (schlanke Auslieferung).

## [1.0.0] — `main` (Tag `v1.0.0`)
Stabiler Ausgangsstand vor dem Redesign.
