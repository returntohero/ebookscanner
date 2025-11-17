# Dockerfile
FROM python:3.9-slim

# --- [NEW] Install system dependencies and build tools ---
# This is the crucial step. It installs the C compiler, Python development headers,
# and other libraries needed to build some of the Python packages from source.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
# This pip install command will now succeed because the build tools are present.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application script
COPY monitor_and_scan.py .

# The command to run the monitoring service
CMD ["python", "monitor_and_scan.py"]
