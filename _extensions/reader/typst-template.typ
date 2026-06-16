// ===========================================================
// THWS Reader — Typst-Template (Redesign · editorial)
// -----------------------------------------------------------
// Palette : CI-Orange #EC6500 (Lead) · Teal #005564 (Akzent)
// Schrift : Helvetica / Arial (max. Kompatibilität)
// Autor   : Christian Kraus — Redesign abgeleitet aus HTML-Mockup
// ===========================================================
#import "@preview/cades:0.3.1": qr-code

// ---------------------------------------------------------------------------
// 1. THWS-PALETTE
// ---------------------------------------------------------------------------
#let thws-orange      = rgb("#EC6500")
#let thws-orange-600  = rgb("#D25400")
#let thws-orange-tint = rgb("#FFF4EB")
#let thws-teal        = rgb("#005564")
#let thws-teal-600    = rgb("#00424F")
#let thws-teal-tint   = rgb("#EAF1F2")
#let thws-ink         = rgb("#1F1D1A")
#let thws-ink-soft    = rgb("#3A3733")
#let thws-muted       = rgb("#6B655D")
#let thws-faint       = rgb("#9A938A")
#let thws-line        = rgb("#E4E0DA")

#let body-font = ("Helvetica Neue", "Helvetica", "Arial", "Liberation Sans")

// ---------------------------------------------------------------------------
// 2. LOGO-RECOLOR
// Färbt die einfarbige THWS-Wortmarke (Klasse .st0) in jede CI-Farbe ein,
// indem ein <style>-Block in das SVG injiziert wird.
// Bei NICHT-THWS-/Mehrfarb-Logos passiert nichts -> Datei wird unverändert
// gezeigt (sicherer Fallback).  Für PNG/JPG ebenfalls 1:1-Anzeige.
// ---------------------------------------------------------------------------
#let thws-logo(path, hex: "#EC6500", width: auto, height: auto) = {
  if path == none { return }
  let ext = lower(path.split(".").last())
  if ext == "svg" {
    let data = read(path)
    // 1) Vorhandene Füllfarben überschreiben — als CSS (.st0{fill:#…}) ODER als
    //    Inline-Attribut (fill="#…"). \\s/\\" sind Typst-String-Escapes fürs Regex.
    data = data.replace(regex("fill\\s*:\\s*#[0-9A-Fa-f]{3,8}"), "fill:" + hex)
    data = data.replace(regex("fill\\s*=\\s*\"#[0-9A-Fa-f]{3,8}\""), "fill=\"" + hex + "\"")
    // 2) Regel zusätzlich vor </svg> nachreichen (greift in der Kaskade zuletzt).
    let css = "<style>.st0,.st1,path{fill:" + hex + "}</style>"
    data = data.replace("</svg>", css + "</svg>")
    image(bytes(data), format: "svg", width: width, height: height)
  } else {
    image(path, width: width, height: height)
  }
}

