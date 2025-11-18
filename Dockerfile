# Dockerfile (Final Brute-Force Fix)

# --- Stage 1: The Builder ---
FROM python:3.9-slim-bullseye AS builder
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential python3-dev pkg-config libxml2-dev libxslt1-dev zlib1g-dev libjpeg62-turbo-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir --upgrade pip wheel
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt


# --- Stage 2: The Final Image ---
FROM python:3.9-slim-bullseye
RUN apt-get update \
    && apt-get install -y --no-install-recommends libxml2 libxslt1.1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the user
RUN useradd --create-home appuser

# Copy the pre-compiled wheels
COPY --from=builder /wheels /wheels

# Switch to the non-root user
USER appuser
WORKDIR /home/appuser/app

# Install the wheels as the non-root user into the user's home directory
RUN pip install --no-cache-dir --user /wheels/*

# --- [THE DEFINITIVE FIX] ---
# Forcefully tell the Python interpreter where the packages were just installed.
# This explicitly adds the user's local package directory to Python's import path.
ENV PYTHONPATH="/home/appuser/.local/lib/python3.9/site-packages"

# Also add the user's local bin directory to the main PATH
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Copy the application code as the non-root user
COPY --chown=appuser:appuser monitor_and_scan.py .

# The command to run the monitoring service
CMD ["python", "monitor_and_scan.py"]
