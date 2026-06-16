# Entwicklung (dev → main)

Dieses Repo wird von vielen Projekten per `quarto add c-kraus/thws_quarto` konsumiert (Default-
Branch `main`). Damit Konsumenten nicht vorzeitig brechen, läuft die Weiterentwicklung über `dev`.

## Branches
- **`main`** — stabil, das was `quarto add c-kraus/thws_quarto` ausliefert.
- **`dev`** — Weiterentwicklung. Testbar mit `quarto add c-kraus/thws_quarto@dev`.
- **Tags** — `v1.0.0` (Stand vor v2). Bei Release: `vX.Y.Z` auf `main`.

## Ablauf
1. Auf `dev` arbeiten: `git checkout dev`.
2. Extension(s) unter `_extensions/<name>/` ändern.
3. **Lokal rendern** (Smoke-Test) mit einer eigenen Test-`.qmd`:
   ```bash
   quarto render test.qmd --to tutorial-typst                        # Übungsblatt (Angabe)
   quarto render test.qmd --to tutorial-typst -M show_solutions:true # mit Lösungen
   # reader/handout ebenso gegenprüfen (lang de/en)
   ```
4. `CHANGELOG.md` pflegen, committen, `git push` (dev).
5. **Release:** `dev` → `main` mergen, `vX.Y.Z` taggen, pushen:
   ```bash
   git checkout main && git merge --no-ff dev && git tag -a vX.Y.Z -m "…" && git push && git push --tags
   ```

## Repo-Aufbau
- `_extensions/{reader,handout,tutorial}/` — die drei PDF-Formate (Typst). **Nur Funktionsdateien**
  (`_extension.yml`, `*.typ`, `filter.lua`, Logos) — wird per `quarto add` ausgeliefert.
- `_extensions/moodle/` — HTML/Moodle-Format (separat, bei Bedarf später überarbeiten).
- `docs/<name>/` — Entwickler-Doku (`README.md` je Format). **Nicht** ausgeliefert.

> Lokale Arbeitsdateien (gitignored, nicht im Repo): Mockup-HTMLs, `docs/reader/LOGO-STOLPERFALLE.md`,
> Musterdatei `tutorial-07-real-options.qmd`, `tutorial-skill-prompt.md`.
