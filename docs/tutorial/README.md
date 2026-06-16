# THWS Tutorial / Übungsblatt — Redesign (Typst)

Schlankes `tutorial`-Format in derselben Designsprache wie Reader & Handout (CI-Orange
`#EC6500` · Teal `#005564` · Helvetica/Arial). **Kein Deckblatt**, kompakter Masthead
(„ÜBUNGSBLATT · Nr. xx"), Kopfzeile auf jeder Seite. Reines Markdown — Lösungen über Quartos
**natives** `content-visible`, kein eigener Filter-Mechanismus dafür.

## Dateien

```
_extensions/tutorial/
├── _extension.yml
├── typst-template.typ
├── typst-show.typ
├── filter.lua              (minimal: nur Logo-Auto-Resolve + web_url)
├── thws-logo.svg           (deutsche Wortmarke, horizontal)
└── thws-logo_en.svg        (englische Wortmarke, horizontal)
```

## Autoren-Format

Das folgende Schema zeigt alle Elemente des Übungsblatt-Formats.

**YAML-Kopf** (alles außer `title` optional, alles erscheint im Masthead):

```yaml
title: "Real Options Analysis"
subtitle: "…"
lang: en                # de → „ÜBUNGSBLATT"+dt. Logo · en → „WORKSHEET"+engl. Logo
author: [{ name: …, email: …, role: …, affiliation: … }]
course: "Corporate Finance"   # Masthead MODUL + Kopfzeile links
semester: "WS 2025/26"        # Kopfzeile rechts
sheet: "07"                   # Eyebrow „… · No. 07"
date: last-modified           # AUSGABE · sprachabhängig formatiert
show_solutions: false
format: tutorial-typst
```

Der Meta-Streifen zeigt bewusst nur **MODUL · DOZENT · AUSGABE** (sonst bricht der Name um).

> ⚠️ **Wichtig — erste Zeile muss ein `# Titel` (H1) sein.** Er erscheint nicht im Text (der
> Masthead zeigt den Titel), **verankert aber die Überschriften-Level**. Nur mit H1 bleibt
> `##` = Level 2 = große Aufgabe und `####` = Level 4 = Teilaufgabe. **Ohne** H1 schiebt Quarto
> alle Level um eins hoch und kein Stil (Badge, Pille) greift mehr.

**Überschriften-Hierarchie** (H1-Titel vorausgesetzt):

| Ebene | Rolle | Rendering |
|---|---|---|
| `# Titel` | Dokumenttitel | **unsichtbar** im Text (nur Level-Anker; Masthead zeigt ihn). |
| `## Label N: Titel` | **große Aufgabe** | dickes oranges **Nummern-Badge** + Kicker (= Label) + Titel; geparst. `## Case Study 1: …`, `## Aufgabe 3: …`, `## Fallstudie 2: …` funktionieren alle. **Beginnt auf neuer Seite** (außer der ersten). |
| `## Titel` (ohne „Wort N:") | Info-/Zwischenabschnitt | schlichte Teal-Überschrift, **kein** Badge, **kein** Seitenumbruch. |
| `### …` | **Reserve** | optionale Zwischen-Überschrift. |
| `#### Task N: Titel [P P]` | **Teilaufgabe** | `Task N` (Label folgt `lang`) + Titel + **Punkte-Pille**. |

**Punkte pro Teilaufgabe:** am Ende der H4-Überschrift in eckigen Klammern —
`[3 P]`, `[3 Punkte]` oder `[3]`. Wird geparst, als Pille rechts gerendert und vom Titel entfernt.

Kontext/Angabe stehen direkt unter der H2 (kein Zwischen-`###` nötig). Tabellen, Mathe (`$…$` /
`$$…$$`), Code-Blöcke und Block­zitate (`>`) funktionieren wie üblich.

## Lösungen ein-/ausblenden — Quarto nativ

Lösungen in einen `content-visible`-Block mit `when-meta` setzen:

```markdown
#### Task 1: …
Frage / Aufgabenstellung …

::: {.content-visible when-meta="show_solutions"}
**Solution:** …

**Grading Notes:** …
:::
```

Steuerung über die Metadatenvariable `show_solutions` — beide Varianten aus *einer* Quelle:

```bash
quarto render tutorial-07.qmd --to tutorial-typst -M show_solutions:true    # mit Lösungen
quarto render tutorial-07.qmd --to tutorial-typst -M show_solutions:false   # Angabe-Blatt
```

(Oder `show_solutions: false` fest im YAML-Header.) Das macht Quarto ohne Filter/Template-Code —
der frühere `solutions:`-Schalter im Filter war redundant (und las sogar den falschen Key).

## Logo & Sprache

`lang` steuert Logo **und** den Masthead-Eyebrow (`de` → „ÜBUNGSBLATT" + deutsches Logo,
`en` → „WORKSHEET" + englisches Logo). Logo-Pfade müssen **nicht** angegeben werden — der Filter
löst die mitgelieferten SVGs automatisch relativ zur Extension auf. Eigenes Logo optional über
`tutorial-logo:` / `tutorial-logo-en:`. Das Datum (`date` / `last-modified`) wird sprachabhängig
formatiert (DE `16.06.2026`, EN `June 16, 2026`).

Übungsblatt-spezifische Masthead-Felder (alle optional): `sheet` (→ „Nr. xx"), `time`
(Bearbeitungszeit), `points` (Punkte gesamt), `course`, `semester`.

## Änderungsprotokoll — angeglichen an `reader` (2026-06-16)

Getestet an einer Muster-`.qmd` (`--to tutorial-typst`, `show_solutions` true/false, EN & DE).

| Bereich | Änderung |
|---|---|
| **Filter** | Von 277 auf ~35 Zeilen eingedampft: nur noch **Logo-Auto-Resolve** (`resolvePath` + `make_relative`, Keys `tutorial-logo` / `-en`) und **web_url** (QR). Der redundante `SHOW_SOLUTIONS`-Schalter sowie die ungenutzten Spezial-Div-Transformationen (`.aufgabe`, `.loesung`, Flashcards, Quiz, Lückentext) **entfernt** — Lösungen macht Quarto nativ. |
| `typst-show.typ` | Reservierter `logo`-Key → eigene Keys `tutorial-logo` / `tutorial-logo-en` mit `.replace`; `date` als String durchgereicht. |
| `typst-template.typ` (`thws-logo`) | Recolor robust (Regex, auch bei internem `<style>`); `height:`-Parameter. |
| `typst-template.typ` | Sprachweiche `logo_en` + `active-logo`; **horizontale** Logos über `height` (Kopf 11 mm, vertikal zentriert); Blockzitat-**Einzelstrich** statt Doppellinie; Masthead-Titel gegen Blocksatz (`set par(justify: false)`); Datum sprachabhängig. |
| `typst-template.typ` (Nummerierung, wie Mockup) | **H2** = große Aufgaben → dickes oranges **Nummern-Badge** + Kicker + Titel; Nummer *und* Kicker werden aus der Überschrift geparst (`"Case Study 1: …"` → Badge `1`, Kicker `CASE STUDY`) — bezeichnungs-/sprachagnostisch, respektiert die manuelle Zählung (pro Aufgabe zurückgesetzt). **H3** = Überleitung (Context/Tasks). **H4** = kleine Tasks → `Task N` orange + Titel, ohne Badge. Helfer `to-string` zieht den Klartext aus dem Heading. Passt eine Überschrift nicht ins „Wort N:"-Schema → schlichte Standard-Überschrift. |
| `typst-template.typ` (entfernt) | Die toten Funktionen `#eyebrow`, `#aufgabe`, `#loesung`, `#flashcard` und der Aufgaben-Counter — nach dem Filter-Schlankheitskur nicht mehr aufgerufen. |

Logo-Verdrahtung identisch zum `reader` (nur Key-Präfix `tutorial-`).

## Umgebung

Getestet mit Quarto 1.9.37 / Typst 0.14.2. `@preview/cades:0.3.1` (QR) wird beim Render geladen.
`liberation sans` (letzter Schrift-Fallback) erzeugt eine harmlose Warnung.
