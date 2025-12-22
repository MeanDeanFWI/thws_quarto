

# 📘 THWS Interactive Scripts – Quickstart Guide

Diese Anleitung erklärt, wie Sie in 5 Minuten eine interaktive Vorlesungseinheit (PDF-Skript + Moodle-HTML) erstellen.

---

## 🛠️ 1. Vorbereitung (Einmalig)

Stellen Sie sicher, dass folgende Software installiert ist:

1. **[VS Code](https://code.visualstudio.com/)** (Editor)
2. **[Quarto CLI](https://quarto.org/docs/get-started/)** (Der Generator)
3. **VS Code Extension:** Suchen Sie in VS Code (links bei den Quadraten) nach "Quarto" und installieren Sie die Extension.

---

## 🚀 2. Projekt starten

1. Erstellen Sie einen neuen, leeren Ordner für Ihre Vorlesung (z.B. `Marketing_01`).
2. Öffnen Sie diesen Ordner in VS Code (`Datei` -> `Ordner öffnen...`).
3. Öffnen Sie das **Terminal** in VS Code (Menü: `Terminal` -> `New Terminal`).
4. Geben Sie folgenden Befehl ein, um die THWS-Vorlagen zu installieren:

```bash
quarto add MeanDeanFWI/thws_quarto

```

*Bestätigen Sie alle Abfragen mit der Taste `Enter` (bzw. `y` für Yes).*

---

## 📝 3. Die Datei anlegen (YAML)

Erstellen Sie eine neue Datei, z.B. `01_vorlesung.qmd`.
Kopieren Sie diesen Header **exakt** an den Anfang der Datei.

💡 **Tipp:** Löschen Sie die Formate raus, die Sie gerade nicht brauchen (einfach mit `#` auskommentieren).

```yaml
---
title: "Titel der Einheit"
subtitle: "Untertitel"
date: last-modified
lang: de

# Autoren-Daten (Wichtig für das Deckblatt)
author:
  - name: Ihr Name
    email: ihr.name@thws.de
    role: Dozent
    affiliation: THWS FWI

# Semester-Daten
semester: "WS 25/26"
course: "Modulname"
version: "1.0"

# --- Ausgabe-Formate ---
format:
  # 1. Skript (PDF) - Das volle Lehrbuch
  #reader-typst:
    logo: "images/logo.png"  # Optional: Eigenes Logo (siehe unten)

  # 2. Handout (PDF) - Kompakt für die Vorlesung
  #handout-typst:
    logo: "images/logo.png"

  # 3. Moodle (HTML) - Interaktiv für LMS
  #moodle-html:
    
---
```


## 🖼️ Exkurs: Eigenes Logo einbinden


1. Erstellen Sie einen Ordner `images` in Ihrem Projekt.
2. Legen Sie dort Ihre Bilddatei ab (z.B. `logo.png` oder `logo.svg`).
3. Fügen Sie im YAML-Header (siehe oben) unter dem jeweiligen Format die Zeile hinzu:
`logo: "images/logo.png"`

---

## ✨ 4. Interaktive Elemente einbauen

Schreiben Sie Ihren Inhalt in normalem Text. Nutzen Sie folgende Bausteine für Interaktionen:

### A. Lernkarten (Flip-Cards)

Ideal für Definitionen. Der Titel ist die Vorderseite, der Inhalt die Rückseite.

```markdown
::: {.flip-card}
#### Was ist der ROI?
Der Return on Investment beschreibt die Kapitalrentabilität einer Investition.
:::

```

### B. Lückentext (Drag & Drop)

Markieren Sie die einzusetzenden Wörter *kursiv* mit Sternchen.

```markdown
::: {.drag-exercise}
Die Bilanz ist eine *Zeitpunktrechnung*, die GuV ist eine *Zeitraumrechnung*.
:::

```

### C. Quiz (Quick-Check)

Markieren Sie die richtige Antwort **fett**.

```markdown
::: {.quick-check}
Welches Prinzip gilt im HGB?
- Fair Value
- **Vorsichtsprinzip**
- Matching Principle
> Das HGB dient primär dem Gläubigerschutz.
:::

```

### D. Fallstudien (Reflection Pattern)

Erst nachdenken, dann Lösung sehen. Das Textfeld erscheint automatisch.

```markdown
::: {.case-study}
#### Fall Müller
Herr Müller hat vergessen, die Rückstellung zu bilden. Wie bewerten Sie das?

::: {.solution}
**Lösung:**
Nach § 249 HGB muss für ungewisse Verbindlichkeiten eine Rückstellung gebildet werden.
:::
:::

```

### E. Videos (YouTube)

Bettet Videos datenschutzkonform ein.

```markdown
{{< video https://www.youtube.com/watch?v=VIDEO_ID >}}

```

---

## 🖨️ 5. Ergebnis erstellen (Rendern)

Drücken Sie in VS Code oben rechts auf den **Render**-Button (blauer Pfeil) oder nutzen Sie das Terminal:

* **Alles erstellen:** `quarto render 01_vorlesung.qmd`
* **Nur HTML (schnell):** `quarto render 01_vorlesung.qmd --to html`
* **Nur PDF:** `quarto render 01_vorlesung.qmd --to thws-reader-typst`

🎉 **Fertig!** Laden Sie die HTML-Datei oder das PDF in Moodle hoch und danken Sie dem Studiendekan.