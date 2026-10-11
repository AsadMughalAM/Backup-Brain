# ARCHITECTURE.md — Backup Brain (AI Home Energy Manager for Load-Shedding & Backup Power)

> **Product name:** Backup Brain · **Platform:** Flutter app (Android first) + Firebase
> **Context:** Hackathon build. Target market: Pakistani households dealing with load-shedding.
> **Audience of this file:** The coding agent (and team) building the product. This file owns **what we build and why**: problems, features, formulas, data model, screens. When in doubt, follow the **Build Order** (Section 11) and the **Agent Rules** (Section 13).
> **Precedence:** technology, folders, Firestore layout and Cloud Functions → `TECH_STACK.md` wins. Colors, fonts, icons, component visuals → `DESIGN.md` wins. Start at `CLAUDE.md` for the doc map.

## Contents

1. [One-Line Positioning](#1-one-line-positioning) · 2. [The Problem](#2-the-problem) · 3. [Personas](#3-who-faces-these-problems-personas) · 4. [Feature Map](#4-solution-overview--feature-map) · 5. [Feature Specs F1–F10](#5-feature-specifications) · 6. [System Architecture](#6-system-architecture) · 7. [Tech Stack](#7-tech-stack) · 8. [Data Model](#8-data-model) · 9. [Server Interface](#9-server-interface) · 10. [Screens](#10-screens--ux) · 11. [Build Order](#11-build-order-for-the-agent) · 12. [Demo Script](#12-hackathon-demo-script-target-3-minutes) · 13. [Agent Rules](#13-agent-rules) · 14. [Open Questions](#14-assumptions--open-questions) · 15. [Success Metrics](#15-success-metrics)

---

## 1. One-Line Positioning

> **"An AI energy manager that tells your home exactly how long its backup will last, what to switch off, when solar will recharge the battery, what solar would cost you, and where to buy or repair a battery when it fails."**

We are **not** building "a load-shedding app". We are building an **energy decision layer** that turns raw numbers (battery %, load watts, weather) into simple household decisions **before, during, and after** every outage.

---

## 2. The Problem

### 2.1 Root problem

The real problem is not "the power goes out". It is **uncertainty and poor control**. Households do not know:

- when the outage will happen or how long it will last,
- how much backup energy they actually have,
- which appliances to prioritize,
- whether their battery is healthy,
- whether solar will recharge the battery before the next outage,
- whether installing solar is worth it, and what it would cost,
- where to get a good replacement battery or a trustworthy repair when the battery dies.

Backup power becomes guesswork → wasted money, early battery death, and avoidable blackouts inside the home.

### 2.2 Detailed problem list

| # | Problem | What happens in the house | Why it hurts |
|---|---|---|---|
| P1 | Unpredictable outages | Load-shedding starts early, runs long, or comes without notice; published schedules often don't match reality | Families can't plan cooking, work, sleep, water pumping, charging |
| P2 | Unknown backup time | User sees "60%" on the UPS, not "hours remaining" for their actual appliances | Fans stop, Wi-Fi drops, work is interrupted mid-task |
| P3 | Wrong appliance choices | Iron, water motor, washing machine, multiple fans left running | A few hundred extra watts cuts backup from hours to < 1 hour |
| P4 | Battery never fully recharges | Repeated cuts leave too little grid time to recharge | Backup gets shorter every day, worst in summer |
| P5 | Battery degradation | Deep discharges, overcharging, sitting at low voltage | Expensive tubular / lithium batteries die early |
| P6 | Solar doesn't match usage | Solar peaks at midday; demand peaks evening/night | Surplus by day, shortage after sunset |
| P7 | Weather & seasonal uncertainty | Clouds, smog, dust on panels, winter sun angle, heat | Users expect a full charge, get much less, run out at night |
| P8 | No visibility | Only an inverter display or a basic vendor app | No per-appliance view, no losses, no anomaly detection |
| P9 | High electricity cost | UPS recharges from grid; solar users still import at night | Backup reduces inconvenience but raises the bill |
| P10 | Solar purchase confusion | People want solar but don't know the size, cost, or payback | Over/under-sized systems, overpaying, or never deciding |
| P11 | Battery replacement & repair | When the battery goes bad ("kharab"), users don't know which battery to buy or where to repair it | Bad purchases, fake/low-quality batteries, overpriced repairs |
| P12 | Hardware fragmentation | Inverter, battery, panels, plugs from different brands | Automation is hard without technical expertise |
| P13 | Generator trade-offs | Fuel, noise, fumes, maintenance, manual start | Generators used only as last resort |

### 2.3 The deeper gap: no "energy decision layer"

Every home has three disconnected information sources:

```
 GRID ─────── uncertain timing, unstable supply
 SOLAR ────── weather-dependent, hard to predict locally
 BATTERY ──── only voltage / rough % / load visible
```

The user is forced to combine these in their head: *"Is the battery full? Will solar charge it tomorrow? Should I run the fridge? Will the next cut be long?"* Most people can't do this accurately. **Our app does this combination for them.**

---

## 3. Who Faces These Problems (Personas)

| Persona | Setup | Main pains | Most-used features |
|---|---|---|---|
| **A. UPS-only household** (most common) | Grid + UPS + 1–2 lead-acid/tubular batteries, no solar | P1, P2, P3, P4, P5, P11 | Backup countdown, load priority, battery health, battery buy/repair |
| **B. Hybrid solar household** | Panels + hybrid inverter + battery (lead-acid or lithium) + grid | P2, P4, P6, P7, P8, P9 | Solar recharge forecast, underperformance check, backup countdown |
| **C. Prospective solar buyer** | Currently grid/UPS, considering solar | P9, P10 | Solar cost & sizing estimator, payback calculator |
| **D. Battery-in-trouble user** | Any setup, battery already failing | P5, P11 | Health diagnosis, "repair or replace?" advice, battery search, repair-shop finder |
| **E. Small shop / home office** (secondary) | UPS or solar, business-critical loads | P2, P3, P9 | Backup countdown, load priority, cost savings |

Language: support **English** and **Roman Urdu** for AI explanations from day one (Urdu script is a later stretch goal).

---

## 4. Solution Overview — Feature Map

Features are derived from the team's notebook + R&D. Priority: **P0 = must ship for demo**, **P1 = should ship**, **P2 = stretch**.

| ID | Feature | Solves | Priority |
|---|---|---|---|
| F1 | **Backup Time Countdown** — "How long will my backup last right now?" (real-time battery hours) | P2, P3 | P0 |
| F2 | **Load Priority / "What should I turn off first?"** — ranked list with time gained per appliance | P3 | P0 |
| F3 | **Weather-based Solar Charge Forecast** — how much will solar charge my battery today/tomorrow | P6, P7, P4 | P0 |
| F4 | **Solar Underperformance Check** — "Is my solar system underperforming?" (built on top of F3) | P7, P8 | P1 |
| F5 | **Solar Cost & Sizing Estimator** — "Agar aap solar lagwana chah rahe hain to kya kharcha aa sakta hai?" | P10, P9 | P0 |
| F6 | **Battery Health Monitor** — degradation warnings in plain language | P5 | P1 |
| F7 | **Battery Marketplace & Repair Finder** — best batteries to buy when the battery is "kharab", plus nearby repair shops | P11 | P1 |
| F8 | **Outage Schedule & Recharge Readiness** — "Will my battery be ready before the next outage?" | P1, P4 | P1 |
| F9 | **AI Assistant (chat)** — ask anything in English / Roman Urdu; answers backed by the calculation engine | All | P0 (simple) |
| F10 | **Hardware Integration** (inverter cloud APIs, smart plugs, ESP32 sensors) | P8, P12 | P2 |

### Before / During / After value

- **Before outage:** "Power may go out at 7 PM. At current usage your battery lasts 2 h."
- **During outage:** "Turn off the fridge and one fan → backup goes from 2 h to 4 h."
- **After outage:** "Grid is back. Battery will be full by 4:30 PM using solar."
- **Long term:** "Your battery delivers 20% less than 3 months ago. Change these settings to extend its life." / "Battery is near end-of-life — here are 3 good replacements and 2 repair shops near you."

---

## 5. Feature Specifications

### F1 — Backup Time Countdown (P0)

**User question:** "How long will my backup last right now?"

**Inputs**
- Battery bank: chemistry (`lead_acid` | `tubular` | `lifepo4`), voltage (12/24/48 V), capacity (Ah), number of batteries, age (months)
- Current state of charge (SoC %) — manual entry, or from inverter later
- Current load (W) — computed from the list of appliances currently ON, or measured later
- Inverter/UPS efficiency (default 0.85 for UPS, 0.90 for hybrid inverters)
- Health factor from F6 (default 1.0)

**Formula (deterministic engine — never computed by the LLM)**

```
nominal_Wh     = voltage × Ah × battery_count
min_SoC        = 0.50 for lead_acid/tubular, 0.15 for lifepo4   (configurable)
usable_Wh      = nominal_Wh × health_factor × max(0, SoC_now − min_SoC)
backup_hours   = (usable_Wh × inverter_eff) / load_W
```

Optional refinement for lead-acid at high load (Peukert-style derate):
```
if chemistry in (lead_acid, tubular) and load_W > 0.2 × nominal_Wh:
    backup_hours *= 0.85
```

**Output example**
> "Approximately **3 h 28 min** left at current usage (420 W). Turning off the TV and the fridge extends this to **5 h 49 min**." (numbers from the demo household in §12)

**UI:** big countdown ring, current load, "stops protecting battery at X%" note, link to F2.

---

### F2 — Load Priority: "What should I turn off first?" (P0)

**Appliance model:** each appliance has `name`, `watts`, `quantity`, `priority` (`essential` | `comfort` | `avoid_on_backup`), `is_on`, and optional `duty_cycle` (e.g. fridge ≈ 0.4, since the compressor cycles).

**Default priority tiers (user-editable)**
- **Essential (keep):** router, LED lights, phone charging, medical devices, CCTV
- **Comfort (use carefully):** ceiling fans, TV, refrigerator, laptop
- **Avoid on backup:** iron, water motor, washing machine, AC, microwave, electric heater, kettle

**Algorithm**
1. Compute `effective_W = watts × quantity × duty_cycle` for every ON appliance.
2. Candidates to switch off = all ON appliances except `essential`.
3. Sort by `avoid_on_backup` first, then by `effective_W` descending.
4. For each candidate, compute **marginal time gained** = `backup_hours(load − candidate_W) − backup_hours(load)`.
5. Return a ranked list: *"Turn off Iron → +2 h 10 min"*, plus a cumulative "if you do the top 3" line.
6. If the user enters a **target duration** ("I need 4 hours"), find the smallest set of switch-offs that reaches it (greedy is fine for MVP).

**Overload warning:** if load exceeds the inverter's rated W, show a red warning immediately.

**Seed data:** ship `app/assets/data/appliances_pk.json` with typical wattages (ceiling fan 70–80 W, inverter fan 30–40 W, LED bulb 10–15 W, fridge 150–250 W, router 10–15 W, LED TV 60–100 W, iron 1000 W, water motor 750 W, 1.5-ton inverter AC 1200–1500 W). Users can edit values.

---

### F3 — Weather-based Solar Charge Forecast (P0)

**User question:** "Will solar charge my battery today/tomorrow?"

**Inputs**
- System: panel capacity (kWp), tilt, azimuth/orientation, location (lat/lon), shading level (none/partial/heavy), last cleaned date
- Battery state and night-time load profile (from F1/F2)

**Data source:** [Open-Meteo](https://open-meteo.com/) forecast API (free, no key) — hourly `shortwave_radiation` / `global_tilted_irradiance`, `cloud_cover`, `temperature_2m`. Cache per location for 1 hour.

**Formula (per hour h)**
```
PR (performance ratio) = 0.78 default
soiling_factor         = 1.00 if cleaned < 7 days, 0.95 < 30 days, 0.90 otherwise (configurable)
temp_derate            = 1 − 0.004 × max(0, cell_temp − 25)   ; cell_temp ≈ air_temp + 20
shading_factor         = 1.00 / 0.85 / 0.65
E_h (Wh) = kWp × 1000 × (irradiance_h / 1000) × PR × soiling × temp_derate × shading
```
Then simulate the battery hour by hour: solar energy first covers the daytime load, the surplus charges the battery (charge efficiency 0.90 for lithium, 0.80 for lead-acid), capped at 100%.

**Outputs**
- Expected generation today/tomorrow (kWh) vs. a clear-sky baseline → "% below normal"
- Expected battery SoC at sunset
- Night sufficiency: "Battery at sunset will cover your night load until ~2:30 AM"
- Advice example: *"Today's solar may be 35% below normal due to clouds and smog. Your battery may reach only 70% by evening — avoid heavy loads after 6 PM."*

---

### F4 — Solar Underperformance Check (P1, builds on F3)

**User question:** "Is my solar system underperforming?"

- User enters actual daily generation (from the inverter display/app) — later automated via F10.
- Compare with F3's **expected generation for the actual weather that day** (use Open-Meteo historical/archive data).
- `performance_index = actual_kWh / expected_kWh`
  - ≥ 0.90 → healthy
  - 0.75–0.90 → "slightly low — likely dust or partial shading; clean panels"
  - < 0.75 for 3+ clear days → "significantly underperforming — check wiring, inverter MPPT, or a faulty panel; consider a technician"
- Show a 7-/30-day trend chart.

---

### F5 — Solar Cost & Sizing Estimator (P0)

**User question:** "Agar mein solar lagwana chahun to kitna kharcha aayega?" (If I want to install solar, what will it cost?)

**Inputs:** monthly electricity units (kWh) or monthly bill (PKR), city, roof space (optional), main goal (`reduce_bill` | `backup_during_loadshedding` | `both`), desired backup hours at night, budget (optional).

**Sizing**
```
PSH (peak sun hours)  = from city lookup (Lahore ≈ 5.0–5.5 yearly average; store per city in config)
system_kWp            = monthly_kWh / (30 × PSH × PR)
panel_count           = ceil(system_kWp × 1000 / panel_watt)          ; panel_watt default 580 W
inverter_kW           = max(system_kWp, peak_load_kW × 1.25), rounded up to standard sizes (3/4/6/8/10/12 kW)
battery_Wh            = night_load_W × backup_hours / (usable_DoD × inverter_eff)
```

**Cost model:** all prices live in Firestore `config/pricing_pk` (bundled fallback `app/assets/data/pricing_pk.json`, seeded from `seed/pricing_pk.json`) (PKR per watt for panels, per-unit inverter prices by size, per-kWh battery prices by chemistry, structure/wiring/installation lump sums). **Prices change often — never hardcode them in code; display a "prices last updated: <date>" note and an "estimates only, get quotes from installers" disclaimer.** The team must fill in current market prices before the demo.

**Outputs**
- 3 packages: **Basic (bill saving, on-grid/no battery)**, **Hybrid (bill + backup)**, **Full backup** — each with size, component list, cost range (min–max), monthly savings, simple payback in years.
- Payback: `annual_savings = units_offset × tariff_per_unit × 12`; `payback_years = total_cost / annual_savings`. Tariff per unit and any net-metering/net-billing rate are **configurable** (government policy changes; do not assume).
- AI summary in plain language + "questions to ask your installer" checklist.

---

### F6 — Battery Health Monitor (P1)

**User question:** "Is my battery becoming unhealthy?"

Track every discharge session (manual "outage started/ended" taps for MVP; automatic later):
```
session: start_SoC, end_SoC, avg_load_W, duration_h, start_time, recharge_duration_h
delivered_Wh          = avg_load_W × duration_h / inverter_eff
estimated_capacity_Wh = delivered_Wh / (start_SoC − end_SoC)
health_factor         = rolling_median(estimated_capacity_Wh, last 10 sessions) / nominal_Wh
```

**Warning rules**
- health_factor dropped > 15% vs. first 30 days → capacity loss warning
- end_SoC below chemistry minimum on > 30% of sessions → "you are deep-discharging"
- recharge time trending up > 25% → "charging problem or ageing"
- lead-acid battery older than 18–24 months with health < 0.6 → suggest replacement → link to F7

**Output example:** *"Your battery is delivering about 18% less backup than 3 months ago. Avoid discharging below 50% and check that UPS charging is set to the correct battery type (tubular vs. dry)."*

---

### F7 — Battery Marketplace & Repair Finder (P1)

**User question:** "Meri battery kharab ho gayi — kaunsi nayi lun, ya repair ho sakti hai?" (My battery is dead — which one should I buy, or can it be repaired?)

**Flow**
1. **Diagnose first (repair vs. replace):** short questionnaire + F6 data (age, symptoms: swelling, backup in minutes, won't charge, water level for tubular, smell/heat). Rules engine returns `try_maintenance` | `repair_possible` | `replace`.
2. **Recommend batteries:** filter a catalog by user's inverter voltage, required Wh (from F1/F5), budget, chemistry preference. Rank by `cost_per_usable_kWh_per_year` (price ÷ (usable_kWh × expected_life_years)) — this shows why lithium can be cheaper long-term despite higher upfront cost.
3. **Find repair shops / dealers nearby:** map search (Google Places API or OpenStreetMap/Overpass) for "battery shop", "UPS repair", "solar installer" near the user.

**Data strategy (hackathon)**
- `seed/battery_catalog_pk.json` → Firestore `batteryCatalog/`: curated list — brand, model, chemistry, voltage, Ah, warranty months, cycle life, price range (PKR), `price_last_updated`.
- Optional: AI web-search refresh of prices (LLM with web search tool) — always show source + date.
- Never present prices as guaranteed. No affiliate ranking bias in MVP.

---

### F8 — Outage Schedule & Recharge Readiness (P1)

**User question:** "Will my battery be ready before the next outage?"

- No reliable official real-time API exists for most DISCOs (LESCO etc.) — so for MVP the user **enters their area schedule manually** and taps **"Light gayi" / "Light aa gayi"** (power went / came back) buttons.
- Log every real outage → learn the household's actual pattern (time-of-day histogram, average duration) → show a "likely next outage" prediction with confidence.
- Recharge forecast: `hours_to_full = (target_Wh − current_Wh) / (charger_W × charge_eff)` combined with F3 solar contribution.
- Alert: *"Next outage likely at 7 PM (based on your last 14 days). Battery will only be at 65% by then — avoid running the iron now."*
- Community/crowdsourced outage reports by area = P2 stretch.

---

### F9 — AI Assistant (P0, simple version)

- Chat interface in English and Roman Urdu.
- **Architecture rule: the LLM never invents numbers.** It only explains numbers produced by the Dart engine. Hackathon: the app sends an engine **snapshot** with each message. Later: client-executed tools (`get_backup_time`, `suggest_switch_offs`, `get_solar_forecast`, `estimate_solar_cost`, `get_battery_health`, `search_batteries`). See `TECH_STACK.md` §3.1.
- Also generates the short advice cards shown on the dashboard.
- System prompt includes the user's setup summary (household profile) so answers are personal.

---

### F10 — Hardware Integration (P2 / post-hackathon)

Adapter pattern so data sources are swappable:
```
DataSource interface → get_soc(), get_load_w(), get_solar_w(), get_grid_status()
  ├─ ManualSource      (MVP: user input)
  ├─ SimulatedSource   (demo mode: realistic fake data stream)
  ├─ InverterCloudSource (e.g. vendor cloud APIs where available)
  └─ LocalSensorSource (ESP32 + current/voltage sensors via MQTT)
```
Smart plug control (auto-shed "avoid_on_backup" loads) comes last and must require explicit user confirmation — safety first.

---

## 6. System Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│              FLUTTER APP (Android first, offline-first)              │
│  Onboarding │ Dashboard │ Load Planner │ Solar │ Battery │ Chat      │
└──────┬───────────────┬──────────────────┬───────────────┬────────────┘
       │               │                  │               │
┌──────▼──────┐ ┌──────▼───────┐ ┌────────▼───────┐ ┌─────▼──────────┐
│ CALCULATION │ │ FORECAST     │ │ AI LAYER       │ │ DATA SOURCES   │
│ ENGINE      │ │ Open-Meteo   │ │ Cloud Function │ │ (adapters)     │
│ pure Dart,  │ │ fetch+cache, │ │ → Claude API;  │ │ Manual /       │
│ on device:  │ │ solar model, │ │ explains engine│ │ Simulated /    │
│ backup,     │ │ outage       │ │ numbers in EN +│ │ Inverter /     │
│ loads,      │ │ pattern      │ │ Roman Urdu     │ │ Sensors        │
│ sizing,     │ │              │ │                │ │                │
│ health      │ │              │ │                │ │                │
└─────────────┘ └──────┬───────┘ └────────────────┘ └─────┬──────────┘
                       └─────────────┬────────────────────┘
                              ┌──────▼──────┐   ┌─────────────────────┐
                              │  FIRESTORE  │   │ BUNDLED ASSETS +    │
                              │ offline     │   │ FIRESTORE CONFIG    │
                              │ cache:users,│   │ appliances_pk.json  │
                              │ systems,    │   │ battery_catalog_pk  │
                              │ outages,logs│   │ pricing_pk.json     │
                              └─────────────┘   │ cities_psh.json     │
                                                └─────────────────────┘
External: Open-Meteo (weather/irradiance) · Claude API · Google Places API (F7)
```

Concrete wiring (repositories, callables, Firestore paths) lives in `TECH_STACK.md` §3–§4.

**Key design principles**
1. **Deterministic engine, AI explains.** All numbers come from tested pure functions. The LLM only orchestrates and explains.
2. **Software-first.** Everything works with manual input; hardware is an optional upgrade.
3. **Config over code** for prices, tariffs, PSH, wattages — they change.
4. **Demo mode** with simulated data so the hackathon demo never depends on live hardware.
5. **Honest uncertainty.** Every estimate shows a range or confidence, not false precision.

---

## 7. Tech Stack

**Final: Flutter + Firebase.** Flutter (Dart 3, Riverpod, go_router) for the app, a pure Dart `energy_engine` package for every calculation, Cloud Firestore (offline cache) for data, Cloud Functions (TypeScript) for the Claude and Google Places proxies, Open-Meteo for weather. Full details, packages and rules: **`TECH_STACK.md`**.

---

## 8. Data Model

Logical entities below; the Firestore paths that store them are in `TECH_STACK.md` §4.

```ts
User            { id, name, phone?, language: 'en'|'ur_Latn', city, lat, lon, createdAt }

System          { id, userId, hasSolar: bool,
                  inverter: { type: 'ups'|'hybrid'|'ongrid', ratedW, efficiency, chargerW },
                  battery:  { chemistry: 'lead_acid'|'tubular'|'lifepo4', voltage, ah, count,
                              ageMonths, minSoC },
                  solar?:   { kWp, panelW, panelCount, tiltDeg, azimuthDeg,
                              shading: 'none'|'partial'|'heavy', lastCleanedAt } }

Appliance       { id, systemId, name, watts, quantity, dutyCycle,
                  priority: 'essential'|'comfort'|'avoid_on_backup', isOn }

OutageEvent     { id, systemId, startedAt, endedAt?, source: 'manual'|'auto',
                  startSoC?, endSoC?, avgLoadW? }

SolarDailyLog   { id, systemId, date, actualKWh?, expectedKWh, performanceIndex? }

HealthSnapshot  { id, systemId, date, estimatedCapacityWh, healthFactor, warnings[] }

OutageSchedule  { id, systemId, dayOfWeek, startTime, endTime }   // user-entered

BatteryProduct  { id, brand, model, chemistry, voltage, ah, warrantyMonths, cycleLife,
                  priceMinPKR, priceMaxPKR, priceLastUpdated, source }
```

---

## 9. Server Interface

There is **no REST API**. Calculations (backup, switch-offs, solar forecast, sizing, health, diagnosis, outage prediction) run in the Dart engine on the phone. Profile, appliances, outages and logs are **direct Firestore reads/writes** guarded by security rules. Only two things need a server, both as callable Cloud Functions: `assistantChat` (F9) and `findNearbyShops` (F7). Full list: `TECH_STACK.md` §3.2.

---

## 10. Screens / UX

1. **Onboarding (≤ 2 min):** city → "Do you have solar?" → battery details (with photo-guide of the label) → pick appliances from presets.
2. **Dashboard:** big backup countdown ring; grid status toggle (Light gayi / aa gayi); today's solar forecast strip; top AI advice card; battery health badge.
3. **Load Planner:** appliance toggles with live-updating backup time; "What should I turn off?" ranked list; target-hours input.
4. **Solar:** forecast chart (hourly), expected SoC at sunset, performance check & trend.
5. **Solar Estimator:** form → 3 package cards → payback → installer checklist. Works for users with **no account setup** (great hackathon hook).
6. **Battery:** health trend, warnings, "My battery is kharab" button → diagnosis → recommendations → shops map.
7. **Chat:** assistant with suggested prompts ("Kitni der chalegi battery?", "Kal solar kitna charge karega?").

Mobile-first, large numbers, minimal text, Roman Urdu toggle.

---

## 11. Build Order (for the agent)

Product-level phases. The step-by-step technical order is `TECH_STACK.md` §9; engine files live in `packages/energy_engine/lib/src/`.

**Phase 0 — Skeleton (first)**
- Project setup, Firestore rules, seed JSON files (`appliances_pk.json`, `cities_psh.json`, `pricing_pk.json`, `battery_catalog_pk.json` with placeholder prices clearly marked `TODO: verify`).
- `SimulatedSource` + Demo Mode toggle.

**Phase 1 — Core engine + P0 features**
1. `backup_calculator.dart` (F1) + unit tests
2. `load_planner.dart` (F2) + unit tests
3. Onboarding + Dashboard + Load Planner screens
4. Open-Meteo source (cached) + `solar_model.dart` (F3) + Solar screen
5. `solar_sizing.dart` (F5) + Estimator screen
6. `assistantChat` Cloud Function with an engine snapshot (F9)

**Phase 2 — P1 features**
7. Outage logging + `battery_health.dart` (F6)
8. Performance check (F4)
9. Outage pattern prediction + readiness (F8)
10. Battery diagnose / recommend / shops (F7)

**Phase 3 — Polish & demo**
11. Roman Urdu strings, empty states, loading states, disclaimers
12. Scripted demo scenario using simulated data (see Section 12)

**Phase 4 — Post-hackathon (P2)**
- Inverter integrations, ESP32 sensors, smart-plug auto-shedding, crowdsourced outage map, Urdu script, push notifications.

---

## 12. Hackathon Demo Script (target ~3 minutes)

**Demo household** (the `SimulatedSource` fixture; every number below comes from the engine and is locked by a test in `packages/energy_engine/test/`):

- Battery: LiFePO4, 24 V × 150 Ah × 1 (3.6 kWh), SoC 60%, health 1.0. It must be lithium: with lead-acid at 60% only 10% of capacity is usable, so a realistic bank would show under 1 hour.
- Inverter: hybrid, rated 2000 W, efficiency 0.90.
- Appliances ON (420 W total): 2 × ceiling fan 75 W, fridge 200 W × duty 0.4, LED TV 90 W, laptop 40 W, router 10 W, 5 × LED bulb 10 W.

1. **Hook:** "Battery shows 60%. How long will it actually last?" → Dashboard shows **3 h 28 min**.
2. Toggle iron (1000 W) + water motor (750 W) on → 2170 W → countdown drops live → red overload warning (> 2000 W).
3. Turn them off again, tap "What should I turn off?" → ranked list (TV, fridge, fan…) → apply the top two → **5 h 49 min**.
4. Solar tab: "Tomorrow cloudy, 35% below normal, battery reaches 70% by sunset" — real Open-Meteo data for Lahore.
5. Estimator: neighbour without solar enters 400 units/month → 3 packages with cost and payback.
6. Battery tab: simulated ageing battery → "18% less capacity" → "kharab?" → diagnosis → 3 recommended batteries + nearby shops.
7. Chat in Roman Urdu: "Raat 2 baje tak fan chal sakta hai?" → assistant answers using engine numbers.

---

## 13. Agent Rules

- **Never let the LLM compute or guess numbers.** All numbers come from the engine; the LLM explains them.
- **Every engine function is pure and unit-tested** with at least: normal case, zero/edge load, low SoC below minimum, lithium vs. lead-acid.
- **No hardcoded prices, tariffs, or policy values in code** — read from Firestore `config/` (bundled JSON fallback) and show "last updated".
- **Always show ranges/uncertainty** for forecasts and cost estimates.
- **Safety:** no automated switching of appliances without explicit user confirmation; show overload warnings; for battery swelling/smell/heat, tell the user to disconnect and contact a technician.
- **Fail gracefully:** if Open-Meteo or the LLM is down, fall back to cached data / clear-sky estimates and template text.
- Keep the app usable **fully offline-ish for F1/F2** (pure client-side calculation is fine).
- Defaults must be sensible for Pakistan (230 V grid, PKR currency, local appliance wattages, local cities).

---

## 14. Assumptions & Open Questions

| Item | Current assumption | To decide / verify |
|---|---|---|
| Outage schedules | Manual entry + user logging | Any usable DISCO data source? |
| Prices (panels, inverters, batteries) | Placeholders in config | Team fills current market prices before demo |
| Tariff & net-metering/net-billing rates | Configurable values | Verify current policy |
| Battery SoC accuracy | User-entered % or voltage-based estimate | Add voltage→SoC lookup table per chemistry |
| Repair shop data | Maps API search | Curated verified list later? |
| Monetization | Not in MVP | Installer leads, battery dealer partnerships, premium monitoring |

---

## 15. Success Metrics

- Backup-time estimate within **±15%** of real outage duration (validated via logged sessions).
- Solar forecast within **±20%** of actual daily kWh on most days.
- User completes onboarding in **< 2 minutes**.
- At least one actionable recommendation shown on every dashboard visit.
- Demo runs end-to-end without any hardware.
