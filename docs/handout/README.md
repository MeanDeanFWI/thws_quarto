# THWS Handout — Redesign (Typst)

Kompaktes `handout`-Format (Schwester von `reader`): **kein Deckblatt**, stattdessen ein
kompakter **Masthead** oben auf Seite 1 (Eyebrow · Titel · Meta-Streifen · Inhaltsübersicht),
Kopf-/Fußzeile auf jeder Seite. CI-Orange `#EC6500` (Lead), Teal `#005564` (Akzent).

## Dateien

```
_extensions/handout/
├── _extension.yml
├── typst-template.typ
├── typst-show.typ
├── filter.lua
├── thws-logo.svg        (deutsche Wortmarke, horizontal)
└── thws-logo_en.svg     (englische Wortmarke, horizontal)
```

`lang` steuert Logo **und** Box-Labels (`de` → deutsches Logo + „Fallstudie/Quick-Check…",
`en` → englisches Logo + „Case Study/Quick Check…"). Logo-Pfade müssen **nicht** angegeben
werden — der Filter löst die mitgelieferten SVGs automatisch auf. Eigenes Logo optional über
`handout-logo:` / `handout-logo-en:`.

## Änderungsprotokoll — angeglichen an `reader` (2026-06-16)

Die Handout-Extension war auf dem Stand des readers **vor** dessen Überarbeitung. Dieselben
Fixes wurden portiert und mit `03_PPE.qmd` (`--to handout-typst`, EN & DE) gegengetestet:

| Bereich | Problem | Fix |
|---|---|---|
| `filter.lua` (`Meta`) | Box-Labels immer deutsch (auch `lang: en`); Logo nur über hartcodierten Pfad. | `DOC_LANG` aus `m.lang` + Zwei-Pass-`return` (Meta vor Div); Logo-Pfade via `quarto.utils.resolvePath()` + `make_relative` selbst gesetzt (Keys `handout-logo` / `handout-logo-en`, install-/namespace-unabhängig, manueller Key gewinnt). |
| `typst-show.typ` | Reservierter `logo`-Key → kam nur als `"true"` an. | Eigene Keys `handout-logo` / `handout-logo-en` mit `.replace("\\","")`. |
| `typst-template.typ` (`thws-logo`) | Recolor versagte bei SVGs mit eigenem `<style>.st0{fill:…}`. | `fill`-Werte per Regex umschreiben (CSS + Inline) + Regel vor `</svg>`; `height:`-Parameter ergänzt. |
| `typst-template.typ` (Sprachweiche) | Kein EN-Logo. | Param `logo_en` + `active-logo` per `lang.starts-with("en")`. |
| Logos | Vertikale Wortmarke (zu hoch/klein im Kopf, DE/EN ungleich). | **Horizontale** Varianten (viewBox …×130, gleiche Höhe) → über `height` normiert, „thws"-Marke in DE/EN gleich groß. Kopf 11 mm, vertikal zentriert. |
| `typst-template.typ` (Blockzitat) | Doppelte/versetzte linke Linie. | Eigenes `show quote.where(block: true)` → ein Block, eine Kante. |
| `typst-template.typ` (`flashcard`) | Kurze Boxen brachen über Seiten. | `breakable: (kind == "case" or kind == "deepdive")` — nur lange Boxen brechen. |
| `typst-template.typ` (Masthead) | Titel konnte im Blocksatz strecken. | `set par(justify: false)` für den Masthead, vor dem Body wieder `true`. |

### Handout-spezifische Feinarbeit (2026-06-16)

| Bereich | Änderung |
|---|---|
| Inhaltsübersicht | H1-Nummer **orange** (Titel/Seite Tinte-fett) via eigenem `show outline.entry.where(level: 1)` mit `it.indented(text(fill: orange, it.prefix()), it.inner())` (Typst-0.14-API: `prefix()`/`inner()` sind Methoden). |
| Meta-Streifen | Werte-Schrift 11,5→10 pt, Label 7,5→7 pt; Spalten von `1fr` auf **`auto`** → der Dozentenname bricht nicht mehr um. |
| Datum | Sprachabhängig: DE `16.06.2026`, EN `June 16, 2026`. Quarto liefert ISO unabhängig von `lang`; Datum wird als String durchgereicht (`typst-show.typ`) und im Template per `datetime`+`display` neu formatiert. **Falle:** `typst-template.typ` ist ein Pandoc-Template — das `$` im Regex-Endanker muss als `$$` geschrieben werden. |

Logo-Verdrahtung identisch zum `reader` (nur Key-Präfix `handout-` statt `reader-`).
