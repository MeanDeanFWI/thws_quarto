# 📘 THWS Interactive Scripts – Quickstart Guide

Diese Anleitung erklärt, wie Sie in 5 Minuten eine interaktive Vorlesungseinheit (PDF-Skript + Moodle-HTML) erstellen.

---

## 🛠️ 1. Vorbereitung (Einmalig)

Stellen Sie sicher, dass folgende Software installiert ist:

1. **[VS Code](https://code.visualstudio.com/)** (Editor)
2. **[Quarto CLI](https://quarto.org/docs/get-started/)** (Der Generator)
3. **VS Code Extension:** Suchen Sie in VS Code nach "Quarto" und installieren Sie die Extension.

---

## 🚀 2. Projekt starten

1. Erstellen Sie einen neuen, leeren Ordner für Ihre Vorlesung (z.B. `Marketing_01`).
2. Öffnen Sie diesen Ordner in VS Code (`Datei` -> `Ordner öffnen...`).
3. Öffnen Sie das **Terminal** in VS Code (Menü: `Terminal` -> `New Terminal`).
4. Geben Sie folgenden Befehl ein, um die THWS-Vorlagen zu installieren:

```bash
quarto add c-kraus/thws_quarto

```

*Bestätigen Sie alle Abfragen mit der Taste `Enter` (bzw. `y` für Yes).*

---

## 📝 3. Die Datei anlegen (YAML)

Erstellen Sie eine neue Datei, z.B. `01_vorlesung.qmd`.
Kopieren Sie diesen Header **exakt** an den Anfang der Datei:

```yaml
---
title: "Titel der Einheit"
subtitle: "Untertitel"
date: last-modified
lang: de

# WICHTIG: Link zur Web-Version für den automatischen QR-Code im PDF
web_url: "https://ihr-user.github.io/kurs-name/01_vorlesung.html"

# Autoren-Daten
author:
  - name: Ihr Name
    email: ihr.name@thws.de
    role: Dozent
    affiliation: THWS FWI

# Semester-Daten
semester: "WS 25/26"
course: "Modulname"
version: "1.0"

# Format wählen (beide gleichzeitig möglich beim Export)
format:
  # 1. Skript (PDF) - Statisch, druckreif
  gtl_reader-typst: default
    
  # 2. Moodle (HTML) - Interaktiv
  moodle-html: default
---

```

---

## ✨ 4. Interaktive Elemente einbauen

Das System folgt dem **"Single Source"** Prinzip: Sie schreiben einmal, das System generiert daraus automatisch interaktives HTML für Moodle und statische Boxen für das PDF.

### A. Lernkarten (Flip-Cards)

Ideal für Definitionen.

* **Web:** Karte dreht sich per Klick.
* **PDF:** Statische Definitions-Box.

```markdown
::: {.flip-card}
#### Was ist der ROI?
Der Return on Investment beschreibt die Kapitalrentabilität einer Investition.
:::

```

### B. Deep Dives (Exkurse)

Für komplexe Details oder Gesetzestexte, die den Lesefluss stören würden.

* **Web:** Akkordeon (aufklappbar).
* **PDF:** Abgesetzte Info-Box, damit der Inhalt sichtbar bleibt.

```markdown
::: {.details}
#### Deep Dive: IAS 38
Hier stehen komplexe Details zur Aktivierung von immateriellen Vermögenswerten...
:::

```

### C. Fallstudien (Reflection Pattern)

Trennt Problemstellung und Lösung.

* **Web:** Lösung ist ggf. zunächst ausgeblendet.
* **PDF:** Box mit klarer Trennlinie zur Lösung.

```markdown
::: {.case-study}
#### Fall Müller
Herr Müller hat vergessen, die Rückstellung zu bilden.

::: {.solution}
**Lösung:** Nach § 249 HGB besteht Passivierungspflicht.
:::
:::

```

### D. Lückentext (Drag & Drop)

Markieren Sie die einzusetzenden Wörter *kursiv* mit Sternchen.

* **Web:** Interaktives Drag & Drop Spiel.
* **PDF:** Text ist lesbar, Lösungen sind **fett** gedruckt.

```markdown
::: {.drag-exercise}
Die Bilanz ist eine *Zeitpunktrechnung*, die GuV ist eine *Zeitraumrechnung*.
:::

```

### E. Quiz (Quick-Check)

Markieren Sie die richtige Antwort **fett**.

* **Web:** Klickbares Quiz mit Feedback.
* **PDF:** Checkliste zum Ankreuzen.

```markdown
::: {.quick-check}
Welches Prinzip gilt im HGB?
- Fair Value
- **Vorsichtsprinzip**
- Matching Principle
> Das HGB dient primär dem Gläubigerschutz.
:::

```

### F. Videos (YouTube)

Bettet Videos datenschutzkonform ein.

* **Web:** Videoplayer.
* **PDF:** Link-Box mit Hinweis.

```markdown
::: {.video}
{{< video https://www.youtube.com/watch?v=VIDEO_ID >}}
:::

```

---

## 🔗 5. Hybrid-Publishing (QR-Codes)

Damit Studierende im gedruckten Skript (PDF) direkt zur interaktiven Version gelangen, wird automatisch ein QR-Code generiert.

1. Definieren Sie im YAML-Header die `web_url` (siehe Schritt 3).
2. Beim Erstellen des PDFs (`reader-typst`) erscheint oben rechts automatisch der QR-Code, der auf diese URL zeigt.

*Tipp: Wenn Sie die URL leer lassen, wird kein Code generiert.*

---

## 🖨️ 6. Ergebnis erstellen (Rendern)

1. Öffnen Sie die Datei in VS Code.
2. Drücken Sie den **Render** Button (oder `Ctrl+Shift+K`).
3. Wählen Sie das Format (HTML für Moodle, Typst für PDF).

*Nachher dem Studiendekan danken.*

## 🔄 7. Updates & Wartung

Die THWS-Vorlagen werden stetig verbessert (neue Features, Design-Anpassungen). So halten Sie Ihr Skript aktuell:

1.  Öffnen Sie das Terminal in Ihrem Projektordner.
2.  Führen Sie denselben Befehl wie bei der Installation aus:

```bash
quarto add c-kraus/thws_quarto
```

Quarto erkennt, dass die Erweiterung bereits existiert und fragt: Extension '...' already exists. Overwrite? (y/n/a)

Bestätigen Sie mit a (für "All") oder y.

⚠️ Wichtig:

Ihre Inhalte (Texte in .qmd-Dateien) bleiben dabei zu 100% sicher.

Nur die Systemdateien im Ordner _extensions werden überschrieben. (Haben Sie dort manuell Dinge geändert, gehen diese verloren – was man ohnehin vermeiden sollte).