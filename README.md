# Self-Hosted Ebook Metadata Scanner

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/returntohero/ebook-scanner/docker-publish.yml?style=for-the-badge&logo=githubactions&logoColor=white)
![Docker Pulls](https://img.shields.io/docker/pulls/returntohero/ebook-scanner?style=for-the-badge&logo=docker&logoColor=white)

A modern, event-driven Docker application that actively monitors your ebook library. When a file is added, moved, or deleted, it automatically rescans your collection, extracts metadata like title and ISBN, and generates a fresh report.

This project is configured for **Automated Builds** using GitHub Actions. New versions are automatically built and published to Docker Hub for easy, reliable self-hosting.

---

## Features

-   **Event-Driven**: No more schedules! The scanner runs instantly after a file change.
-   **Highly Efficient**: Uses almost no CPU while idle, only waking up when needed.
-   **One-File Setup**: The entire configuration lives in a single `docker-compose.yml` file.
-   **Stable Releases**: Uses version tagging for predictable, safe updates.
-   **Multi-Format Support**: Scans `.epub`, `.mobi`, `.azw3`, and `.pdf` files.

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)

---

## Quick Start Guide

> [!IMPORTANT]
> This guide is designed for Linux-based hosts, including servers like TrueNAS, Unraid, etc.

### Step 1: Create a Project Folder

First, create a new, empty folder on your server. This is where you will save the configuration file and where the output report will be generated.

```sh
mkdir -p /path/to/your/config/ebook-scanner
cd /path/to/your/config/ebook-scanner
```

### Step 2: Download the `docker-compose.yml` File

Download the official `docker-compose.yml` file from this repository into the folder you just created.

```sh
# Run this command from inside your new project folder
curl -o docker-compose.yml https://raw.githubusercontent.com/returntohero/ebook-scanner/main/docker-compose.yml
```

### Step 3: Configure the `docker-compose.yml` File

Open the `docker-compose.yml` file you just downloaded with any text editor (like `nano`). You **must** edit the following lines:

1.  **`image`**:
    *   For stability, change `:latest` to a specific version tag like `:v1.0.0`. You can find all available tags on the **[Docker Hub Tags Page](https://hub.docker.com/r/returntohero/ebook-scanner/tags)**.

2.  **`user`**:
    *   You need to find the User ID (PUID) and Group ID (PGID) of the user that owns your media files. In a terminal, run `id your-media-user`.
    *   Change the placeholder `"1000:1000"` to your user's `UID:GID` (e.g., `"568:568"` for the `apps` user on TrueNAS).

3.  **`volumes`**:
    *   Replace the placeholder `/path/to/your/books` with the full, absolute path to your ebook library.
    *   Replace `./output` with the full, absolute path to where you want the report saved. This **must** be a different folder than your books folder.

### Step 4: Start the Service

From your project folder, run the following command:

```sh
docker-compose up -d```

Docker will now download the image and start the monitoring service. The `output` folder will be created, and your `ebook_info.txt` report will be generated inside it.

---

## Management and Updates

### Viewing Logs
To see the real-time activity of the scanner or check for errors, run:
```sh
docker-compose logs -f
```

### Updating the Application
Updating to a new version is safe and easy.

1.  Check the [Docker Hub Tags page](https://hub.docker.com/r/returntohero/ebook-scanner/tags) for the latest version number.
2.  Update the `image:` line in your `docker-compose.yml` to the new version tag.
3.  From your project folder, run the following commands:
    ```sh
    # 1. Pull the new version you specified
    docker-compose pull

    # 2. Restart the container with the new image
    docker-compose up -d
    ```

---

## Troubleshooting

<details>
<summary><strong>Fixing `Permission denied` Errors in Logs</strong></summary>

If your logs show a `[Errno 13] Permission denied` error when trying to write the output file, it means the user you specified in the `docker-compose.yml` (`user: "PUID:PGID"`) does not have write permissions on the host output folder.

To fix this, run the following command on your host machine, replacing the path and user details with your own:

```sh
# chown -R PUID:PGID /path/to/your/output/folder
chown -R 568:568 /mnt/Storage/configs/ebook-scanner/output
```
Then, restart the container with `docker-compose up -d`.

</details>

## License
This project is licensed under the [MIT License](LICENSE).
