-- ===========================================================================
-- THWS Reader — Pandoc-Filter (Typst + HTML)
-- Redesign: farbcodierte Boxen via #flashcard(kind:…), Inline-Asides
--           #merksatz / #begriff, Ballot-Boxen im Quick-Check.
-- ===========================================================================

-- Dokumentsprache — wird in Meta() gesetzt und in get_labels()/Div() genutzt.
-- Wichtig: Pandoc ruft Meta NACH den Blöcken auf; deshalb erzwingt der
-- Zwei-Pass-Return am Dateiende, dass Meta zuerst läuft.
local DOC_LANG = nil

-- 1. META-DATEN & URL-LOGIK -------------------------------------------------
function Meta(m)
    if m.lang then DOC_LANG = pandoc.utils.stringify(m.lang) end

    -- Logo-Pfade relativ zur EXTENSION auflösen, falls der Autor nichts setzt.
    -- quarto.utils.resolvePath() findet die mitgelieferte Datei – egal ob die
    -- Extension lokal unter _extensions/reader/ oder nach `quarto add owner/repo`
    -- unter _extensions/owner/reader/ liegt. So reisen die Logos mit und es
    -- braucht keinen hartcodierten Pfad. Ein im Dokument gesetzter Key
    -- (handout-logo / handout-logo-en) hat Vorrang.
    -- resolvePath() gibt einen ABSOLUTEN Pfad; Typst löst read() aber relativ
    -- zur .typ (= Dokumentordner) auf — daher relativ machen.
    if quarto.doc.is_format("typst") then
        local doc_dir = pandoc.path.directory(quarto.doc.input_file or ".")
        local function logo_rel(name)
            return pandoc.path.make_relative(quarto.utils.resolvePath(name), doc_dir)
        end
        if not m['handout-logo'] then
            m['handout-logo'] = pandoc.MetaString(logo_rel("thws-logo.svg"))
        end
        if not m['handout-logo-en'] then
            m['handout-logo-en'] = pandoc.MetaString(logo_rel("thws-logo_en.svg"))
        end
    end

    if not m.web_url and m.website and m.website['site-url'] then
        local base_url = pandoc.utils.stringify(m.website['site-url'])
        if quarto.doc.input_file then
            local html_file = quarto.doc.input_file:gsub("%.%w+$", ".html")
            base_url = base_url .. "/" .. html_file
        end
        m.web_url = base_url
    end

    return m
end

-- 2. WÖRTERBUCH & SPRACHE ----------------------------------------------------
local function get_labels()
    -- Aus Meta() erfasste Dokumentsprache; THWS-Default ist Deutsch.
    local lang = DOC_LANG or "de"

    local vocab = {
        note            = "Note",
        drag_title      = "Exercise · Terms",
        quiz_title      = "Quick Check",
        case_title      = "Case Study",
        definition_title= "Definition",
        deepdive_title  = "Deep Dive",
        solution_title  = "Solution",
        video_title     = "Video Recommendation",
    }

    if lang and type(lang) == "string" and lang:find("^de") then
        vocab = {
            note             = "Hinweis",
            drag_title       = "Übung · Begriffe",
            quiz_title       = "Quick-Check",
            case_title       = "Fallstudie",
            definition_title = "Definition",
            deepdive_title   = "Deep Dive",
            solution_title   = "Lösung",
            video_title      = "Video-Empfehlung",
        }
    end
    return vocab
end

-- 3. HILFSFUNKTIONEN ---------------------------------------------------------

-- Für Typst-String-Argumente: Quotes/Backslashes neutralisieren
local function tq(s)
    s = s or ""
    s = s:gsub("\\", "\\\\"):gsub('"', '\\"')
    return s
end

-- H4-Titel vom restlichen Inhalt trennen
local function split_title_content(el, default_title)
    local title_text = default_title
    local content_blocks = pandoc.Blocks({})
    for _, block in ipairs(el.content) do
        if block.t == "Header" and block.level == 4 then
            title_text = pandoc.utils.stringify(block.content)
        else
            content_blocks:insert(block)
        end
    end
    return title_text, content_blocks
end

-- Emphasis -> Strong (Lückentext-Begriffe)
local function highlight_gaps(blocks)
    local div = pandoc.Div(blocks)
    local result = pandoc.walk_block(div, {
        Emph = function(el)
            local new_inlines = pandoc.Inlines({})
            new_inlines:extend(el.content)
            return pandoc.Strong(new_inlines)
        end
    })
    return result.content
end

-- Quiz-Liste -> Ballot-Boxen (☑ richtig / ☐ falsch)
local function format_quiz_list(blocks)
    local div = pandoc.Div(blocks)
    local result = pandoc.walk_block(div, {
        BulletList = function(el)
            local new_items = pandoc.List({})
            for _, item in ipairs(el.content) do
                local is_correct = false
                pandoc.walk_block(pandoc.Div(item), {
                    Strong = function(e) is_correct = true end
                })
                local marker = is_correct and "☑  " or "☐  "
                if item[1] and item[1].t == "Para" then
                    item[1].content:insert(1, pandoc.Str(marker))
                end
                new_items:insert(item)
            end
            return pandoc.BulletList(new_items)
        end
    })
    return result.content
end

