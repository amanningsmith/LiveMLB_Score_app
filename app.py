"""Standalone Scores Flask app for Render deployment."""

from flask import Flask, jsonify, render_template, request

from config import DEBUG, SECRET_KEY
from modules.logger import logger
from modules import scores

app = Flask(__name__)
app.config['SECRET_KEY'] = SECRET_KEY
app.config['DEBUG'] = DEBUG


@app.route('/')
def home():
    return render_template('scores.html', default_date=scores.get_et_today_date_str())


@app.route('/scores')
def scores_dashboard():
    return render_template('scores.html', default_date=scores.get_et_today_date_str())

@app.before_request
def log_request_info():
    total_size = sum(len(k) + len(v) for k, v in request.headers.items())
    app.logger.info(f"Total header size: {total_size} bytes")
    if total_size > 8000:
        for key, value in request.headers.items():
            app.logger.info(f"{key}: {len(value)} bytes")

@app.route('/api/scores/ticker', methods=['GET'])
def scores_ticker_api():
    try:
        date_str = request.args.get('date', '').strip() or None
        payload = scores.get_ticker_payload(date_str=date_str)
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores ticker API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'games': []}), 500


@app.route('/api/scores/dashboard', methods=['GET'])
def scores_dashboard_api():
    try:
        date_str = request.args.get('date', '').strip() or None
        payload = scores.get_dashboard_payload(date_str=date_str)
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores dashboard API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'games': []}), 500


@app.route('/api/scores/standings', methods=['GET'])
def scores_standings_api():
    try:
        payload = scores.get_standings_payload()
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores standings API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'standings': None}), 500


@app.route('/api/scores/lineups/<int:game_pk>', methods=['GET'])
def scores_lineups_api(game_pk):
    try:
        payload = scores.get_game_lineups_payload(game_pk)
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores lineups API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'game_pk': game_pk}), 500


@app.route('/api/scores/events/home-runs/<int:game_pk>', methods=['GET'])
def scores_home_run_events_api(game_pk):
    try:
        payload = scores.get_game_home_run_events_payload(game_pk)
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores home run events API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'game_pk': game_pk, 'events': []}), 500


@app.route('/api/scores/at-bats', methods=['GET'])
def scores_at_bats_api():
    try:
        date_str = request.args.get('date', '').strip() or None
        limit = int(request.args.get('limit', 80))
        payload = scores.get_at_bat_feed_payload(date_str=date_str, limit=limit)
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores at-bats API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'entries': []}), 500


@app.route('/api/scores/at-bats/<int:game_pk>', methods=['GET'])
def scores_game_at_bats_api(game_pk):
    try:
        limit = int(request.args.get('limit', 40))
        payload = scores.get_game_at_bat_feed_payload(game_pk=game_pk, limit=limit)
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores game at-bats API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'game_pk': game_pk, 'entries': []}), 500


@app.route('/api/scores/leaders', methods=['GET'])
def scores_leaders_api():
    try:
        stat_group = (request.args.get('stat_group', 'hitting') or 'hitting').strip().lower()
        stat_type = (request.args.get('stat_type', '') or '').strip() or None
        date_str = (request.args.get('date', '') or '').strip() or None
        refresh_value = (request.args.get('refresh', 'false') or '').strip().lower()
        force_refresh = refresh_value in {'1', 'true', 'yes'}
        limit = int(request.args.get('limit', 15))
        payload = scores.get_leaders_payload(
            stat_group=stat_group,
            stat_type=stat_type,
            limit=limit,
            date_str=date_str,
            force_refresh=force_refresh,
        )
        status_code = 200 if payload.get('success') else 502
        return jsonify(payload), status_code
    except Exception as exc:
        logger.error(f'Scores leaders API error: {exc}')
        return jsonify({'success': False, 'error': str(exc), 'leaders': []}), 500


@app.errorhandler(404)
def not_found(_error):
    return render_template('error.html', error='Page not found'), 404


@app.errorhandler(500)
def internal_error(_error):
    return render_template('error.html', error='Internal server error'), 500


if __name__ == '__main__':
    logger.info('Starting Score_app')
    app.run(debug=DEBUG, host='127.0.0.1', port=5000)
