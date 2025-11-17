# Dockerfile

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

# Create the user first
RUN useradd --create-home appuser

# Copy the pre-compiled wheels from the builder stage
COPY --from=builder /wheels /wheels

# --- [CRUCIAL FIX] ---
# Switch to the non-root user BEFORE installing packages.
USER appuser
WORKDIR /home/appuser/app

# Install the wheels as the non-root user. The --user flag installs
# packages into the user's home directory (~/.local/), which they
# inherently have permission to read.
RUN pip install --no-cache-dir --user /wheels/*

# Add the PATH to the user's scripts
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Copy the application code as the non-root user
COPY --chown=appuser:appuser monitor_and_scan.py .

# The command to run the monitoring service
CMD ["python", "monitor_and_scan.py"]
