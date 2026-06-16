# Logo — Verdrahtung & Stolperfallen

Wie das THWS-Logo in diesem Reader-Format eingebunden ist, und welche Fallen dahinterstecken.
Erstellt 16.06.2026, aktualisiert 16.06.2026 (horizontale Logos, Sprachweiche, Auto-Resolve).

## Stand heute — so ist das Logo verdrahtet

**In den meisten Fällen muss der Autor gar nichts angeben.** `lang` steuert alles.

```
lang: de            →  thws-logo.svg     (DE, horizontal)
lang: en            →  thws-logo_en.svg  (EN, horizontal)
```

Die Kette von der Datei bis ins PDF:

1. **Dateien.** `thws-logo.svg` (DE) und `thws-logo_en.svg` (EN) liegen **im Extension-Ordner**
   und reisen bei `quarto add owner/repo` automatisch mit (der ganze Ordner wird kopiert — ein
   `resources:`-Eintrag ist dafür *nicht* nötig). Beide sind die **horizontalen** Varianten
   (viewBox 542,7×130 bzw. 701,4×130, **gleiche Höhe 130**).

2. **Auto-Resolve** (`filter.lua` → `Meta`). Setzt der Autor keinen Key, ermittelt der Filter die
   Pfade selbst:
   ```lua
   local doc_dir = pandoc.path.directory(quarto.doc.input_file or ".")
   m['reader-logo']    = pandoc.MetaString(pandoc.path.make_relative(
                           quarto.utils.resolvePath("thws-logo.svg"), doc_dir))
   m['reader-logo-en'] = pandoc.MetaString(pandoc.path.make_relative(
                           quarto.utils.resolvePath("thws-logo_en.svg"), doc_dir))
   ```
   `resolvePath()` findet die mitgelieferte Datei relativ zur **Extension** (egal ob lokal unter
   `_extensions/reader/` oder nach Install unter `_extensions/owner/reader/`). Da Typst `read()`
   relativ zur `.typ` (= Dokumentordner) auflöst, wird der **absolute** Pfad mit
   `make_relative` auf den Dokumentordner zurückgerechnet. Beides nur, wenn der Key nicht
   schon gesetzt ist → **manueller Key gewinnt** (eigenes Logo möglich).

3. **Durchreichen** (`typst-show.typ`).
   ```typ
   $if(reader-logo)$ logo: "$reader-logo$".replace("\\", ""), $endif$
   $if(reader-logo-en)$ logo_en: "$reader-logo-en$".replace("\\", ""), $endif$
   ```
   `.replace("\\", "")` entfernt den Backslash, den Pandoc vor `_` setzt (siehe Ursache 2 unten).

4. **Sprachweiche** (`typst-template.typ` → `project`).
   ```typ
   let active-logo = if lang != none and lang.starts-with("en") and logo_en != none {
     logo_en
   } else { logo }
   ```

5. **Recolor** (`thws-logo`-Funktion). Färbt die Wortmarke um — **weiß** aufs Deckblatt, **orange**
   in die Kopfzeile. Robust auch bei SVGs mit eigenem `<style>.st0{fill:#…}` (so die THWS-Logos):
   vorhandene `fill`-Werte werden per Regex direkt umgeschrieben (als CSS *und* Inline-Attribut),
   zusätzlich wird `.st0,.st1,path{fill:…}` vor `</svg>` nachgereicht.

6. **Größe.** Über **`height:`** normiert (nicht `width:`), weil beide Logos viewBox-Höhe 130
   haben → die „thws"-Marke ist in DE und EN exakt gleich groß, nur der EN-Subtitle läuft weiter
   nach rechts. Kopf 11 mm, Cover 13 mm, beide Grids vertikal zentriert (`horizon`).

## Postmortem: die zwei ursprünglichen Bugs (warum eigener Key + `.replace`)

### Ursache 1 — `logo` ist ein reservierter Quarto-Key

Quarto hat ein eigenes **Brand-/Logo-System**. Setzt man `logo:` (top-level oder unter dem
Format), greift Quarto den Wert ab, legt das Logo als **Seiten-Hintergrund** an und reicht dem
Template nur den **Wahrheitswert** `logo: "true"` durch → `read("true")` schlägt fehl
(`error: file not found (searched at …/true)`).

**Lösung:** eigene, nicht reservierte Keys **`reader-logo`** / **`reader-logo-en`** verwenden.

### Ursache 2 — Pandoc escaped den Unterstrich

Der Pfad kam als `"\_extensions/…/thws-logo.svg"` an — Pandoc setzt vor `_` in interpolierten
Strings einen **Backslash**. Typst sucht dann `\_extensions` und findet nichts. Auch der
**Auto-Resolve-Pfad** geht durch diese Interpolation, daher gilt `.replace("\\", "")` weiterhin.

## Pfad-Auflösung (das Detail hinter `make_relative`)

Typst löst `read(...)` **relativ zur kompilierten `.typ`** (Dokumentordner) auf. `resolvePath()`
liefert aber einen **absoluten** Pfad — den interpretiert Typst relativ zur Projekt-Wurzel und
**verdoppelt** ihn (`…/projekt/Users/…/thws-logo.svg` → not found). Deshalb wird er mit
`pandoc.path.make_relative(absolut, doc_dir)` auf den Dokumentordner zurückgerechnet.

## Diagnose-Tipp

Bei „kommt der Pfad überhaupt richtig an?"-Fragen das Typst-Zwischenformat behalten und prüfen:

```bash
quarto render … --to reader-typst -M keep-typ:true
grep -nE "^ *logo:|^ *logo_en:" <datei>.typ   # zeigt, was beim project()-Aufruf ankommt
```

## Merksätze

- `logo` gehört Quarto → eigene Keys `reader-logo` / `reader-logo-en`.
- Interpolierte Pfade immer mit `.replace("\\", "")` von Pandoc-Escapes befreien.
- Gebündelte Dateien per `quarto.utils.resolvePath()` finden, dann mit `make_relative` Typst-tauglich machen.
- Horizontale Logos über die **Höhe** skalieren → marken­gleich in DE/EN.
