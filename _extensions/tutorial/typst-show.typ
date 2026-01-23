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

// FIX: Reihenfolge gedreht & 'it.role' in der Schleife benutzt
$if(by-author)$
  authors: (
    $for(by-author)$
    (
      // 1. Name: Tilden weg
      name: "$it.name.literal$".replace("~", " "),
      
      // 2. Email: Backslashes weg
      $if(it.email)$ email: "$it.email$".replace("\\", ""), $endif$

      // 3. Rolle
      $if(it.role)$
        role: "$it.role$".replace("\\", ""),
      $else$
        $if(it.roles)$
          role: "$for(it.roles)$$it.role$$sep$ $endfor$".replace("\\", ""),
        $endif$
      $endif$

      // 4. Affiliation
      $if(it.affiliations)$
        affiliation: "$for(it.affiliations)$$it.name$$sep$, $endfor$".replace("\\", ""),
      $endif$
    ),
    $endfor$
  ),
$endif$

$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$

// Optionale Overrides
$if(course)$ course: [$course$], $endif$
$if(semester)$ semester: [$semester$], $endif$
$if(faculty)$ faculty: [$faculty$], $endif$
$if(university)$ university: [$university$], $endif$
$if(version)$ version: [$version$], $endif$

// --- NEU: QR-Code URLs ---
// Das Lua-Skript füllt 'web_url' automatisch, hier reichen wir es an Typst weiter.
$if(web_url)$ web_url: "$web_url$", $else$$if(web-url)$ web_url: "$web-url$", $endif$$endif$
$if(github_url)$ github_url: "$github_url$", $else$$if(github-url)$ github_url: "$github-url$", $endif$$endif$

// Layout-Steuerung
$if(outline-depth)$ outline_depth: $outline-depth$, $endif$
$if(show-outline)$ show_outline: $show-outline$, $endif$

// Bibliographie
//$if(bibliography)$ bib_file: "$bibliography$", $endif$
//$if(biblio-style)$ citation_style: "$biblio-style$", $endif$
  doc,
)