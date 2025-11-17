# Self-Hosted Ebook Metadata Scanner

![Docker Build Status](https://img.shields.io/docker/cloud/build/your-username/ebook-scanner?style=for-the-badge) ![Docker Pulls](https://img.shields.io/docker/pulls/your-username/ebook-scanner?style=for-the-badge)

A simple, self-hosted Docker application that automatically scans your ebook library on a schedule, extracts metadata, and generates a clean report.

This project is configured for **Automated Builds** on Docker Hub. When new code is pushed to this GitHub repository, a new Docker image is automatically built and published.

## Features

-   **One-File Setup**: The entire configuration lives in a single `docker-compose.yml` file.
-   **Automated Updates**: New versions are automatically published to Docker Hub.
-   **Stable Versions**: Uses version tagging (e.g., `v1.0.0`) for predictable deployments.

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)

## One-File Installation

#### Step 1: Create a Project Folder
Create a new, empty folder on your computer to hold your `docker-compose.yml` file.

#### Step 2: Create and Configure `docker-compose.yml`
Inside your new folder, create a file named `docker-compose.yml`. Paste the content below.

**Recommendation:** For stability, it is highly recommended to use a specific version tag (e.g., `v1.0.0`) instead of `latest`. You can find all available version tags on the [Docker Hub page](https://hub.docker.com/r/your-username/ebook-scanner/tags).

```yaml
# docker-compose.yml
version: '3.8'

services:
  ebook-scanner:
    # Pulls the pre-built image from Docker Hub.
    # Replace 'your-username' with the actual Docker Hub username.
    # It is recommended to use a specific version tag for stability.
    image: your-username/ebook-scanner:v1.0.0 # <-- CHANGE TO THE LATEST VERSION TAG
    
    container_name: ebook-scanner
    restart: always
    
    environment:
      # Set your desired scan schedule in cron format.
      - CRON_SCHEDULE=0 2 * * *
      
    volumes:
      # Edit the 'source' path below to point to your ebook library.
      - type: bind
        source: /path/to/your/books # <-- EDIT THIS LINE
        target: /ebooks
        read_only: true
        
      # This line maps an 'output' folder in the current directory.
      - type: bind
        source: ./output
        target: /output
