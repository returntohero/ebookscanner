# Self-Hosted Ebook Metadata Scanner

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/your-username/ebook-scanner/docker-publish.yml?style=for-the-badge) ![Docker Pulls](https://img.shields.io/docker/pulls/your-username/ebook-scanner?style=for-the-badge)

A modern, event-driven Docker application that actively monitors your ebook library. When a file is added, moved, or deleted, it automatically rescans your collection and generates a fresh report.

This project is configured for **Automated Builds** using GitHub Actions. New versions are automatically built and published to Docker Hub.

## Features

-   **Event-Driven**: No more schedules! The scanner runs instantly after a file change.
-   **Highly Efficient**: Uses almost no CPU while idle, only waking up when needed.
-   **One-File Setup**: The entire configuration lives in a single `docker-compose.yml` file.
-   **Stable Releases**: Uses version tagging for predictable, safe updates.

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
    image: your-username/ebook-scanner:v1.0.0 # <-- CHANGE TO THE LATEST VERSION TAG
    
    container_name: ebook-scanner
    restart: unless-stopped
    
    volumes:
      # --- MAP YOUR FOLDERS HERE ---
      # 1. Edit the 'source' path below to point to your ebook library.
      - type: bind
        source: /path/to/your/books # <-- EDIT THIS LINE
        target: /ebooks
        read_only: true
        
      # 2. This line maps an 'output' folder in the current directory.
      - type: bind
        source: ./output
        target: /output
