# THWS Reader — Redesign (Typst)

Neugestaltetes `reader`-Format für `c-kraus/thws_quarto`. Editorial-Skript auf Basis des
THWS Design Sets: **CI-Orange `#EC6500`** als Leitfarbe, **Teal `#005564`** als Akzent,
Helvetica/Arial für maximale Kompatibilität.

Grundlage war ein optischer Mockup (4 A4-Seiten); dieser Ordner enthält die daraus abgeleiteten
Typst-Dateien.

## Änderungsprotokoll — Test-Iteration 2026-06-16 (für Claude Design)

Erster echter `quarto render … --to reader-typst` an einem realen Kapitel
(`03_PPE.qmd`, IAS 16/36, `lang: en`, 18 Seiten). Ergebnis: **kompiliert sauber** — die
README-Warnung „nie in Typst kompiliert" ist damit erledigt. Einzige verbleibende
Render-Meldung ist `unknown font family: liberation sans` (nur der *letzte* Fallback der
Schriftliste; Helvetica/Arial greifen auf macOS/Windows — harmlos).

Beim Test gefunden und in dieser Iteration **behoben**:

| # | Datei | Problem | Fix |
|---|---|---|---|
| 1 | `filter.lua` | Box-Labels erschienen **immer deutsch**, auch bei `lang: en` („Fallstudie" statt „Case Study"). `quarto.doc.lang()` lieferte hier nicht die Dokumentsprache. | Sprache in `Meta()` aus `m.lang` erfasst (`DOC_LANG`). Da Pandoc `Meta` **nach** den Blöcken aufruft, erzwingt ein **Zwei-Pass-`return`** am Dateiende (`{Meta}` zuerst, dann `{Header, Div}`), dass die Sprache beim Boxen-Rendern bekannt ist. |
| 2 | `typst-show.typ`, `typst-template.typ`, **neu** `thws-logo_en.svg` | Keine Sprachweiche fürs Logo — nur eine (deutsche) Wortmarke. | Neuer Key **`reader-logo-en`** → Param `logo_en`. Template wählt `active-logo` per `lang.starts-with("en")`. Fehlt der Key, wird in beiden Sprachen `reader-logo` genutzt (abwärtskompatibel). |
| 3 | `typst-template.typ` (`thws-logo`) | Recolor versagte beim EN-Logo: dessen internes `<style>.st0{fill:#FF6A00}` überschrieb die injizierte Regel (Kaskaden-Reihenfolge). | Recolor schreibt vorhandene `fill`-Werte **direkt** um — per Regex als CSS *und* Inline-Attribut — und reicht die `.st0`-Regel zusätzlich **vor `</svg>`** nach. Order-unabhängig, funktioniert für DE- (nur `class`, kein `<style>`) und EN-Logo (`<style>`). |
| 4 | `typst-template.typ` (Deckblatt) | Cover-Titel im **Blocksatz gestreckt** (große Wortlücken bei „Property, Plant &"). Der globale `set par(justify: true)` (für den Fließtext) griff in den Cover-Block durch. | `#set par(justify: false)` am Anfang des Deckblatt-`page()`-Blocks. |
| 5 | `filter.lua` (`Meta`) | Logo-Pfade mussten im Dokument hartcodiert werden (`_extensions/<namespace>/reader/…`) — der Namespace ändert sich aber je nach Install (lokal vs. `quarto add owner/repo`), und die Logos „reisten" nur über den expliziten Pfad. | Der Filter setzt `reader-logo`/`reader-logo-en` selbst via **`quarto.utils.resolvePath()`** (relativ zur Extension, dann `pandoc.path.make_relative` auf den Dokumentordner). **Kein Key mehr nötig**, install-/namespace-unabhängig; ein im Dokument gesetzter Key gewinnt weiterhin. Die SVGs werden bei `quarto add` automatisch mitkopiert (gesamter Extension-Ordner). |
| 6 | `typst-template.typ` (Kopfzeile) | Logo + Kurszeile waren `horizon`-zentriert in der (logohohen) Kopf-Zeile und schwebten dadurch weit über der Trennlinie. | Grid-Ausrichtung auf `bottom` → beide sitzen dicht über der Linie (`v(3pt)`→`v(5pt)`). |
| 7 | `typst-template.typ` (Kapitel-Opener) | Riesiger Abstand (~23 mm) zwischen Kapitelziffer „01" und „KAPITEL" — die 56pt-Zeilenbox reservierte Unterlängen-Leerraum, den `v(-2pt)` nicht ausglich. | Opener als `stack(spacing: 0pt)` mit explizitem `v()` je Abstand; Ziffer per `top-edge: "cap-height"` / `bottom-edge: "baseline"` auf die Cap-Höhe beschnitten. Abstand jetzt ~2,7 mm — „01/KAPITEL/Titel/Strich" als kompakte Gruppe. |
| 8 | `thws-logo.svg` + `thws-logo_en.svg` (ersetzt), `typst-template.typ` (`thws-logo`, Cover, Kopfzeile) | Die **vertikalen** Wortmarken (viewBox 358×175/200) waren in der Kopfzeile zu hoch (stießen, bes. EN mit 3 Sublines, an den oberen Seitenrand) und DE/EN unterschiedlich hoch. | Auf die **horizontalen** Varianten umgestellt (viewBox 542,7×130 DE / 701,4×130 EN, **gleiche Höhe**). `thws-logo` bekam einen `height:`-Parameter; Logos werden jetzt **über die Höhe** normiert → „thws"-Marke in DE und EN exakt gleich groß, nur der EN-Subtitle läuft weiter nach rechts. Kopf 11 mm, Cover 13 mm. Beide Grids auf `horizon` (vertikal zentriert) → gedachte Mittellinie läuft durch „thws" **und** den Nebentext (Kopf: Kurszeile, Cover: Fakultät). `header-ascent` zurück auf 35 % (das kurze Logo braucht keine Verschiebung mehr; ersetzt die `bottom`-Ausrichtung aus #6). Trennlinie näher an den Kopf-Inhalt gerückt (`v(5pt)`→`v(-1pt)`). |
| 9 | `typst-template.typ` (`flashcard`) | Kurze Boxen (Definition, Quick-Check, Übung …) brachen über Seitenumbrüche (z. B. Seite 3/4) und wirkten zerrissen. | `breakable: (kind == "case" or kind == "deepdive")` am Box-`block` — nur die langen Typen (Fallstudie, Deep Dive) dürfen umbrechen; alle anderen bleiben als Einheit zusammen und werden ggf. komplett auf die nächste Seite geschoben. |
| 10 | `typst-template.typ` (Blockzitat) | Zitate hatten eine **doppelte/versetzte** linke Linie. Ursache: `show quote: set block(stroke: (left: …))` legte den Strich auf mehrere verschachtelte Blöcke des Quote-Defaults. | Eigenes Rendering `show quote.where(block: true): it => block(…, stroke: (left: 2.5pt + thws-orange), inset: (left: 14pt))[text(it.body)]` — genau **ein** Block mit **einer** sauberen Kante. |
| 11 | `typst-show.typ`, `typst-template.typ` (Cover-Fußzeile „Stand") | Datum sprachunabhängig im ISO-Format (`2026-06-16`). | Sprachabhängig: DE `16.06.2026`, EN `June 16, 2026`. Datum als String durchgereicht und per `datetime`+`display` neu formatiert (`date-disp`). **Falle:** Pandoc-Template — `$` im Regex-Endanker als `$$`, und auch im Kommentar kein einzelnes `$` verwenden. |

Verifiziert in beide Richtungen: `lang: en` → EN-Logo + EN-Labels + „LECTURE NOTES";
`lang: de` (via `-M lang:de`) → DE-Logo + DE-Labels + „VORLESUNGSSKRIPT". Auto-Resolve ohne
Key getestet; Vorrang eines gesetzten Keys per Gegenprobe bestätigt.

**Install-Beweis (mitreisende Logos):** Extension als Tarball verpackt (ohne `resources:`-Key),
per `quarto add` in ein frisches Projekt installiert → beide SVGs landen unter
`_extensions/reader/`; anschließender `quarto render … --to reader-typst` zeigt das Logo ohne
jeden Key. `quarto add` kopiert den **gesamten** Extension-Ordner — ein `resources:`-Eintrag
ist dafür *nicht* nötig (der steuert nur, was beim Rendern neben den **Output** kopiert wird;
unsere Logos werden von Typst per `read()` direkt in die PDF eingebettet).

**Noch offen — bewusste Design-Entscheidungen, kein Fehler:**

- **`.widget`-iframes entfallen im PDF** (korrekt für Print), aber die Einleitungssätze
  („*Use the interactive calculator below…*") zeigen dann auf nichts. Idee: der Filter
  könnte einen Print-Platzhalter (QR/Link zur Online-Version) einsetzen. Im Testkapitel
  4× betroffen.
- **`.callout-warning` nutzt den Quarto-Default-Look** statt des THWS-Stils (im `filter.lua`
  nicht behandelt) — bricht optisch leicht aus dem Reader-Design aus.
- **`liberation sans`** als letzter Fallback der Schriftliste ist auf macOS/Windows nicht
  installiert → Render-Warnung. Optional aus `#let body-font` entfernen oder durch eine
  vorhandene Grotesk ersetzen.

## Installation

Die sechs Dateien in den Extension-Ordner deines Projekts kopieren und vorhandene überschreiben:

```
_extensions/reader/
├── _extension.yml
├── typst-template.typ
├── typst-show.typ
├── filter.lua
├── thws-logo.svg        (deutsche Wortmarke, horizontal)
└── thws-logo_en.svg     (englische Wortmarke, horizontal)
```

(In deinem Repo unter `_extensions/reader/`.)

**Logo:** Standardmäßig **nichts** angeben — der Filter löst die mitgelieferten Wortmarken
(`thws-logo.svg` / `thws-logo_en.svg`) automatisch relativ zur Extension auf, egal ob lokal
oder via `quarto add owner/repo` installiert. `lang` steuert die Auswahl: `lang: en` → englische
Wortmarke, sonst die deutsche.

Nur wenn du ein **eigenes** Logo verwenden willst, die Keys **`reader-logo:`** / **`reader-logo-en:`**
setzen — **nicht** `logo:` (das ist von Quarto reserviert). Ein
gesetzter Key hat Vorrang vor dem Auto-Resolve:

```yaml
lang: de   # 'en' → englisches Logo + englische Box-Labels
format:
  reader-typst:
    reader-logo:    "assets/mein-logo.svg"      # optional, überschreibt das THWS-Logo
    reader-logo-en: "assets/mein-logo_en.svg"   # optional
```

## Was neu ist

- **Deckblatt** — vollflächig Teal, weiße Wortmarke, oranger Eck-Akzent, großer Editorial-Titel,
  Modul/Semester/Version, Autorenblock + integrierter QR-Code.
- **Kopf-/Fußzeile** — Logo (orange) links, `KURS · SEMESTER` rechts; Fuß: aktuelles Kapitel
  links, Seitenzahl (orange) rechts.
- **Kapitel-Opener** — große Kapitelnummer „01", Kicker „KAPITEL", Titel, oranger Strich.
- **Inhaltsverzeichnis** — eigenständige Überschrift „Inhalt", fette Kapitel-Einträge.
- **Farbcodierte Boxen** statt einheitlicher Flashcard — je Kontext ein eigener Look (siehe unten).
- **Inline-Asides** `#merksatz` / `#begriff` (neu).
- **Quick-Check** mit echten Ankreuz-Symbolen (☑ / ☐), **Lückentext** mit orange unterstrichenen
  Begriffen, **Fallstudie** mit sauberer Problem-/Lösungs-Trennung.

## Autoren-Syntax (Markdown)

Die bekannten Elemente funktionieren weiter (`.flip-card`, `.details`, `.case-study`,
`.drag-exercise`, `.quick-check`, `.video`) — sie bekommen jetzt automatisch farbcodierte Looks.

**Neu — Merksatz (im Textfluss):**

```markdown
::: {.merksatz}
Aktiva = Mittelverwendung, Passiva = Mittelherkunft. Beide Seiten sind stets gleich.
:::
```

**Neu — Begriff (mit Titel):**

```markdown
::: {.begriff title="Stichtagsprinzip"}
Die Bilanz bezieht sich immer auf einen Zeitpunkt, nicht auf einen Zeitraum.
:::
```

> Hinweis: Bewusst als schlanke Boxen **im Textfluss** umgesetzt (nicht als echte Randspalte).
> Eine automatische Marginalien-Spalte ist in Typst nur mit Zusatzpaket (`marginalia`/`drafting`)
> robust — kann später nachgerüstet werden.

### Box-Typen → Look

| Klasse | `kind` | Farbe | Look |
|---|---|---|---|
| `.details` | `deepdive` | Teal | gefüllte Kopfleiste (Exkurs) |
| `.flip-card` | `definition` | Orange | Karte mit Titel |
| `.case-study` | `case` | Orange | Problem + getrennte Lösung |
| `.drag-exercise` | `drag` | Orange | Begriffe unterstrichen |
| `.quick-check` | `quiz` | Orange | Ankreuz-Liste + Feedback |
| `.video` | `video` | Teal | Play-Hinweis |
| (Standard) | `hinweis` | Teal | ruhige Info-Box |

## Logo

Die einfarbige THWS-Wortmarke (`.svg` mit Klasse `.st0`) wird automatisch eingefärbt —
**weiß** auf dem Deckblatt, **orange** in der Kopfzeile (Funktion `thws-logo` in
`typst-template.typ`). Die Recolor-Funktion überschreibt vorhandene `fill`-Werte direkt
(als CSS *und* als Inline-Attribut), funktioniert also auch, wenn das SVG — wie die
englische Wortmarke — eine eigene `<style>.st0{fill:…}`-Regel mitbringt. Ein PNG/JPG oder
ein mehrfarbiges Logo wird unverändert angezeigt.

**Sprachweiche:** `lang` steuert gleichzeitig Logo *und* Box-Beschriftungen. Bei `lang: en`
zeigt der Reader die englische Wortmarke und englische Labels (Case Study, Quick Check,
Exercise · Terms, Deep Dive, …); bei `lang: de` die deutschen Pendants. Fehlt
`reader-logo-en`, wird in beiden Sprachen das Standard-Logo (`reader-logo`) verwendet.

## Umgebung / Abhängigkeiten

Getestet mit **Quarto 1.9.37** und der von Quarto gebündelten Typst-Version (macOS, 2026-06-16).

1. **Typst-Version / Bild-API** — `thws-logo` nutzt `image(bytes(data), format: "svg")` (Typst ≥ 0.12).
   Falls dein Build über eine ältere Version läuft, in `typst-template.typ` durch
   `image.decode(data)` ersetzen.
2. **Schrift** — `Helvetica Neue`/`Helvetica`/`Arial` muss installiert sein (auf macOS/Windows i. d. R. vorhanden).
   `liberation sans` (letzter Fallback) erzeugt sonst eine harmlose Warnung — ggf. aus
   `#let body-font` entfernen.
3. **QR-Code** — benötigt das Paket `@preview/cades:0.3.1` (wird beim Render automatisch geladen).