// ---------------------------------------------------------------------------
// 3. EYEBROW / KLEINE LABEL-ZEILE
// ---------------------------------------------------------------------------
#let eyebrow(label, col) = text(
  size: 8pt, weight: "bold", tracking: 0.16em, fill: col,
)[#upper(label)]

// ---------------------------------------------------------------------------
// 4. FLASHCARD — farbcodierte Box je Kontext (kind)
//    Wird vom filter.lua aufgerufen:  #flashcard(kind:"…", label:"…", title:[…])[ … ]
// ---------------------------------------------------------------------------
#let flashcard(kind: "hinweis", label: none, title: none, body) = {
  let cfg = (
    hinweis:    (accent: thws-teal,   bg: thws-teal-tint,   lbl: "Hinweis",            head: false),
    deepdive:   (accent: thws-teal,   bg: white,            lbl: "Deep Dive",          head: true),
    definition: (accent: thws-orange, bg: white,            lbl: "Definition",         head: false),
    case:       (accent: thws-orange, bg: white,            lbl: "Fallstudie",         head: false),
    drag:       (accent: thws-orange, bg: thws-orange-tint, lbl: "Übung · Begriffe",   head: false),
    quiz:       (accent: thws-orange, bg: white,            lbl: "Quick-Check",        head: false),
    video:      (accent: thws-teal,   bg: thws-teal-tint,   lbl: "Video-Empfehlung",   head: false),
  )
  let c = cfg.at(kind, default: cfg.hinweis)
  let acc = c.accent
  let lbl = if label != none { label } else { c.lbl }

  // -- Inhalt je nach kind leicht angepasst --
  let inner = {
    set text(size: 10pt, fill: thws-ink-soft)
    set par(leading: 0.6em, spacing: 0.7em, justify: false)
    if kind == "quiz" {
      set list(marker: none, indent: 0pt, body-indent: 8pt)
      body
    } else if kind == "drag" {
      // Lückentext: eingesetzte Begriffe (Strong) als orange unterstrichene Wörter
      show strong: it => box(underline(
        text(fill: thws-ink, weight: "bold", it.body),
        stroke: 2pt + thws-orange, offset: 2.5pt,
      ))
      body
    } else {
      body
    }
  }

  // Kurze Boxen (Definition, Quick-Check, Übung, Video, Hinweis) nicht über
  // Seiten umbrechen — sie sollen als Einheit zusammenbleiben. Nur die langen
  // Typen (Fallstudie, Deep Dive) dürfen umbrechen, sonst könnten sie eine
  // Seite überlaufen.
  let box-breakable = kind == "case" or kind == "deepdive"

  v(0.7em)
  block(
    width: 100%,
    radius: 5pt,
    clip: true,
    breakable: box-breakable,
    stroke: 0.5pt + thws-line,
    fill: c.bg,
  )[
    #if c.head [
      // Deep Dive: gefüllte Teal-Kopfleiste (Exkurs)
      #block(width: 100%, fill: acc, inset: (x: 14pt, y: 9pt))[
        #grid(columns: (auto, 1fr), column-gutter: 9pt, align: horizon,
          box(width: 7pt, height: 7pt, fill: thws-orange, radius: 1pt),
          {
            eyebrow(lbl, white)
            if title != none [ #h(6pt) #text(fill: white, weight: "bold", size: 10.5pt)[#title] ]
          },
        )
      ]
      #block(width: 100%, inset: (x: 16pt, y: 12pt))[#inner]
    ] else [
      // Standardbox mit farbiger linken Kante
      #block(
        width: 100%,
        inset: (left: 16pt, rest: 14pt),
        stroke: (left: 3pt + acc),
      )[
        #eyebrow(lbl, if kind == "drag" or kind == "quiz" { thws-orange-600 } else { acc })
        #if title != none [
          #v(3pt)
          #text(fill: thws-ink, weight: "bold", size: 11.5pt)[#title]
        ]
        #v(5pt)
        #inner
      ]
    ]
  ]
  v(0.5em)
}

// Trennlinie Problem / Lösung in der Fallstudie (vom filter.lua gesetzt)
#let solution-divider() = {
  v(0.5em)
  line(length: 100%, stroke: (paint: thws-line, thickness: 0.5pt, dash: "dashed"))
  v(0.4em)
}

// ---------------------------------------------------------------------------
// 5. INLINE-ASIDES  (Option B — im Textfluss, keine Randspalte)
//    #merksatz[ … ]              und   #begriff(title:"…")[ … ]
// ---------------------------------------------------------------------------
#let merksatz(body) = {
  v(0.6em)
  block(
    width: 100%, fill: thws-orange-tint, radius: 3pt,
    inset: (left: 14pt, rest: 11pt), stroke: (left: 3pt + thws-orange),
  )[
    #eyebrow("Merksatz", thws-orange-600)
    #v(4pt)
    #set text(size: 9.5pt, fill: thws-ink-soft)
    #set par(leading: 0.58em, spacing: 0.6em, justify: false)
    #body
  ]
  v(0.6em)
}

#let begriff(title: none, body) = {
  v(0.6em)
  block(
    width: 100%, fill: thws-teal-tint, radius: 3pt,
    inset: (left: 14pt, rest: 11pt), stroke: (left: 3pt + thws-teal),
  )[
    #eyebrow("Begriff", thws-teal)
    #if title != none [ #v(3pt) #text(weight: "bold", fill: thws-ink, size: 10.5pt)[#title] ]
    #v(4pt)
    #set text(size: 9.5pt, fill: thws-ink-soft)
    #set par(leading: 0.58em, spacing: 0.6em, justify: false)
    #body
  ]
  v(0.6em)
}

