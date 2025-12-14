function Header(el)
  -- Wenn es eine Überschrift Level 4 ist (####)
  if el.level == 4 then
    -- Füge die Klasse .unnumbered hinzu (stoppt Nummerierung)
    el.classes:insert('unnumbered')
    -- Füge die Klasse .unlisted hinzu (stoppt Eintrag im TOC)
    el.classes:insert('unlisted')
  end
  return el
end