-- Lösungs-Label "Lösung: " fett vor den ersten Absatz der Lösung setzen
local function prepend_solution_label(blocks, label)
    local out = pandoc.Blocks({})
    local done = false
    for _, b in ipairs(blocks) do
        if (not done) and b.t == "Para" then
            local inl = pandoc.Inlines({})
            inl:insert(pandoc.Strong(pandoc.Inlines({ pandoc.Str(label .. ":"), pandoc.Space() })))
            inl:extend(b.content)
            out:insert(pandoc.Para(inl))
            done = true
        else
            out:insert(b)
        end
    end
    if not done then
        out:insert(pandoc.Para(pandoc.Strong(pandoc.Str(label .. ":"))))
        out:extend(blocks)
    end
    return out
end

-- 4. HEADER: H4 in Boxen ausblenden -----------------------------------------
function Header(el)
    if el.level == 4 then
        el.classes:insert('unnumbered')
        el.classes:insert('unlisted')
    end
    return el
end

-- 5. DIV: RENDER-LOGIK -------------------------------------------------------
function Div(el)
    local labels = get_labels()

    -- === A. TYPST (PDF READER) ===
    if quarto.doc.is_format("typst") then

        -- A0. Inline-Asides (Option B): Merksatz & Begriff
        if el.classes:includes("merksatz") then
            local result = pandoc.Blocks({})
            result:insert(pandoc.RawBlock("typst", "#merksatz[\n"))
            result:extend(el.content)
            result:insert(pandoc.RawBlock("typst", "\n]"))
            return result
        elseif el.classes:includes("begriff") then
            local t = (el.attributes and el.attributes.title) or ""
            local hdr, content = split_title_content(el, "")
            if t == "" then t = hdr end
            local result = pandoc.Blocks({})
            result:insert(pandoc.RawBlock("typst", '#begriff(title: "' .. tq(t) .. '")[\n'))
            result:extend(content)
            result:insert(pandoc.RawBlock("typst", "\n]"))
            return result
        end

        -- A1. Farbcodierte Boxen
        local kind = nil
        local box_label = nil
        local box_title = nil           -- spezifische H4-Überschrift (optional)
        local typst_content = pandoc.Blocks({})

        if el.classes:includes("drag-exercise") then
            kind, box_label = "drag", labels.drag_title
            typst_content:extend(highlight_gaps(el.content))

        elseif el.classes:includes("quick-check") then
            kind, box_label = "quiz", labels.quiz_title
            typst_content:extend(format_quiz_list(el.content))

        elseif el.classes:includes("case-study") then
            kind, box_label = "case", labels.case_title
            local t, c = split_title_content(el, nil)
            box_title = t
            for _, block in ipairs(c) do
                if block.t == "Div" and block.classes:includes("solution") then
                    typst_content:insert(pandoc.RawBlock("typst", "#solution-divider()"))
                    typst_content:extend(prepend_solution_label(block.content, labels.solution_title))
                else
                    typst_content:insert(block)
                end
            end

        elseif el.classes:includes("flip-card") then
            kind, box_label = "definition", labels.definition_title
            local t, c = split_title_content(el, nil)
            box_title = t
            typst_content:extend(c)

        elseif el.classes:includes("details") then
            kind, box_label = "deepdive", labels.deepdive_title
            local t, c = split_title_content(el, nil)
            box_title = t
            typst_content:extend(c)
        end

        -- Sonderfall Video (kann zusätzlich gesetzt sein)
        if el.classes:includes("video") then
            kind, box_label, box_title = "video", labels.video_title, nil
            typst_content = pandoc.Blocks({})
            typst_content:extend(el.content)
        end

        if kind ~= nil then
            local result = pandoc.Blocks({})
            local args = '#flashcard(kind: "' .. kind .. '"'
            if box_label then args = args .. ', label: "' .. tq(box_label) .. '"' end
            if box_title then args = args .. ', title: [' .. box_title .. ']' end
            args = args .. ')[\n'
            result:insert(pandoc.RawBlock("typst", args))
            result:extend(typst_content)
            result:insert(pandoc.RawBlock("typst", "\n]"))
            return result
        end
    end

    -- === B. HTML (WEB / MOODLE) ===
    if quarto.doc.is_format("html") then
        if el.classes:includes("details") then
            local t, c = split_title_content(el, "Details")
            local result = pandoc.Blocks({})
            result:insert(pandoc.RawBlock("html", "<details><summary>" .. t .. "</summary>"))
            result:extend(c)
            result:insert(pandoc.RawBlock("html", "</details>"))
            return result
        elseif el.classes:includes("merksatz") then
            local result = pandoc.Blocks({})
            result:insert(pandoc.RawBlock("html", '<aside class="thws-merksatz"><span class="thws-eyebrow">' .. labels.note .. '</span>'))
            result:extend(el.content)
            result:insert(pandoc.RawBlock("html", "</aside>"))
            return result
        elseif el.classes:includes("begriff") then
            local t = (el.attributes and el.attributes.title) or ""
            local hdr, content = split_title_content(el, "")
            if t == "" then t = hdr end
            local result = pandoc.Blocks({})
            result:insert(pandoc.RawBlock("html", '<aside class="thws-begriff"><span class="thws-eyebrow">' .. t .. '</span>'))
            result:extend(content)
            result:insert(pandoc.RawBlock("html", "</aside>"))
            return result
        end
    end
end

-- 6. PASS-REIHENFOLGE --------------------------------------------------------
-- Erst Meta (setzt DOC_LANG), dann Header/Div — sonst kennt die Box-Render-
-- Logik die Dokumentsprache noch nicht und Labels fallen auf Deutsch zurück.
return {
    { Meta = Meta },
    { Header = Header, Div = Div },
}
