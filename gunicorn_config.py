# gunicorn_config.py
bind = "0.0.0.0:10000"
workers = 2
threads = 2
timeout = 120
limit_request_field_size = 16384  # Fix for header size error
limit_request_fields = 200