// ===========================================================================
// 6. HAUPT-TEMPLATE
// ===========================================================================
#let project(
  title: [Titel],
  subtitle: none,
  abstract: none,
  authors: (),
  course: none,
  semester: none,
  faculty: [Fakultät Wirtschaftsingenieurwesen],
  university: [Technische Hochschule Würzburg-Schweinfurt],
  date: none,
  version: none,
  lang: "de",
  logo: none,
  logo_en: none,
  bib_file: none,
  citation_style: none,
  show_outline: true,
  outline_depth: 2,
  web_url: none,
  github_url: none,
  body,
) = {
  let author_list = if type(authors) == array { authors } else if type(authors) == dictionary { (authors,) } else { () }
  set document(title: title, author: author_list.map(a => a.name))

  // Sprachweiche fürs Logo: bei englischer Dokumentsprache das EN-Logo
  // verwenden, sofern hinterlegt — sonst Fallback auf das (deutsche) Standardlogo.
  let active-logo = if lang != none and lang.starts-with("en") and logo_en != none {
    logo_en
  } else {
    logo
  }

  // Datumsformat sprachabhängig: DE → 16.06.2026, EN → June 16, 2026.
  // Quarto liefert das Datum als ISO-String (z. B. last-modified → 2026-06-16),
  // unabhängig von lang — daher hier parsen und neu formatieren.
  // (Regex-Endanker als $$ geschrieben — typst-template.typ ist ein Pandoc-Template.)
  let lang-de = lang == none or lang.starts-with("de")
  let date-fmt = if lang-de { "[day].[month].[year]" } else { "[month repr:long] [day], [year]" }
  let parse-iso(d) = {
    if type(d) == str and d.match(regex("^\\d{4}-\\d{2}-\\d{2}$$")) != none {
      let p = d.split("-")
      datetime(year: int(p.at(0)), month: int(p.at(1)), day: int(p.at(2)))
    } else { none }
  }
  let date-disp = if date != none {
    let dt = parse-iso(date)
    if dt != none { dt.display(date-fmt) } else { date }
  } else { none }

  let course-disp = if course != none { course } else { title }

  // -------------------------------------------------------------------------
  // Globale Seite (Inhaltsseiten ab S. 2): Kopf links Logo (orange), rechts
  // Kurs · Semester; Fuß: Kapitel links, Seitenzahl rechts (orange).
  // -------------------------------------------------------------------------
  set page(
    paper: "a4",
    margin: (left: 28mm, right: 24mm, top: 32mm, bottom: 24mm),
    header-ascent: 35%,
    footer-descent: 32%,
    header: context {
      if counter(page).get().first() > 1 {
        grid(
          columns: (auto, 1fr, auto),
          align: (left + horizon, center + horizon, right + horizon),
          thws-logo(active-logo, hex: "#EC6500", height: 11mm),
          [],
          text(size: 8pt, tracking: 0.12em, fill: thws-muted)[
            #upper(course-disp) #h(4pt) · #h(4pt) #text(fill: thws-orange, weight: "bold")[#upper(if semester != none { semester } else { [ ] })]
          ],
        )
        v(-1pt)
        line(length: 100%, stroke: 0.5pt + thws-line)
      }
    },
    footer: context {
      if counter(page).get().first() > 1 {
        let hs = query(heading.where(level: 1).before(here()))
        let foot-left = if hs.len() > 0 { hs.last().body } else { title }
        line(length: 100%, stroke: 0.5pt + thws-line)
        v(3pt)
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(size: 7.5pt, tracking: 0.08em, fill: thws-faint)[#foot-left],
          text(size: 9pt, weight: "bold", fill: thws-orange)[#counter(page).display()],
        )
      }
    },
  )

  // -------------------------------------------------------------------------
  // TYPOGRAFIE
  // -------------------------------------------------------------------------
  set text(font: body-font, size: 10.5pt, lang: lang, fill: thws-ink-soft)
  set par(leading: 0.7em, spacing: 1.05em, justify: true, first-line-indent: 0pt)

  show cite: set text(fill: thws-orange)
  // Bibliography: Quarto (>= 1.8) erzeugt den #bibliography(...)-Call selbst.
  // Wir rufen ihn NICHT mehr im Template auf, sondern fangen Quartos Call ab
  // und stylen ihn (Überschrift + Schrift + Abstände). Eigener Titel statt Default.
  set bibliography(title: none)
  show bibliography: it => {
    pagebreak()
    set par(spacing: 8pt, leading: 0.62em)
    set text(size: 9.5pt)
    heading(level: 1, numbering: none)[#if lang == "de" { "Literatur" } else { "Literature" }]
    it
  }
  set footnote(numbering: n => text(fill: thws-orange, numbering("1", n)))
  set list(indent: 1em, marker: (text(fill: thws-orange)[•], text(fill: thws-orange)[‣], text(fill: thws-orange)[–]))
  set enum(indent: 1em, numbering: (..nums) => text(fill: thws-orange, numbering("1.", ..nums)))

  // --- Überschriften ---
  set heading(numbering: "1.1")
  show heading: set block(sticky: true)

  // H1 als Kapitel-Opener bzw. schlichter Titel (Inhalt / Literatur)
  show heading.where(level: 1): it => {
    if it.numbering == none {
      block(above: 1.4em, below: 1em)[
        #text(size: 28pt, weight: "bold", fill: thws-ink)[#it.body]
        #v(0.35em)
        #box(width: 52pt, height: 3pt, fill: thws-orange)
      ]
    } else {
      let n = counter(heading).at(it.location()).first()
      // stack(spacing: 0pt) statt Paragraph-Fluss: jeder Abstand wird exakt per
      // v() gesetzt; die 56pt-Ziffer wird per top/bottom-edge auf die Cap-Höhe
      // beschnitten, damit „KAPITEL" dicht darunter sitzt (kein Zeilenbox-Leerraum).
      block(above: 2.4em, below: 1.5em, breakable: false, stack(
        spacing: 0pt,
        text(size: 56pt, weight: "bold", fill: thws-orange, top-edge: "cap-height", bottom-edge: "baseline")[#numbering("01", n)],
        v(7pt),
        eyebrow("Kapitel", thws-teal),
        v(10pt),
        text(size: 23pt, weight: "bold", fill: thws-ink)[#it.body],
        v(9pt),
        box(width: 52pt, height: 3pt, fill: thws-orange),
      ))
    }
  }

  // H2 — teal, mit orange-getönter Nummer
  show heading.where(level: 2): it => block(above: 1.8em, below: 0.7em)[
    #text(size: 15pt, weight: "bold", fill: thws-teal)[
      #if it.numbering != none [
        #text(fill: thws-orange)[#counter(heading).display(it.numbering)] #h(6pt)
      ]
      #it.body
    ]
  ]

  // H3 — Tinte
  show heading.where(level: 3): it => block(above: 1.4em, below: 0.5em)[
    #text(size: 12.5pt, weight: "bold", fill: thws-ink)[
      #if it.numbering != none [ #text(fill: thws-orange)[#counter(heading).display(it.numbering)] #h(5pt) ]
      #it.body
    ]
  ]

  // --- Quote / Tabelle / Mathe ---
  // Blockzitat: EIGENES Rendering — genau ein Block mit einer linken Kante.
  // (Das frühere `set block(stroke: left)` legte den Strich auf mehrere
  //  verschachtelte Blöcke und erzeugte so eine doppelte/versetzte Linie.)
  set quote(block: true)
  show quote.where(block: true): it => block(
    width: 100%,
    above: 1.2em, below: 1.2em,
    inset: (left: 14pt),
    stroke: (left: 2.5pt + thws-orange),
    text(style: "italic", fill: thws-ink-soft, it.body),
  )

  show math.equation.where(block: true): set block(above: 1.2em, below: 1.2em)

  set table(
    inset: (x: 8pt, y: 6pt),
    align: left,
    stroke: (x, y) => if y == 0 { none } else { (bottom: 0.5pt + thws-line) },
    fill: (x, y) => if y == 0 { thws-teal } else if calc.odd(y) { white } else { rgb("#F7F5F2") },
  )
  show table.cell.where(y: 0): set text(fill: white, weight: "bold", size: 9.5pt)
  show table.cell: set text(size: 9.5pt)

  // =========================================================================
  // DECKBLATT (eigene Seite — Teal vollflächig, Option-3-Look)
  // =========================================================================
  page(
    fill: thws-teal,
    margin: 0pt,
    header: none,
    footer: none,
  )[
    // Deckblatt-Text nie im Blocksatz — sonst streckt der globale justify:true
    // den Titel über die Zeile (große Wortlücken bei "Property, Plant &").
    #set par(justify: false)

    // oranger Eck-Akzent oben rechts
    #place(top + right, polygon((0mm, 0mm), (34mm, 0mm), (34mm, 34mm), fill: thws-orange))

    // Kopf: Logo (weiß) + Fakultät
    #pad(top: 16mm, left: 16mm, right: 16mm)[
      #grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
        thws-logo(active-logo, hex: "#FFFFFF", height: 13mm),
        text(size: 8pt, tracking: 0.14em, fill: rgb(255, 255, 255, 200))[#upper(faculty)],
      )
    ]

    // Mitte: Eyebrow + Titel + Untertitel + Meta
    #place(horizon + left, dx: 16mm, dy: -6mm, block(width: 150mm)[
      #grid(columns: (auto, 1fr), column-gutter: 12pt, align: horizon,
        text(size: 9pt, weight: "bold", tracking: 0.3em, fill: thws-orange)[#upper(if lang == "de" { "Vorlesungsskript" } else { "Lecture Notes" })],
        line(length: 100%, stroke: 1.5pt + rgb(255, 255, 255, 46)),
      )
      #v(14pt)
      #text(size: 38pt, weight: "bold", fill: white, hyphenate: false)[#title]
      #if subtitle != none [
        #v(12pt)
        #text(size: 15pt, fill: thws-orange)[#subtitle]
      ]
      #v(26pt)
      #grid(columns: (auto, auto, auto), column-gutter: 34pt,
        ..(
          (if course != none { ("Modul", course) }),
          (if semester != none { ("Semester", semester) }),
          (if version != none { ("Version", version) }),
        ).filter(x => x != none).map(p => {
          stack(spacing: 6pt,
            text(size: 7.5pt, tracking: 0.18em, fill: rgb(255, 255, 255, 140))[#upper(p.at(0))],
            text(size: 12pt, weight: "bold", fill: white)[#p.at(1)],
          )
        })
      )
    ])

    // Fuß: dunklere Teal-Leiste mit Autoren + QR
    #place(bottom, block(width: 100%, fill: thws-teal-600, inset: (x: 16mm, top: 9mm, bottom: 10mm))[
      #grid(columns: (1fr, auto), column-gutter: 24pt, align: (left + bottom, right + bottom),
        {
          for a in author_list {
            text(size: 12pt, weight: "bold", fill: white)[#a.name]
            linebreak()
            if "role" in a { text(size: 9pt, fill: rgb(255, 255, 255, 180))[#a.role]; linebreak() }
            if "email" in a { text(size: 9pt, fill: thws-orange)[#a.email]; linebreak() }
            v(6pt, weak: true)
          }
          v(6pt)
          text(size: 8pt, fill: rgb(255, 255, 255, 150))[#university]
          if date-disp != none { linebreak(); text(size: 8pt, fill: rgb(255, 255, 255, 130))[Stand: #date-disp] }
        },
        {
          let qr_target = if web_url != none { web_url } else { github_url }
          if qr_target != none {
            align(center, stack(spacing: 6pt,
              box(fill: white, inset: 5pt, radius: 4pt)[#qr-code(qr_target, width: 24mm)],
              text(size: 7pt, fill: rgb(255, 255, 255, 190))[Interaktive Übungen \ & Online-Version],
            ))
          }
        },
      )
    ])
  ]

  // Optionales Abstract auf eigener Position
  if abstract != none {
    v(1cm)
    align(center, block(width: 80%)[#text(style: "italic")[#abstract]])
  }

  // =========================================================================
  // INHALTSVERZEICHNIS
  // =========================================================================
  if show_outline {
    let outline_title = if lang == "de" { "Inhalt" } else { "Contents" }
    heading(level: 1, numbering: none, outlined: false)[#outline_title]
    // H1-Eintrag: Nummer orange, Titel/Seite Tinte-fett.
    show outline.entry.where(level: 1): it => {
      v(10pt, weak: true)
      set text(weight: "bold", fill: thws-ink, size: 12pt)
      it.indented(
        text(fill: thws-orange, it.prefix()),
        it.inner(),
      )
    }
    set outline(indent: 1.4em)
    outline(title: none, depth: outline_depth)
    pagebreak()
  }

  // =========================================================================
  // INHALT
  // =========================================================================
  body

  // Literatur: wird von Quartos #bibliography(...)-Call erzeugt und vom
  // `show bibliography`-Hook oben gestylt (eigene Überschrift, Schrift, Abstände).
}
