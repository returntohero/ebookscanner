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
RUN useradd --create-home appuser
USER appuser
WORKDIR /home/appuser/app
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/*

# --- [DEBUGGING STEP] ---
# This command will run during the build and its output will be
# permanently saved in the GitHub Actions log for verification.
RUN echo "--- VERIFYING INSTALLED PACKAGES ---" && pip list && echo "--- VERIFICATION COMPLETE ---"

COPY --chown=appuser:appuser monitor_and_scan.py .
CMD ["python", "monitor_and_scan.py"]
