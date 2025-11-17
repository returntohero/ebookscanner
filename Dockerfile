# Dockerfile
FROM python:3.9-slim-bullseye

# Set an environment variable to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    pkg-config \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg62-turbo-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- [CRUCIAL FIX] ---
# First, upgrade pip, setuptools, and wheel. An outdated pip is a
# very common cause for build failures with modern packages.
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Now, copy and install the pinned dependencies.
# This step is much more reliable with an upgraded pip.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY monitor_and_scan.py .

# The command to run the monitoring service
CMD ["python", "monitor_and_scan.py"]
