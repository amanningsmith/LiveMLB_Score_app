import sys

bind = "0.0.0.0:10000"
workers = 2
threads = 2
timeout = 120
limit_request_field_size = 16384
limit_request_fields = 200

# This will print to logs so you know config is loaded
def on_starting(server):
    print("=" * 50)
    print("GUNICORN CONFIG LOADED")
    print(f"Request field size limit: {limit_request_field_size}")
    print(f"Request fields limit: {limit_request_fields}")
    print("=" * 50)
    sys.stdout.flush()
