# Self-Hosted Ebook Metadata Scanner

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/your-username/ebook-scanner/docker-publish.yml?style=for-the-badge&logo=githubactions&logoColor=white)
![Docker Pulls](https://img.shields.io/docker/pulls/your-username/ebook-scanner?style=for-the-badge&logo=docker&logoColor=white)

A modern, event-driven Docker application that actively monitors your ebook library. When a file is added, moved, or deleted, it automatically rescans your collection and generates a fresh report.
This has been vibe coded, but does the job.

This project is configured for **Automated Builds** using GitHub Actions. New versions are automatically built and published to Docker Hub for easy, reliable self-hosting.

---

## Features

-   **Event-Driven**: No more schedules! The scanner runs instantly after a file change.
-   **Highly Efficient**: Uses almost no CPU while idle, only waking up when needed.
-   **One-File Setup**: The entire configuration lives in a single `docker-compose.yml` file.
-   **Stable Releases**: Uses version tagging for predictable, safe updates.

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)

---

## Quick Start Guide

> [!IMPORTANT]
> This guide requires you to download the `docker-compose.yml` file from this repository.

### Step 1: Create a Project Folder

First, create a new, empty folder on your computer. This is where you will save the configuration file and where the output report will be generated.

### Step 2: Download the `docker-compose.yml` File

1.  Navigate to the main page of this repository.
2.  Click on the `docker-compose.yml` file in the file list.
3.  On the file view page, find and click the **"Raw"** button (usually near the top right).
4.  Your browser will display the plain text of the file. Right-click anywhere on the page and select **"Save As..."** (or your browser's equivalent).
5.  Save the file as `docker-compose.yml` inside the project folder you created in Step 1.

### Step 3: Edit the Configuration

Open the `docker-compose.yml` file you just downloaded with any text editor. You **must** edit the following lines:

*   **`image`**:
    *   Replace `your-username` with the repository owner's Docker Hub username.
    *   For stability, change `:latest` to a specific version tag like `:v1.0.0`. You can find all available tags on the **[Docker Hub Tags Page](https://hub.docker.com/r/your-username/ebook-scanner/tags)**.

*   **`volumes`**:
    *   Replace the placeholder `/path/to/your/books` with the full, absolute path to your ebook library on your host machine.

### Step 4: Start the Service

Open a terminal or command prompt, navigate into your project folder, and run the following command:

```sh
docker-compose up -d
