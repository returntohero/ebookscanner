# Dockerfile - Back to Basics

FROM python:3.9-slim-bullseye

# Set work directory
WORKDIR /app

# Install system dependencies first
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy requirements and install them directly
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# --- DEBUGGING: Verify the install location ---
RUN echo "--- VERIFYING INSTALLED PACKAGES (System) ---" && pip list
RUN echo "--- LOCATING WATCHDOG LIBRARY ---" && find /usr/local/lib -name "watchdog"

# Copy the rest of the application code
COPY monitor_and_scan.py .

# Create and switch to a non-root user
RUN useradd --create-home appuser
USER appuser

# The command to run the monitoring service
CMD ["python", "monitor_and_scan.py"]
