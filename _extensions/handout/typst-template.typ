// ===========================================================
// THWS Handout — Typst-Template (Redesign · kompakt)
// -----------------------------------------------------------
// Palette : CI-Orange #EC6500 (Lead) · Teal #005564 (Akzent)
// Schrift : Helvetica / Arial
// Aufbau  : kompakter Masthead (kein Deckblatt) · Inhaltsübersicht
//           · Kopf auf jeder Seite · leichtere Kapitelmarke
// ===========================================================
#import "@preview/cades:0.3.1": qr-code

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
#let thws-sunken      = rgb("#F7F5F2")

#let body-font = ("Helvetica Neue", "Helvetica", "Arial", "Liberation Sans")

// ---- Logo-Recolor (einfarbige THWS-Wortmarke) ----
#let thws-logo(path, hex: "#EC6500", width: auto, height: auto) = {
  if path == none { return }
  let ext = lower(path.split(".").last())
  if ext == "svg" {
    let data = read(path)
    // Vorhandene Füllfarben überschreiben — als CSS (.st0{fill:#…}) ODER Inline
    // (fill="#…"); funktioniert auch, wenn das SVG einen eigenen <style> mitbringt.
    data = data.replace(regex("fill\\s*:\\s*#[0-9A-Fa-f]{3,8}"), "fill:" + hex)
    data = data.replace(regex("fill\\s*=\\s*\"#[0-9A-Fa-f]{3,8}\""), "fill=\"" + hex + "\"")
    let css = "<style>.st0,.st1,path{fill:" + hex + "}</style>"
    data = data.replace("</svg>", css + "</svg>")
    image(bytes(data), format: "svg", width: width, height: height)
  } else {
    image(path, width: width, height: height)
  }
}

#let eyebrow(label, col) = text(size: 8pt, weight: "bold", tracking: 0.16em, fill: col)[#upper(label)]

// ---- FLASHCARD (farbcodierte Box je kind) ----
#let flashcard(kind: "hinweis", label: none, title: none, body) = {
  let cfg = (
    hinweis:    (accent: thws-teal,   bg: thws-teal-tint,   lbl: "Hinweis",          head: false),
    deepdive:   (accent: thws-teal,   bg: white,            lbl: "Deep Dive",        head: true),
    definition: (accent: thws-orange, bg: white,            lbl: "Definition",       head: false),
    case:       (accent: thws-orange, bg: white,            lbl: "Fallstudie",       head: false),
    drag:       (accent: thws-orange, bg: thws-orange-tint, lbl: "Übung · Begriffe", head: false),
    quiz:       (accent: thws-orange, bg: white,            lbl: "Quick-Check",      head: false),
    video:      (accent: thws-teal,   bg: thws-teal-tint,   lbl: "Video-Empfehlung", head: false),
  )
  let c = cfg.at(kind, default: cfg.hinweis)
  let acc = c.accent
  let lbl = if label != none { label } else { c.lbl }

  let inner = {
    set text(size: 10pt, fill: thws-ink-soft)
    set par(leading: 0.6em, spacing: 0.7em, justify: false)
    if kind == "quiz" {
      set list(marker: none, indent: 0pt, body-indent: 8pt)
      body
    } else if kind == "drag" {
      show strong: it => box(underline(
        text(fill: thws-ink, weight: "bold", it.body), stroke: 2pt + thws-orange, offset: 2.5pt,
      ))
      body
    } else { body }
  }

  // Kurze Boxen als Einheit zusammenhalten; nur lange (Fallstudie, Deep Dive)
  // dürfen über Seiten umbrechen.
  let box-breakable = kind == "case" or kind == "deepdive"

  v(0.7em)
  block(width: 100%, radius: 5pt, clip: true, breakable: box-breakable, stroke: 0.5pt + thws-line, fill: c.bg)[
    #if c.head [
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
      #block(width: 100%, inset: (left: 16pt, rest: 14pt), stroke: (left: 3pt + acc))[
        #eyebrow(lbl, if kind == "drag" or kind == "quiz" { thws-orange-600 } else { acc })
        #if title != none [ #v(3pt) #text(fill: thws-ink, weight: "bold", size: 11.5pt)[#title] ]
        #v(5pt)
        #inner
      ]
    ]
  ]
  v(0.5em)
}

#let solution-divider() = {
  v(0.5em)
  line(length: 100%, stroke: (paint: thws-line, thickness: 0.5pt, dash: "dashed"))
  v(0.4em)
}

