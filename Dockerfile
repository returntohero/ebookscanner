# Dockerfile

# --- Stage 1: The Builder ---
# This stage installs all build dependencies and compiles our Python packages.
FROM python:3.9-slim-bullseye AS builder

# Set an environment variable to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install only the build-time system dependencies
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

# Upgrade pip and install wheel
RUN pip install --no-cache-dir --upgrade pip wheel

# Copy requirements and build the wheels.
# This compiles all packages and stores them in /wheels for later.
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt


# --- Stage 2: The Final Image ---
# This is the small, clean image that will actually be published.
FROM python:3.9-slim-bullseye

# Install only the RUNTIME system dependencies. These are much smaller
# than the -dev packages from the builder stage.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libxml2 \
    libxslt1.1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for better security
RUN useradd --create-home appuser
USER appuser
WORKDIR /home/appuser/app

# Copy the pre-compiled wheels from the builder stage
COPY --from=builder /wheels /wheels

# Install the wheels. This is extremely fast as there is no compilation.
RUN pip install --no-cache-dir /wheels/*

# Copy the application code
COPY --chown=appuser:appuser monitor_and_scan.py .

# The command to run the monitoring service
CMD ["python", "monitor_and_scan.py"]
