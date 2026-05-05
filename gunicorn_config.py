import sys

bind = "0.0.0.0:10000"
workers = 2
threads = 2
timeout = 120
limit_request_field_size = 65536  # 64KB per-field (default is 8190)
limit_request_fields = 500  # Maximum total fields in a request (default is 100)

# This will print to logs so you know config is loaded
def on_starting(server):
    print("=" * 50)
    print("GUNICORN CONFIG LOADED")
    print(f"Request field size limit: {limit_request_field_size}")
    print(f"Request fields limit: {limit_request_fields}")
    print("=" * 50)
    sys.stdout.flush()
