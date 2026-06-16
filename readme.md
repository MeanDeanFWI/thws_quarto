# 📘 THWS Interactive Scripts – Quickstart Guide

Diese Anleitung erklärt, wie Sie in 5 Minuten eine interaktive Vorlesungseinheit (PDF-Skript + Moodle-HTML) erstellen.

Das System folgt dem **„Single Source"**-Prinzip: Sie schreiben den Inhalt **einmal**, und Quarto erzeugt daraus automatisch interaktives HTML für Moodle sowie druckreife PDFs.

---

> ### ⚠️ Version 2.0 — wichtige Änderung
> Die PDF-Vorlagen (`reader`/`handout`/`tutorial`) wurden überarbeitet (THWS-Logo automatisch,
> horizontal, sprachabhängig; neues Übungsblatt-Layout). **Logos nicht mehr über `logo:` setzen** —
> der Key ist von Quarto reserviert und funktioniert nicht. Das THWS-Logo erscheint jetzt
> automatisch; ein eigenes Logo optional über `reader-logo:` / `handout-logo:` / `tutorial-logo:`
> (siehe Exkurs). Details & Rückfall auf v1: siehe `CHANGELOG.md`
> (`quarto add c-kraus/thws_quarto@v1.0.0` installiert den alten Stand).

---

## 🛠️ 1. Vorbereitung (einmalig)

Stellen Sie sicher, dass folgende Software installiert ist:

1. **[VS Code](https://code.visualstudio.com/)** (Editor)
2. **[Quarto CLI](https://quarto.org/docs/get-started/)** (der Generator)
3. **VS Code Extension:** Suchen Sie in VS Code (links bei den Quadraten) nach „Quarto" und installieren Sie die Extension.

---

## 🚀 2. Projekt starten

1. Erstellen Sie einen neuen, leeren Ordner für Ihre Vorlesung (z. B. `Marketing_01`).
2. Öffnen Sie diesen Ordner in VS Code (`Datei` → `Ordner öffnen...`).
3. Öffnen Sie das **Terminal** in VS Code (Menü: `Terminal` → `New Terminal`).
4. Geben Sie folgenden Befehl ein, um die THWS-Vorlagen zu installieren:

```bash
quarto add c-kraus/thws_quarto
```

*Bestätigen Sie alle Abfragen mit `Enter` (bzw. `y` für Yes).*

---

## 📝 3. Die Datei anlegen (YAML)

Erstellen Sie eine neue Datei, z. B. `01_vorlesung.qmd`, und kopieren Sie diesen Header **exakt** an den Anfang.

💡 **Tipp:** Kommentieren Sie Formate, die Sie gerade nicht brauchen, einfach mit `#` aus.

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

# --- Ausgabe-Formate (auskommentieren, was nicht gebraucht wird) ---
# Logo NICHT angeben — das THWS-Logo wird automatisch eingebunden. lang (oben)
# schaltet Logo + Beschriftungen (de/en).
format:
  reader-typst: default     # 1. Skript (PDF) – das vollständige Lehrbuch
  handout-typst: default    # 2. Handout (PDF) – kompakt für die Vorlesung
  tutorial-typst: default   # 3. Übungsblatt (PDF) – siehe eigener Hinweis unten
  moodle-html: default      # 4. Moodle (HTML) – interaktiv fürs LMS
---
```

### 🖼️ Exkurs: Logo

Das **THWS-Logo erscheint automatisch** (horizontal, oben links; bei `lang: en` die englische
Wortmarke) — Sie müssen nichts tun. Nur für ein **eigenes** Logo:

1. Legen Sie die Datei ab (z. B. `assets/logo.svg`).
2. Setzen Sie pro Format den **format-eigenen** Key (NICHT `logo:`):

```yaml
format:
  reader-typst:
    reader-logo: "assets/logo.svg"        # + reader-logo-en für die EN-Variante
  handout-typst:
    handout-logo: "assets/logo.svg"
  tutorial-typst:
    tutorial-logo: "assets/logo.svg"
```

---

## ✨ 4. Interaktive Elemente einbauen

Jedes Element erzeugt im **Web** eine interaktive Komponente und im **PDF** eine passende statische Box.

> **Übungsblatt (`tutorial-typst`):** Dieses Format nutzt seit v2 eine **eigene** Auszeichnung —
> große Aufgaben als `## …`, Teilaufgaben als `#### …`, Lösungen über Quartos
> `::: {.content-visible when-meta="show_solutions"}`. Anleitung & Beispiele:
> `docs/tutorial/README.md`. Die folgenden Boxen sind für
> `reader-typst`, `handout-typst` und `moodle-html` gedacht.

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

Trennt Problemstellung und Lösung – erst nachdenken, dann Lösung sehen.

* **Web:** Lösung ist zunächst ausgeblendet.
* **PDF:** Box mit klarer Trennlinie zur Lösung.

```markdown
::: {.case-study}
#### Fall Müller
Herr Müller hat vergessen, die Rückstellung zu bilden. Wie bewerten Sie das?

::: {.solution}
**Lösung:** Nach § 249 HGB besteht für ungewisse Verbindlichkeiten eine Passivierungspflicht.
:::
:::
```

### D. Lückentext (Drag & Drop)

Markieren Sie die einzusetzenden Wörter *kursiv* mit Sternchen.

* **Web:** Interaktives Drag-&-Drop-Spiel.
* **PDF:** Text ist lesbar, Lösungen sind **fett** gedruckt.

```markdown
::: {.drag-exercise}
Die Bilanz ist eine *Zeitpunktrechnung*, die GuV ist eine *Zeitraumrechnung*.
:::
```

### E. Quiz (Quick-Check)

Markieren Sie die richtige Antwort **fett**. Die Zeile nach `>` ist das Feedback.

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

*Tipp: Lassen Sie die URL leer, wird kein Code generiert.*

---

## 🖨️ 6. Ergebnis erstellen (Rendern)

Drücken Sie in VS Code oben rechts den **Render**-Button (blauer Pfeil bzw. `Ctrl+Shift+K`) oder nutzen Sie das Terminal:

* **Alles erstellen:** `quarto render 01_vorlesung.qmd`
* **Nur HTML (schnell):** `quarto render 01_vorlesung.qmd --to moodle-html`
* **Nur PDF-Skript:** `quarto render 01_vorlesung.qmd --to reader-typst`
* **Nur Übungsblatt:** `quarto render 01_vorlesung.qmd --to tutorial-typst`

🎉 **Fertig!** Laden Sie die HTML-Datei oder das PDF in Moodle hoch und danken Sie dem Studiendekan.

---

## 🔄 7. Updates & Wartung

Die THWS-Vorlagen werden stetig verbessert (neue Features, Design-Anpassungen). So halten Sie Ihr Skript aktuell:

1. Öffnen Sie das Terminal in Ihrem Projektordner.
2. Führen Sie denselben Befehl wie bei der Installation aus:

```bash
quarto add c-kraus/thws_quarto
```

Quarto erkennt, dass die Erweiterung bereits existiert, und fragt: `Extension '...' already exists. Overwrite? (y/n/a)` — bestätigen Sie mit `a` (für „All") oder `y`.

⚠️ **Wichtig:** Ihre Inhalte (Texte in `.qmd`-Dateien) bleiben dabei zu 100 % sicher. Nur die Systemdateien im Ordner `_extensions` werden überschrieben. (Haben Sie dort manuell Dinge geändert, gehen diese verloren – was man ohnehin vermeiden sollte.)
