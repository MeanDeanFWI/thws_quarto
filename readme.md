

# 📘 THWS Interactive Scripts – Quickstart Guide

Diese Anleitung erklärt, wie Sie in 5 Minuten eine interaktive Vorlesungseinheit (PDF-Skript + Moodle-HTML) erstellen.

---

## 🛠️ 1. Vorbereitung (Einmalig)

Stellen Sie sicher, dass folgende Software installiert ist:
1.  **[VS Code](https://code.visualstudio.com/)** (Editor)
2.  **[Quarto CLI](https://quarto.org/docs/get-started/)** (Der Generator)
3.  **VS Code Extension:** Suchen Sie in VS Code nach "Quarto" und installieren Sie die Extension.

---

## 🚀 2. Projekt starten

1.  Erstellen Sie einen neuen, leeren Ordner für Ihre Vorlesung (z.B. `Marketing_01`).
2.  Öffnen Sie diesen Ordner in VS Code (`Datei` -> `Ordner öffnen...`).
3.  Öffnen Sie das **Terminal** in VS Code (Menü: `Terminal` -> `New Terminal`).
4.  Geben Sie folgenden Befehl ein, um die THWS-Vorlagen zu installieren:

```bash
quarto add MeanDeanFWI/thws_quarto

```

*Bestätigen Sie alle Abfragen mit der Taste `Enter` (bzw. `y` für Yes).*

---

## 📝 3. Die Datei anlegen (YAML)Erstellen Sie eine neue Datei, z.B. `01_vorlesung.qmd`.
Kopieren Sie diesen Header **exakt** an den Anfang der Datei:

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
    affiliation: THWS Business School

# Semester-Daten
semester: "WS 25/26"
course: "Modulname"
version: "1.0"

# für eine Variante entscheiden
format:
  # 1. Skript (PDF)
 # reader-typst
    
  # 2. Handout (PDF)
 # handout-typst

  # 3. Moodle (HTML Interaktiv)
 # moodle-html
---

```

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

### D. Videos (YouTube)

Bettet Videos datenschutzkonform ein.

```markdown
{{< video [https://www.youtube.com/watch?v=IHR_VIDEO_ID](https://www.youtube.com/watch?v=IHR_VIDEO_ID) >}}

```

---

## 🖨️ 5. Ergebnis erstellen (Rendern)

Wenn Sie fertig sind:

Gewünschtes Format im YAML angeben und den render Button drücken.

Nachher dem Studiendekan danken.