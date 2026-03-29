# LiveMLB Score App

A real-time MLB score and statistics web app built with Flask. All data is sourced from the free [MLB Stats API](https://statsapi.mlb.com) — no API key required.

![Python](https://img.shields.io/badge/Python-3.10%2B-blue)
![Flask](https://img.shields.io/badge/Flask-3.0-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Features

- **Live Score Dashboard** — Auto-refreshing game cards with inning-by-inning linescores, runs/hits/errors, base runner diamond, outs, and live ball-strike count
- **Ticker View** — Compact text summary of every game on the selected date
- **Game Lineups** — Full batting orders with positions, batting averages, and Baseball Savant links; current batter highlighted
- **Home Run Event Log** — Every home run hit in a game with batter, team, inning, and play description
- **At-Bat Feed** — Live play-by-play across all active games or drill into a single game
- **MLB Standings** — AL/NL division standings with W/L/PCT/GB/Streak/Last 10
- **League Leaders** — Season-to-date hitting and pitching leaders across 11+ statistical categories; results cached locally by date
- **Smart Polling** — Refreshes every 10 seconds during live games, drops to once per hour when no games are active
- **Alert Inbox** — Notifications for home runs (🔔), no-hitter bids, and close games, deduplicated across refreshes
- **Watchlist** — Track specific teams or players; separate watchlist alert feed with 👁 badge
- **ABS Challenge Detection** — Flags Automated Ball-Strike challenge events in the ⚡ inbox
- **Spoiler Mode** — "Hide Scores" toggle for catching up on games later
- **Density Presets** — Switch between Compact, Default, and Large card layouts
- **Favorites** — Star teams to keep them at the top
- **Sound Alerts** — Audio notification on home run events
- **Persistent Preferences** — All settings (favorites, watchlist, density, spoiler mode, seen alerts) saved to `localStorage`

---

## Getting Started

### Prerequisites

- Python 3.10 or higher
- `pip`

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/LiveMLB_Score_app.git
   cd LiveMLB_Score_app
   ```

2. **Create and activate a virtual environment** (recommended)

   ```bash
   python -m venv venv

   # Windows
   venv\Scripts\activate

   # macOS / Linux
   source venv/bin/activate
   ```

3. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

### Running Locally

```bash
python app.py
```

The app starts at [http://127.0.0.1:5000](http://127.0.0.1:5000).

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `SECRET_KEY` | `score-app-prod-secret-change-me` | Flask session secret — **change this in production** |
| `DEBUG` | `False` | Enable Flask debug mode |

Set these in your shell or a `.env` file before running.

### Production (Gunicorn)

```bash
gunicorn app:app
```

The app is configured for deployment on [Render](https://render.com). Add the environment variables in the Render dashboard under your service's **Environment** settings.

---

## How to Use

### Score Dashboard

The main view loads today's games automatically (US Eastern Time). Use the **date picker** in the toolbar to browse any date.

Each game card shows:
- Team logos, names, and current score
- Inning-by-inning linescore
- Base runner positions and outs indicator
- Live count (balls/strikes) and pitch count
- Current batter and pitcher names
- Decision pitchers (W/L/S) with color-coded badges
- Links to MLB.com game page and team rosters

### Alerts

Three inbox buttons appear in the toolbar with live badge counts:

| Button | What it tracks |
|---|---|
| 🔔 Alerts | Home runs, no-hitter bids through 6+ innings, close games (1 run, 7th inning+) |
| 👁 Watchlist Feed | Any alert involving a team or player on your watchlist |
| ⚡ ABS Challenges | Automated Ball-Strike challenge events |

Click any button to open the slide-out alert panel.

### Watchlist

Open the **Watchlist** drawer from the toolbar to add team abbreviations (e.g. `NYY`, `LAD`) or player names. The app checks every refresh and fires a watchlist alert whenever a tracked team or player appears in a scoring event.

### Lineups

Click the **Lineup** button on any game card to open a modal showing both batting orders — position, batting average, game stats, and a link to each player's Baseball Savant page. The current batter is highlighted in real time.

### At-Bat Feed

Click the **At-Bats** button on a game card to see the recent play-by-play for that game, including scoring plays and ABS challenge flags.

### Standings

Click **Standings** in the toolbar to view AL and NL division standings. Switch between leagues with the tab toggle.

### League Leaders

Click **Leaders** in the toolbar to browse season-to-date statistical leaders. Toggle between **Hitting** and **Pitching**, then select a category from the pill tabs:

- **Hitting:** HR, AVG, Hits, 2B, 3B, SB, OBP, OPS, RBI, Runs, BB
- **Pitching:** Wins, ERA, Strikeouts, Saves, IP, WHIP, K/9, BAA

Leader data is cached locally (in `data/leaders_daily_cache.json`) and refreshes once per day. Use the **Refresh** button inside the leaders panel to force a rebuild.

---

## API Endpoints

The app exposes a REST API consumed by the frontend. You can call these directly for your own tooling.

| Method | Endpoint | Query Params | Description |
|---|---|---|---|
| `GET` | `/api/scores/dashboard` | `date` (YYYY-MM-DD) | Full game data for all games on a date |
| `GET` | `/api/scores/ticker` | `date` (YYYY-MM-DD) | Compact game list for ticker display |
| `GET` | `/api/scores/standings` | — | AL/NL division standings |
| `GET` | `/api/scores/lineups/<game_pk>` | — | Batting orders for a specific game |
| `GET` | `/api/scores/events/home-runs/<game_pk>` | — | All home run events for a game |
| `GET` | `/api/scores/at-bats` | `date`, `limit` (default 80) | Aggregated at-bat feed across all live games |
| `GET` | `/api/scores/at-bats/<game_pk>` | `limit` (default 40) | At-bat feed for a single game |
| `GET` | `/api/scores/leaders` | `stat_group` (hitting/pitching), `stat_type`, `date`, `limit`, `refresh` | Season statistical leaders |

All responses return JSON with a `success` boolean. On failure, the dashboard and ticker endpoints serve the last successfully cached response rather than an error.

---

## Project Structure

```
LiveMLB_Score_app/
├── app.py              # Flask routes
├── config.py           # App configuration and directory setup
├── requirements.txt
├── modules/
│   ├── scores.py       # All MLB Stats API calls and data processing
│   └── logger.py       # Rotating file logger (logs/app.log)
├── templates/
│   ├── base.html       # Base layout with nav
│   ├── scores.html     # Main dashboard template + all inline JS
│   └── error.html      # 404/500 error page
├── static/
│   ├── css/style_guide.css
│   ├── images/         # MLB team logos
│   └── sounds/         # Home run audio alert
└── data/               # Runtime cache (leaders_daily_cache.json)
```

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

> **Disclaimer:** This app uses the public MLB Stats API for personal and educational use. All MLB data, logos, and trademarks are the property of Major League Baseball.
