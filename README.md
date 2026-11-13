# Cascade Tribunal · The Hormuz Crisis

**Play it: https://cascade-tribunal.vercel.app**

A short, historically grounded strategy game. On 28 February 2026 the Strait of Hormuz begins to close, and with it the sea lane that carries about 90% of India's imported cooking gas. You take six decisions over seven months: what to prepare, who gets the cooking gas that is left, whether to pay for emergency cargo, whether to ration fuel, whether to change course, and one last move. Two or three unexpected developments hit along the way.

You play against **the Computer**. At the end you find out who it was: a reconstruction of what the Government of India actually did, built from its own press briefings and the oil ministry's planning cell, and played through the same engine as you.

The game runs entirely in your browser. There is no server, no account, no AI service and no network request after the page loads.

## How to play
1. **Read the stakes.** Three sourced numbers on an India-first map explain the danger. Click one to see its source.
2. **Decide.** Each decision takes over the screen. Every option shows what it protects, what it gives up, when it takes effect, and a table of what the engine says it changes, calculated from two full runs with and without it.
3. **Watch.** Routes thin, turn amber (delayed) or red (lost); reserves drain; kitchens, workshops, transport and power plants go short or recover. Pause, change speed, or drag the timeline back to look at earlier days (looking back never changes a decision).
4. **React.** Crisis events are hypothetical, clearly labelled, and change the model's inputs. Both you and the Computer face them.
5. **Face the reckoning.** You get a strategic identity read from your decisions, three separate measures against the Computer (shortage, extra cost, cover), a decision journal, the reveal, and two one-click replays with one decision changed.

Add `?seed=12345` to the address to play a particular crisis again.

## What is real, what is modelled, what is invented
| Label in the game | Meaning |
|---|---|
| **Recorded** | Quoted word for word from a published source, dated by the day the source gives. A test checks every quote against `data/evidence/`. |
| **Model** | Calculated by the deterministic engine. Same inputs, same outputs. |
| **Inferred** | A date or link read from documented facts but not stated in a source. |
| **Hypothetical** | Crisis events invented for play. Labelled wherever they appear. |
| **Your run** | The model with your decisions applied from the day you took them. |

The Government reconstruction (`data/game/hormuz_2026.json`) follows the official record: households first; commercial and industrial cooking gas cut back on 8 March 2026 and restored to 20%, 50% (21 March) and 70% (27 March); refinery cooking-gas output up 25%, 31% and 40% (11, 14 and 18 March); crude re-sourced from about 40 countries by 11 March. Where the record shows no action of a kind, the Computer takes none. Claims from secondary research that no official source confirms are listed in Model details and kept out of the game.

**The model and the record disagree, and the game says so.** In the model, the Government's India leaves households about a third short of cooking gas in May 2026. The planning cell measured household consumption that month 19.3% below May 2025. Likely reasons, all shown in the game: the model keeps the strait closed to all cargo while some Indian-flag carriers crossed; its emergency contracts are smaller and slower than the volumes officials reported; and measured consumption also fell because of booking limits and fuel switching. The model was not adjusted to close the gap.

## How it is built
```
web/src/engine/engine.ts   the engine the game runs (TypeScript, in the browser)
cascade/engine.py          the reference engine (Python); both must agree: tests/test_parity.py
web/src/game/              the game: model.ts rules, Game.tsx screens, Atlas.tsx map, game.css
data/network.json          India's trade network: commodities, suppliers, chokepoints; every number has a provenance class
data/evidence/             sourced facts with verbatim quotes
data/game/                 the recorded timeline, the Government reconstruction, the hypothetical event deck
data/geo/india_states.json India's states and union territories (DataMeet, CC BY 4.0)
```
- **Engine:** a daily supply balance for India over about 290 days: cargo dispatched, lost, delayed or rerouted at each chokepoint; arrivals; reserves; unmet demand; prices and costs. Decisions change engine inputs from the day they are taken and never change an earlier day. Method: `docs/SIMULATION_METHODOLOGY.md`.
- **Parity:** the Python reference and the browser engine are compared over 706 requests (672 runs, 34 invalid requests both must reject). Day and count values must match exactly; other numbers to a relative 1e-9 (observed worst: 1.8e-16). `docs/PARITY.md`.
- **Events:** two or three per game from a deck of ten, by a seeded draw. Never within 12 days after a decision, at most one between two decisions, at least 20 days apart, both helpful and harmful.
- **Identities:** your most defining departure from the Computer names your run; the next one, or your result, gives the second line. Every identity is reachable and none covers more than 25% of the 648 possible decision paths (tested).
- **The Tribunal:** four short verdicts at the end were written in advance by an AI model and are chosen by fixed rules. No AI runs when you play.

Stack: React 19, TypeScript, Vite, d3-geo; Python 3.13 with pydantic for the reference engine and tests. System fonts only; map shapes are bundled.

## Run it yourself
```
cd web && npm ci && npm run build && npm run preview     # the game at http://localhost:4173
```
Tests (Python 3.13 and Node.js 22.6+):
```
python -m venv .venv && .venv\Scripts\pip install -r requirements.txt
.venv\Scripts\python -m pytest -q
```
The suite plays all 648 decision paths, every crisis event on its earliest and latest day, 4,000 event draws, and the full parity matrix.

The repository also holds the **analyst workbench** the game grew out of: six rooms (scenarios, cascade, a rule-based tribunal, decisions, evidence, validation) on the Python engine, run locally with `start.bat` at `http://localhost:8000/analyst.html`. It is not part of the public site. `docs/LOCAL_SETUP.md`.

## Limitations
- Most of the roughly 320 model inputs are unverified assumptions; `docs/KNOWN_LIMITATIONS.md` lists them. Results are scenario arithmetic, not forecasts.
- The model's oil price rise (+52%) is well below the recorded +80–97%, so costs are understated.
- Cooking gas has two users in the model (households, and everyone else); there is no state-level data, no diesel or petrol balance, no other importing countries.
- Booking limits, the diesel and jet-fuel export levy, the excise cut, diplomacy and naval protection are recorded in the game but not modelled.
- Sea lanes and landing points on the map are schematic.
- No first-time players have been observed playing it yet.

## Sources
Official: Press Information Bureau briefings (Ministry of Petroleum and Natural Gas, Ministry of Ports, Shipping and Waterways, Ministry of External Affairs), Petroleum Planning and Analysis Cell. International: IMF World Economic Outlook (October 2026), WTO Global Trade Outlook (October 2026), World Bank, UNCTAD, US EIA. Every quote and page reference is in `data/evidence/` and in the game's Model details.

## Licence
No licence has been chosen yet. Until one is, all rights are reserved by the author. Map boundaries: DataMeet India community, CC BY 4.0. Country shapes: Natural Earth, public domain.
