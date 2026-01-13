-- gentleman-core.lua
-- Version: International & Hybrid (HTML/Typst)

-- 1. META-DATEN & URL LOGIK
-- Holt sich automatisch die site-url aus _quarto.yml, falls keine web_url gesetzt ist
function Meta(m)
    -- Hat der Nutzer manuell eine web_url gesetzt? Dann Vorrang.
    if m.web_url then
        return nil
    end

    -- Sonst: Suche in website -> site-url
    if m.website and m.website['site-url'] then
        local base_url = pandoc.utils.stringify(m.website['site-url'])

        -- Optional: Dateinamen anhängen für exakten Link
        if quarto.doc.input_file then
            local html_file = quarto.doc.input_file:gsub("%.%w+$", ".html")
            base_url = base_url .. "/" .. html_file
        end

        -- Die Variable für Typst bereitstellen
        m.web_url = base_url
        return m
    end
end

-- 2. WÖRTERBUCH & SPRACHERKENNUNG
local function get_labels()
    -- Standard-Fallback
    local lang = "de"

    -- Sicherheitsabfrage: Existiert die moderne Funktion?
    if quarto.doc and type(quarto.doc.lang) == "function" then
        lang = quarto.doc.lang()
    elseif PANDOC_READER_OPTIONS and PANDOC_READER_OPTIONS['lang'] then
        -- Editor-freundlicher Zugriff auf Optionen
        lang = PANDOC_READER_OPTIONS['lang']
    end

    -- Vokabeln (Englisch als Basis)
    local vocab = {
        note = "Note",
        drag_title = "Exercise: Terms",
        quiz_title = "Quick Check",
        solution_title = "Solution",
        video_title = "Video Recommendation"
    }

    -- Falls Deutsch erkannt wird (z.B. "de", "de-DE")
    if lang and type(lang) == "string" and lang:find("^de") then
        vocab = {
            note = "Hinweis",
            drag_title = "Übung: Begriffe",
            quiz_title = "Quick-Check",
            solution_title = "Lösung",
            video_title = "Video-Empfehlung"
        }
    end

    return vocab
end


-- 3. HILFSFUNKTIONEN

-- Titel & Inhalt trennen
local function split_title_content(el, default_title)
    local labels = get_labels()
    local title_text = default_title or labels.note

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

-- Rekursiv nach Emphasis suchen und fett machen (Typ-Sicher)
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

-- Listen in Checkboxen verwandeln
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
                local marker = is_correct and "[x] " or "[ ] "
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


-- 4. HAUPTFUNKTIONEN (RENDER LOGIK)

function Header(el)
    -- H4 in Spezialboxen ausblenden
    if el.level == 4 then
        el.classes:insert('unnumbered')
        el.classes:insert('unlisted')
    end
    return el
end

function Div(el)
    -- === A. TYPST (PDF READER) ===
    if quarto.doc.is_format("typst") then
        local labels = get_labels()

        local typst_title = labels.note
        local typst_content = pandoc.Blocks({})
        local is_custom_box = false

        -- 1. Lückentext
        if el.classes:includes("drag-exercise") then
            typst_title = labels.drag_title
            local hl_content = highlight_gaps(el.content)
            typst_content:extend(hl_content)
            is_custom_box = true

            -- 2. Quiz
        elseif el.classes:includes("quick-check") then
            typst_title = labels.quiz_title
            local quiz_content = format_quiz_list(el.content)
            typst_content:extend(quiz_content)
            is_custom_box = true

            -- 3. Fallstudie
        elseif el.classes:includes("case-study") then
            local t, c = split_title_content(el, labels.note)
            typst_title = t

            for _, block in ipairs(c) do
                if block.t == "Div" and block.classes:includes("solution") then
                    typst_content:insert(pandoc.RawBlock("typst", "#line(length: 100%, stroke: 0.5pt + gray)"))
                    typst_content:insert(pandoc.RawBlock("typst", "*" .. labels.solution_title .. ":*"))
                    typst_content:extend(block.content)
                else
                    typst_content:insert(block)
                end
            end
            is_custom_box = true

            -- 4. Flipcards & Details
        elseif el.classes:includes("flip-card") or el.classes:includes("details") then
            local t, c = split_title_content(el, labels.note)
            typst_title = t
            typst_content:extend(c)
            is_custom_box = true
        end

        -- Sonderfall: Videos
        if el.classes:includes("video") then
            typst_title = labels.video_title
            typst_content:extend(el.content)
            is_custom_box = true
        end

        -- RENDERER: Alles wird zur #flashcard
        if is_custom_box then
            local result = pandoc.Blocks({})
            result:insert(pandoc.RawBlock("typst", "#flashcard(title: [" .. typst_title .. "])[\n"))
            result:extend(typst_content)
            result:insert(pandoc.RawBlock("typst", "\n]"))
            return result
        end
    end


    -- === B. HTML (WEB / MOODLE) ===
    if quarto.doc.is_format("html") then
        if el.classes:includes("details") then
            local labels = get_labels()
            -- Fallback Titel für HTML Details
            local t, c = split_title_content(el, "Details")

            local result = pandoc.Blocks({})
            result:insert(pandoc.RawBlock("html", "<details><summary>" .. t .. "</summary>"))
            result:extend(c)
            result:insert(pandoc.RawBlock("html", "</details>"))
            return result
        end
    end
end
