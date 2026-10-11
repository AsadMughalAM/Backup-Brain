# 0001 — No code generation (yet)

**Date:** 2026-10-11 · **Status:** Accepted, revisit when models grow

## Context

TECH_STACK.md §2.2 lists `riverpod_generator`, `freezed` and `json_serializable`, all driven by `build_runner`. The first app slice (dashboard, load planner, demo household) has two small Firestore models and a handful of providers.

## Decision

Write Riverpod providers by hand (`Provider`, `StreamProvider`, `NotifierProvider`) and map Firestore documents with small hand-written DTOs (`SystemDto`, `ApplianceDto`). No `build_runner` step.

## Why

- One less tool and step for every teammate; nothing to regenerate after a pull.
- No version-compatibility risk between generators and Riverpod 3 / Dart 3.13 during the hackathon.
- The DTOs are covered by round-trip tests (`app/test/features/dto_test.dart`), which is what generated code would give us.

## Revisit when

Models get nested or numerous (outages, solar logs, health snapshots, chat). Switching later is mechanical: providers keep their names, and DTO maps become `fromJson`/`toJson`.
