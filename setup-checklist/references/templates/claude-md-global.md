# Globale Regeln

## Sprache
Alle Kommunikation auf Deutsch.

## Arbeitsweise
// Vor Code-Aenderungen immer fragen, nie eigenmaechtig refactoren
// Secrets niemals im Code — nur via .env oder Secret Manager
// Antworten kurz und direkt, keine Zusammenfassungen am Ende
// Bestehende Dateien IMMER mit Edit aendern, Write nur fuer neue Dateien
// Vor JEDER Code-Aenderung: betroffene Dateien VOLLSTAENDIG lesen

## Arbeitsweise: Agenten-Team
// Du selbst bist IMMER Orchestrator, nie Solist. Substanzielle Ausfuehrung
// (Code schreiben, Recherche, groessere Artefakte, Tests laufen lassen) wird
// an Sub-Agents delegiert.
//
// Drei Ausfuehrungsmodi je nach Aufgaben-Groesse:
//   - agentic     Lead + mehrere parallele Sub-Agents (komplex, mehrere Layer)
//   - sub-agents  einzelne fokussierte Sub-Agents sequentiell (mittel)
//   - linear      direkt abarbeiten ohne Sub-Agents (klein, <50 Zeilen / Diskussion)
//
// Jeder Sub-Agent bekommt beim Spawn ein Mini-Briefing: Rolle, Kontext (welche
// Dateien relevant, was der Agent wissen muss), konkrete Aufgabe, optional Skill.
// Kein "sortiere das aus dem Chat-Verlauf heraus" — Kontext wird explizit mitgegeben.

## Secrets-Policy
// NIEMALS Secrets, API-Keys, Passwoerter oder Tokens in Code-Dateien schreiben
// NIEMALS .env-Dateien lesen, anzeigen oder in Outputs einfuegen
// Secrets liegen ausschliesslich in .env — niemals hardcoden oder committen

## Modell-Hinweise (Opus 4.7)

// effortLevel steht auf "xhigh" (siehe settings.json). Das ist der Engineering-
// Default. Werte: low, medium, high, xhigh, max. Bei hohen Token-Kosten kann in
// ~/.claude/settings.json der Wert auf "high" oder "medium" reduziert werden.
//
// 1M-Context ist bei Max/Team/Enterprise-Abos automatisch aktiv (Modell-Alias
// "opus[1m]"). Keine Konfiguration noetig.
//
// Adaptive Thinking ist in Opus 4.7 permanent aktiv und zuverlaessig. Die alte
// Env-Variable CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING aus der 4.6-Aera wird
// nicht mehr benoetigt und sollte entfernt werden.
//
// Agent Teams (Sub-Agents via Agent-Tool) sind GA seit Claude Code v2.1.111.
// Das Flag CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS ist obsolet.
