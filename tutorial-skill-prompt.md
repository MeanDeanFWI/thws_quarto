# Skill-Creator-Prompt — THWS Übungsblatt-Generator

> Diesen Text dem **skill-creator** geben, um einen Erstellungs-Skill für Übungsblätter
> im `tutorial-typst`-Format zu bauen.

---

Erstelle einen Skill, der **THWS-Übungsblätter als Quarto-`.qmd`** für das `tutorial-typst`-Format
erzeugt (Single-Source: PDF-Angabe + PDF mit Lösungen aus einer Datei). Trigger: „Übungsblatt
erstellen", „Aufgaben zu …", „Tutorial-Blatt", „mach mir ein Übungsblatt", „worksheet".

**Referenz / Musterdatei:** `tutorial-07-real-options.qmd` (zeigt alle Elemente). Halte dich
strikt an dieses Format. Die Extension liegt unter `_extensions/tutorial/`.

## Harte Format-Regeln (sonst greifen die Stile nicht)

1. **Erste Body-Zeile MUSS `# <Titel>` sein** (H1). Erscheint nicht im Text (der Masthead zeigt
   den Titel), **verankert aber die Heading-Level**. Ohne H1 schiebt Quarto alle Level um eins
   hoch und Badges/Stile brechen. Den Titeltext gleich wie `title:` im YAML setzen.
2. **Große Aufgabe = `## Label N: Titel`** → bekommt automatisch ein oranges Nummern-Badge +
   Kicker (= „Label") + Seitenumbruch davor (außer der ersten). Beispiele: `## Aufgabe 1: …`,
   `## Case Study 2: …`, `## Fallstudie 3: …`. Nummer & Label frei wählbar, werden geparst.
3. **Info-/Zwischenabschnitt = `## Titel` ohne „Wort N:"** → schlichte Überschrift, kein Badge,
   kein Umbruch (z. B. „## Hinweise", „## When to Use Which Method?").
4. **Teilaufgabe = `#### Task N: Titel`** (bzw. `#### Aufgabe N: …`). Das Label im PDF folgt der
   `lang`-Einstellung (de → „Aufgabe", en → „Task"), unabhängig vom geschriebenen Wort.
5. Kontext/Angabe stehen **direkt unter der `##`** — kein Zwischen-`###` nötig (`###` ist Reserve).
6. **Lösungen** in einen nativen Quarto-Block:
   ```
   ::: {.content-visible when-meta="show_solutions"}
   **Solution:** …
   :::
   ```
   Sichtbarkeit über `show_solutions` (YAML oder `-M show_solutions:true`). KEINEN Filter/Div wie
   `.loesung`/`.aufgabe` verwenden — die gibt es nicht mehr.

## Punkte — standardmäßig WEGLASSEN

- **Default: keine Punkte.** In der Regel sollen Übungsblätter ohne Punktangaben entstehen.
- Nur wenn der Nutzer ausdrücklich Punkte/Klausurnähe will: Punkte am **Ende der `####`-Zeile** in
  eckigen Klammern, z. B. `#### Task 2: … [4 P]`. Das rendert als Pille; `[4]`, `[4 Punkte]`,
  `[4 pts]` gehen auch. Dann konsequent bei allen Teilaufgaben.

## YAML-Kopf

```yaml
title: "…"
subtitle: "…"
lang: de                 # de oder en — steuert Logo, Eyebrow (ÜBUNGSBLATT/WORKSHEET) & Datum
author:
  - name: …
    email: …
    role: …
    affiliation: THWS Business & Engineering
course: "…"              # Masthead MODUL + Kopfzeile links
semester: "…"            # Kopfzeile rechts
sheet: "…"               # Eyebrow „… · Nr. xx"
date: last-modified
show_solutions: false
format: tutorial-typst
```

Meta-Streifen zeigt bewusst nur **MODUL · DOZENT · AUSGABE** (kein Zeit/Punkte — sonst bricht der
Name um). Logo-Pfade NICHT angeben — die Extension löst sie selbst auf.

## Didaktik / Inhalt

- Aufgaben nach steigender Schwierigkeit; klare, eindeutige Angaben.
- Lösungen mit nachvollziehbaren Schritten; bei Bedarf „Grading Notes" als Korrekturhilfe.
- Mathe (`$…$` / `$$…$$`), Tabellen, Code-Blöcke und Hinweis-Zitate (`>`) sind erlaubt und
  rendern korrekt.
- Sprache (de/en) konsistent zum `lang`-Feld.

## Interaktion

Wenn nötig, kurz erfragen: Thema/Fach, Sprache, Anzahl & Schwierigkeit der Aufgaben, ob Punkte
gewünscht (Default nein), Bearbeitungszeit. Dann die `.qmd` schreiben und auf das Rendern beider
Varianten hinweisen:
```
quarto render <blatt>.qmd --to tutorial-typst                       # Angabe
quarto render <blatt>.qmd --to tutorial-typst -M show_solutions:true # mit Lösungen
```