// ---- Inline-Asides ----
#let merksatz(body) = {
  v(0.6em)
  block(width: 100%, fill: thws-orange-tint, radius: 3pt, inset: (left: 14pt, rest: 11pt), stroke: (left: 3pt + thws-orange))[
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
  block(width: 100%, fill: thws-teal-tint, radius: 3pt, inset: (left: 14pt, rest: 11pt), stroke: (left: 3pt + thws-teal))[
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
// HAUPT-TEMPLATE
// ===========================================================================
#let project(
  title: [Handout],
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
  let author_names = author_list.map(a => a.name)
  let author_string = author_names.join(", ")
  // Datumsformat sprachabhängig: DE → 16.06.2026, EN → June 16, 2026.
  // Quarto liefert das Datum als ISO-String (z. B. last-modified → 2026-06-16),
  // unabhängig von lang — daher hier parsen und neu formatieren.
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
  } else {
    datetime.today().display(date-fmt)
  }
  set document(title: title, author: author_names)

  // Sprachweiche fürs Logo: bei englischer Dokumentsprache das EN-Logo nutzen,
  // sofern hinterlegt — sonst Fallback aufs deutsche Standardlogo.
  let active-logo = if lang != none and lang.starts-with("en") and logo_en != none {
    logo_en
  } else {
    logo
  }

  let course-disp = if course != none { course } else { title }

  // -------------------------------------------------------------------------
  // SEITE — Kopf & Fuß auf jeder Seite
  // -------------------------------------------------------------------------
  set page(
    paper: "a4",
    margin: (left: 26mm, right: 24mm, top: 30mm, bottom: 24mm),
    header-ascent: 40%,
    footer-descent: 32%,
    header: context {
      grid(columns: (auto, 1fr, auto), align: (left + horizon, center + horizon, right + horizon),
        thws-logo(active-logo, hex: "#EC6500", height: 11mm),
        [],
        text(size: 8pt, tracking: 0.12em, fill: thws-muted)[
          #upper(course-disp) #h(4pt) · #h(4pt) #text(fill: thws-orange, weight: "bold")[#upper(if semester != none { semester } else { [ ] })]
        ],
      )
      v(-1pt)
      line(length: 100%, stroke: 0.5pt + thws-line)
    },
    footer: context {
      line(length: 100%, stroke: 0.5pt + thws-line)
      v(3pt)
      grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
        text(size: 7.5pt, tracking: 0.08em, fill: thws-faint)[#title],
        text(size: 9pt, weight: "bold", fill: thws-orange)[#counter(page).display()],
      )
    },
  )

  // -------------------------------------------------------------------------
  // TYPOGRAFIE
  // -------------------------------------------------------------------------
  set text(font: body-font, size: 10.5pt, lang: lang, fill: thws-ink-soft)
  set par(leading: 0.7em, spacing: 1.05em, justify: true, first-line-indent: 0pt)

  show cite: set text(fill: thws-orange)
  // Bibliography: Quarto (>= 1.8) erzeugt den #bibliography(...)-Call selbst.
  // Nicht mehr im Template aufrufen, sondern Quartos Call abfangen und stylen.
  set bibliography(title: none)
  show bibliography: it => {
    v(1.6em)
    set par(leading: 0.62em, spacing: 8pt)
    heading(level: 1, numbering: none)[#if lang == "de" { "Literatur" } else { "Literature" }]
    set text(size: 9pt)
    it
  }
  set footnote(numbering: n => text(fill: thws-orange, numbering("1", n)))
  set list(indent: 1em, marker: (text(fill: thws-orange)[•], text(fill: thws-orange)[‣], text(fill: thws-orange)[–]))
  set enum(indent: 1em, numbering: (..nums) => text(fill: thws-orange, numbering("1.", ..nums)))

  set heading(numbering: "1.1")
  show heading: set block(sticky: true)

  // H1 — kompakte Kapitelmarke (Nummer inline + Strich)
  show heading.where(level: 1): it => {
    if it.numbering == none {
      block(above: 1.2em, below: 0.7em)[
        #text(size: 22pt, weight: "bold", fill: thws-ink)[#it.body]
        #v(0.3em)
        #box(width: 48pt, height: 2.5pt, fill: thws-orange)
      ]
    } else {
      let n = counter(heading).at(it.location()).first()
      block(above: 1.9em, below: 0.9em, breakable: false)[
        #grid(columns: (auto, auto), column-gutter: 12pt, align: bottom,
          text(size: 27pt, weight: "bold", fill: thws-orange)[#numbering("1", n)],
          text(size: 20pt, weight: "bold", fill: thws-ink)[#it.body],
        )
        #v(8pt)
        #box(width: 48pt, height: 2.5pt, fill: thws-orange)
      ]
    }
  }

  // H2 — teal, mit orange-getönter Nummer
  show heading.where(level: 2): it => block(above: 1.6em, below: 0.6em)[
    #text(size: 14.5pt, weight: "bold", fill: thws-teal)[
      #if it.numbering != none [ #text(fill: thws-orange)[#counter(heading).display(it.numbering)] #h(6pt) ]
      #it.body
    ]
  ]
  show heading.where(level: 3): it => block(above: 1.2em, below: 0.4em)[
    #text(size: 12pt, weight: "bold", fill: thws-ink)[
      #if it.numbering != none [ #text(fill: thws-orange)[#counter(heading).display(it.numbering)] #h(5pt) ]
      #it.body
    ]
  ]

  // Blockzitat: eigenes Rendering — genau ein Block mit einer linken Kante
  // (das frühere `set block(stroke: left)` ergab eine doppelte/versetzte Linie).
  set quote(block: true)
  show quote.where(block: true): it => block(
    width: 100%,
    above: 1.1em, below: 1.1em,
    inset: (left: 14pt),
    stroke: (left: 2.5pt + thws-orange),
    text(style: "italic", fill: thws-ink-soft, it.body),
  )

  set table(
    inset: (x: 8pt, y: 6pt), align: left,
    stroke: (x, y) => if y == 0 { none } else { (bottom: 0.5pt + thws-line) },
    fill: (x, y) => if y == 0 { thws-teal } else if calc.odd(y) { white } else { thws-sunken },
  )
  show table.cell.where(y: 0): set text(fill: white, weight: "bold", size: 9.5pt)
  show table.cell: set text(size: 9.5pt)

  // -------------------------------------------------------------------------
  // MASTHEAD (kompakt, kein Deckblatt)
  // -------------------------------------------------------------------------
  // Im Masthead kein Blocksatz — sonst streckt der globale justify:true den
  // (mehrzeiligen) Titel über die Zeile. Vor dem Body wieder aktivieren.
  set par(justify: false)
  v(4pt)
  text(size: 11pt, tracking: 0.26em, fill: thws-orange, weight: "bold")[#upper(if lang == "de" { "Handout" } else { "Handout" })]
  v(12pt)
  text(size: 28pt, weight: "bold", fill: thws-ink, hyphenate: false)[#title]
  if subtitle != none { v(8pt); text(size: 13.5pt, fill: thws-muted)[#subtitle] }
  v(14pt)
  box(width: 56pt, height: 3pt, fill: thws-orange)
  v(12pt)

  // Meta-Streifen
  {
    let metas = (
      (if course != none { ("Modul", course) }),
      (if semester != none { ("Semester", semester) }),
      (if author_string != "" { ("Dozent", author_string) }),
      (if date-disp != none { ("Stand", date-disp) }),
    ).filter(x => x != none)
    block(width: 100%, stroke: (top: 0.5pt + thws-line, bottom: 0.5pt + thws-line), inset: (y: 10pt))[
      // auto-Spalten: jede so breit wie ihr Inhalt → der Dozentenname bricht
      // nicht um. Etwas kleinere Werte-Schrift.
      #grid(columns: metas.map(_ => auto), column-gutter: 20pt,
        ..metas.map(m => stack(spacing: 4pt,
          text(size: 7pt, tracking: 0.16em, fill: thws-faint)[#upper(m.at(0))],
          text(size: 10pt, weight: "bold", fill: thws-ink)[#m.at(1)],
        )),
      )
    ]
  }

  // Abstract (kompakte Sunken-Box)
  if abstract != none {
    v(14pt)
    block(width: 100%, fill: thws-sunken, radius: 6pt, inset: (x: 16pt, y: 13pt))[
      #set text(size: 10pt, style: "italic", fill: thws-ink-soft)
      #set par(leading: 0.62em, justify: true)
      #abstract
    ]
  }

  // Inhaltsübersicht
  if show_outline {
    v(18pt)
    eyebrow(if lang == "de" { "Inhaltsübersicht" } else { "Contents" }, thws-teal)
    v(8pt)
    // H1-Eintrag: Nummer orange, Titel/Seite Tinte-fett.
    show outline.entry.where(level: 1): it => {
      v(6pt, weak: true)
      set text(weight: "bold", fill: thws-ink)
      link(it.element.location(), it.indented(
        text(fill: thws-orange, it.prefix()),
        it.inner(),
      ))
    }
    set outline(indent: 1.2em)
    outline(title: none, depth: outline_depth)
  }

  // QR-Code dezent in den rechten Rand (Seite 1)
  let qr_target = if web_url != none { web_url } else { github_url }
  if qr_target != none {
    place(top + right, dx: 18mm, dy: 0mm)[
      #align(center)[
        #box(fill: white, inset: 3pt, radius: 3pt)[#qr-code(qr_target, width: 15mm)]
        #v(2pt)
        #text(size: 5.5pt, fill: thws-muted)[Online-Version]
      ]
    ]
  }

  v(18pt)

  // -------------------------------------------------------------------------
  // INHALT
  // -------------------------------------------------------------------------
  set par(justify: true)
  body

  // Literatur: erzeugt von Quartos #bibliography(...)-Call, gestylt vom
  // `show bibliography`-Hook oben (Überschrift, Schrift, Abstände).
}
