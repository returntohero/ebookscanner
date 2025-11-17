# Ebook Metadata Scanner

This is a self-hosted Docker application that recursively scans a directory for various ebook formats (`.epub`, `.mobi`, `.azw3`, `.pdf`), extracts metadata like title and ISBN, and saves the information to a text file.

## Features

-   **Multi-Format Support**: Scans EPUB, MOBI, AZW3, and PDF files.
-   **Recursive Scan**: Scans all subdirectories within the main `ebooks` folder.
-   **Dockerized**: Runs in a containerized environment, requiring only Docker and Docker Compose to be installed. No need to install Python or dependencies on your host machine.
-   **Clean Output**: Generates a well-formatted `ebook_info.txt` file with the results.

## Prerequisites

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)

## How to Use

1.  **Clone the Repository**
    ```sh
    git clone <your-repository-url>
    cd ebook-scanner
    ```

2.  **Add Your Ebooks**
    Place your ebook files and subfolders into the `ebooks/` directory.

3.  **Build and Run the Scanner**
    Open a terminal in the project's root directory and run the following command:
    ```sh
    docker-compose up --build
    ```
    This command will build the Docker image, start the container, and run the scanning script. The script will process all files in the `ebooks` folder and its subdirectories.

4.  **Check the Output**
    Once the script is finished, you will find a file named `ebook_info.txt` inside the `output/` directory. This file contains the extracted titles and ISBNs for each processed ebook.

    To run the scan again in the future, you can simply use `docker-compose up`. If you make changes to the Python script, you must use the `--build` flag again to rebuild the image with your changes.

## Project Structure
