# Dockerfile
FROM python:3.9-slim-bullseye

# Set an environment variable to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# --- [IMPROVED] Install a comprehensive set of system dependencies ---
# This includes build tools, Python headers, and common libraries
# needed by packages like lxml (used by ebooklib).
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

# --- [IMPROVED] Optimize Docker Caching ---
# First, copy only the requirements file and install dependencies.
# This layer will only be re-built if requirements.txt changes.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Now, copy the rest of the application code.
COPY monitor_and_scan.py .

# The command to run the monitoring service
CMD ["python", "monitor_and_scan.py"]
