#show: doc => project(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$

// Autoren: Reihenfolge & Rollen aus dem Quarto-Author-Schema
$if(by-author)$
  authors: (
    $for(by-author)$
    (
      name: "$it.name.literal$".replace("~", " "),
      $if(it.email)$ email: "$it.email$".replace("\\", ""), $endif$
      $if(it.role)$
        role: "$it.role$".replace("\\", ""),
      $else$
        $if(it.roles)$
          role: "$for(it.roles)$$it.role$$sep$ $endfor$".replace("\\", ""),
        $endif$
      $endif$
      $if(it.affiliations)$
        affiliation: "$for(it.affiliations)$$it.name$$sep$, $endfor$".replace("\\", ""),
      $endif$
    ),
    $endfor$
  ),
$endif$

$if(date)$
  date: "$date$".replace("\\", ""),
$endif$
$if(lang)$
  lang: "$lang$",
$endif$

// Logo: eigener Key 'reader-logo' (NICHT 'logo' — das ist von Quartos
// Brand-System reserviert und käme nur als "true" an). .replace entfernt den
// Backslash, den Pandoc vor '_' im Pfad setzt (z. B. _extensions → \_extensions).
$if(reader-logo)$ logo: "$reader-logo$".replace("\\", ""), $endif$
$if(reader-logo-en)$ logo_en: "$reader-logo-en$".replace("\\", ""), $endif$

// Optionale Overrides
$if(course)$ course: [$course$], $endif$
$if(semester)$ semester: [$semester$], $endif$
$if(faculty)$ faculty: [$faculty$], $endif$
$if(university)$ university: [$university$], $endif$
$if(version)$ version: [$version$], $endif$

// QR-Code-URLs — 'web_url' wird vom filter.lua automatisch befüllt
$if(web_url)$ web_url: "$web_url$", $else$$if(web-url)$ web_url: "$web-url$", $endif$$endif$
$if(github_url)$ github_url: "$github_url$", $else$$if(github-url)$ github_url: "$github-url$", $endif$$endif$

// Layout-Steuerung
$if(outline-depth)$ outline_depth: $outline-depth$, $endif$
$if(show-outline)$ show_outline: $show-outline$, $endif$

// Bibliographie
  // Quarto (>= 1.8) erzeugt den #bibliography(...)-Call selbst; das Template
  // stylt ihn per `show bibliography`-Hook (kein bib_file mehr nötig).
  doc,
)
