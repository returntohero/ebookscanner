# Dockerfile (Final "Install as Root, Read as User" Strategy)

# --- Stage 1: The Builder ---
# This stage is working correctly and does not need changes.
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

WORKDIR /app

# Copy the pre-compiled wheels. We are still root at this point.
COPY --from=builder /wheels /wheels

# Install the wheels system-wide as the root user.
RUN pip install --no-cache-dir /wheels/*

# --- [THE DEFINITIVE FIX] ---
# After installing as root, we forcefully make the package directories
# readable and traversable by ANY user who runs the container.
RUN chmod -R a+rX /usr/local/lib/python3.9/site-packages

# Now, create and switch to the non-root user.
RUN useradd --create-home appuser
COPY --chown=appuser:appuser monitor_and_scan.py .
USER appuser

# The command to run the monitoring service. This user will now be able
# to read the packages installed by root.
CMD ["python", "monitor_and_scan.py"]
