-- ===========================================================================
-- THWS Tutorial / Übungsblatt — Minimal-Filter
-- Nur noch: Logo-Auto-Resolve (relativ zur Extension) + web_url (QR).
-- Lösungssichtbarkeit macht Quarto NATIV über  ::: {.content-visible
-- when-meta="show_solutions"}  — dafür braucht es keinen Filter.
-- ===========================================================================

function Meta(m)
    -- Logo-Pfade relativ zur EXTENSION auflösen, falls der Autor nichts setzt.
    -- resolvePath() findet die mitgelieferte Datei (lokal oder nach
    -- `quarto add owner/repo`); make_relative macht den absoluten Pfad
    -- Typst-tauglich (read() löst relativ zur .typ auf). Gesetzter Key gewinnt.
    if quarto.doc.is_format("typst") then
        local doc_dir = pandoc.path.directory(quarto.doc.input_file or ".")
        local function logo_rel(name)
            return pandoc.path.make_relative(quarto.utils.resolvePath(name), doc_dir)
        end
        if not m['tutorial-logo'] then
            m['tutorial-logo'] = pandoc.MetaString(logo_rel("thws-logo.svg"))
        end
        if not m['tutorial-logo-en'] then
            m['tutorial-logo-en'] = pandoc.MetaString(logo_rel("thws-logo_en.svg"))
        end
    end

    -- web_url für den QR-Code aus website.site-url ableiten (falls nicht gesetzt)
    if not m.web_url and m.website and m.website['site-url'] then
        local base_url = pandoc.utils.stringify(m.website['site-url'])
        if quarto.doc.input_file then
            base_url = base_url .. "/" .. quarto.doc.input_file:gsub("%.%w+$", ".html")
        end
        m.web_url = base_url
    end

    return m
end
