# Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the new monitoring script
COPY monitor_and_scan.py .

# The command is now just to run the Python script directly
CMD ["python", "monitor_and_scan.py"]
