local function inject_header(doc)
  local ext_dir = pandoc.path.directory(PANDOC_SCRIPT_FILE)
  local logo_path = pandoc.path.join({ext_dir, "logo_en.svg"})

  -- Logo als <img>: Pandoc bettet die Datei via self-contained selbst ein
  -- (Pfadauflösung relativ zum Dokument/Resource-Path, NICHT zum CWD).
  -- Robust für Book-Renders auf GitHub Actions; inline-SVG via io.open
  -- scheiterte dort, weil io.open relativ zum Arbeitsverzeichnis auflöst.
  local header_html = '<div id="custom-header"><img src="' .. logo_path .. '" alt="THWS Logo"></div>\n' ..
    '<script>\n' ..
    'window.addEventListener("scroll", function() {\n' ..
    '  var h = document.getElementById("custom-header");\n' ..
    '  var s = document.getElementById("quarto-margin-sidebar");\n' ..
    '  var scrolled = window.pageYOffset > 50;\n' ..
    '  h.classList.toggle("shrink", scrolled);\n' ..
    '  if (s) s.classList.toggle("scrollmargin", scrolled);\n' ..
    '});\n' ..
    '</script>\n'

  local header_block = pandoc.RawBlock("html", header_html)
  local blocks = pandoc.List{header_block}
  blocks:extend(doc.blocks)
  return pandoc.Pandoc(blocks, doc.meta)
end

return { { Pandoc = inject_header } }
