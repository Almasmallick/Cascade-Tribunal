# Cascade Tribunal — engineering instructions

India-centred trade-crisis simulation game. A deterministic engine calculates every number. The public site is a static game that runs the engine in the browser; the Python engine is the reference and powers the local analyst workbench.
Read `docs/DEVELOPMENT_LOG.md` first for current state, then `docs/DECISIONS.md` before changing any design choice.

## Rules that do not bend
1. **The engine calculates every number.** No LLM output may introduce a quantitative result. Agents cite ledger ids; `agents.audit_text` rejects numbers that are not in the cited evidence.
2. **Every input has a provenance class.** A bare number in `data/network.json` is class C (unverified). Promote to A only through `scripts/promote_verified_facts.py`, pointing at a fact in `data/evidence/verified_facts.json` that carries a source and a quote.
3. **Same inputs, same outputs.** No randomness, no clocks, no network calls inside `cascade/engine.py`.
4. **Never fake agent output.** With no model backend the AI run returns 503; the Tribunal shows the deterministic analysis, labelled as rules, not AI.
5. **Do not tune the model to pass historical checks.** A miss in `/api/historical` is information. Fix a check only when it misstates the evidence.
6. **Do not touch anything outside this folder.** Sibling folders on the author's machine (another project and a private research library) are read-only.
8. **Two engines, one model.** `cascade/engine.py` is the reference; `web/src/engine/engine.ts` is what the public plays. Change them together and keep `tests/test_parity.py` green (`docs/PARITY.md`). Never loosen its tolerances to pass.
9. **The public site makes no network requests.** No API, fonts, tiles or images from elsewhere; `vercel.json` sets `connect-src 'none'`.
11. **Hypothetical is labelled.** Crisis events in `data/game/crisis_events.json` are invented for play and say so wherever they appear. The Computer is the Government of India reconstruction and acts only where `data/game/hormuz_2026.json` cites a documented action; `tests/test_game.py` enforces both.
10. **Recorded, model, your run.** Every recorded event in `data/game/` carries a verbatim quote from `data/evidence/` (`tests/test_game.py`). Never present a model output as a historical record.
7. **Local first.** `CASCADE_LLM` defaults to `off`. Nothing may switch a paid or external service on by itself, and the app must keep working with no network.

## Commands (run from the project root)
```
start.bat / stop.bat                                           # one-click local start and stop (setup.bat once)
.venv\Scripts\python -m pytest -q                              # 70 tests incl. engine parity and the game-rules suite (needs Node 22.6+), must stay green
.venv\Scripts\python -m cascade hormuz_closure stockpile       # command-line simulation
.venv\Scripts\python -m uvicorn cascade.api:app --port 8000    # API + built interface at http://localhost:8000
cd web && npm run build                                        # type-check and rebuild the interface
vercel deploy --prod                                           # public site https://cascade-tribunal.vercel.app (static game only, no API)
cd web && npm run dev                                          # interface with hot reload on :5173 (needs the API running)
```

## Layout
- `cascade/engine.py` simulation · `interventions.py` user decisions · `decision.py` strategy comparison and diff
- `cascade/agents.py` AI tribunal, ledger, number audit, model backends · `local_intel.py` deterministic tribunal · `historical.py` replay harness · `api.py` + `intel_api.py` HTTP routes
- `data/network.json` the trade network · `data/evidence/` sourced research · `data/historical_replays.json` replay cases
- `web/src/engine/engine.ts` browser engine · `web/src/game/` the game (`model.ts` rules, identities and decisions, `Atlas.tsx` India-first map, `Game.tsx` screens, `game.css` tokens) · `data/game/` recorded events, the Computer's documented basis, and the hypothetical crisis-event deck · `data/geo/india_states.json` state boundaries (built by `scripts/build_india_map.py`)
- `web/src/analyst/` the six-room analyst workbench, served locally at `/analyst.html` (needs the API; not in the public build) · `tests/` · `docs/`

## Conventions
- Python 3.13, pydantic models at every boundary, 160-column lines. TypeScript strict.
- New engine logic needs a test in `tests/test_engine.py` with a hand-calculated expectation.
- Update `docs/DEVELOPMENT_LOG.md` at the end of each working session.
