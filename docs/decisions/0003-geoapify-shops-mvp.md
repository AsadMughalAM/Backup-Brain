# 0003 — Geoapify for nearby shops (F7) in the MVP

**Date:** 2026-10-12 · **Status:** Accepted for the MVP only; revisit before a public release

## Context

F7 "Find help nearby" opened a Google Maps search link: free, but the user leaves the app and sees nothing in it. The spec's plan (`findNearbyShops`, Google Places through a Cloud Function) needs Blaze and a billing card, which the team is not taking for the MVP.

Options checked in October 2026:

| Source | Free amount | Card | Pakistan coverage |
|---|---|---|---|
| Google Places (New) | 5,000 Pro calls a month | Yes | Best |
| **Geoapify Places** | **3,000 credits a day** (20 places = 1 credit) | **No** | OpenStreetMap: real shops, loosely tagged |
| Foursquare Places | 500 calls a month | No | Weak |
| Public Overpass | Free, no key | No | Same data; public servers timed out in testing |

## Decision

The app calls the Geoapify Places API directly (`GeoapifyShopsRepository`) with `GEOAPIFY_API_KEY` from the same git-ignored `env.json` as the Gemini key ([0002](0002-gemini-key-in-app-mvp.md)). Results show inside the battery help screen as soon as it opens; each shop has a one-tap Google Maps **Directions** button. Without a key, or with no home location, the screen keeps the Google Maps search buttons.

Battery and solar shops in Pakistan are tagged loosely on OpenStreetMap (generic shop, car repair, electronics), so a category search finds almost none of them. The repository searches shop **names** instead (Geoapify's `name` filter, any part of the name) with one word per request (`batt`; `ups`, `inverter`, `stabili`; `solar`), then keeps a shop only when the word really fits ("ups" must be a whole word, so "Groups" is dropped) and drops duplicates.

**Setup's area lookup.** "Use my location" in setup names the phone's point with Geoapify **reverse geocoding** (`GeoapifyPlaceNames`, one credit per tap) on the same key: city, area (suburb / district / neighbourhood) and country. Without a key or a connection, the point alone picks the nearest listed city and the area stays for the user to type.

**Area first.** When the home has an area ("Johar Town"), its point is looked up with Geoapify geocoding *inside the home city* (30 km around the city's point; "Johar Town" alone first finds the one in Multan) and shops are searched around it, up to 40 km out, nearest first.

**At least 4–5 results where the map is thin.** Exact matches come first (battery shops for "Battery shops"); related dealers fill the rest of the 8 places (solar, UPS and inverter shops in Pakistan also sell and repair batteries). The related search runs at the same time and is only waited for when exact matches don't fill the list. One slow word doesn't fail the search; only all of them failing does.

Live check, 12 October 2026:

| Area | Battery shops | UPS repair | Solar | Time |
|---|---|---|---|---|
| Johar Town, Lahore | 5 (1 battery shop at 12.3 km, then solar dealers from 2.7 km) | 5 | 4 | ~5 s |
| Gulberg, Lahore | 5 (Malik Battery Agency 4.8 km first) | 5 | 4 | 4–7 s |
| Gulshan-e-Iqbal, Karachi | 8 battery shops, 1.1–3.6 km | 8 | 8 | 2.5–9 s |

Coverage follows what people have mapped: dense in Karachi, thin in Lahore, where only one shop with "battery" in its name is mapped within 40 km of Johar Town. "More on Google Maps" searches "battery shop Johar Town Lahore" for the rest.

## Risks and how they are contained

- **The key is inside every build** and can be extracted. A Geoapify free key has no billing attached, so the worst case is someone using up the day's 3,000 credits; the screen then shows "Couldn't load shops" and the Google Maps button still works.
- One search costs 1 credit per word (20 places each): 4 for battery shops, 5 for UPS repair, 2 for solar, plus 1 per area lookup (remembered for the session). Results are cached per kind and place for the app session.
- The free plan allows limited commercial use only.
- Rotate the key if it leaks.

## Revisit when

Before a public release, or if coverage is too thin: move the search behind `findNearbyShops` (Cloud Function, key in Secret Manager) on Blaze, with Google Places or a paid Geoapify plan.
