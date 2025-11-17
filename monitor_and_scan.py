# monitor_and_scan.py (Corrected Final Debug Version)
import os
import sys
import time
import subprocess
import threading

# --- All the original scanning functions ---
from ebooklib import epub
import mobi
from pypdf import PdfReader
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# (All the scanning functions like process_epub, scan_ebook_folder, etc., remain the same)
def process_epub(file_path):
    """Extracts title and ISBN from an EPUB file."""
    book = epub.read_epub(file_path)
    title = book.get_metadata('DC', 'title')[0][0]
    isbn13 = None
    isbn10 = None
    for identifier in book.get_metadata('DC', 'identifier'):
        if 'urn:isbn:' in identifier[0]:
            isbn_val = identifier[0].replace('urn:isbn:', '').strip()
            if len(isbn_val) == 13:
                isbn13 = isbn_val
            elif len(isbn_val) == 10:
                isbn10 = isbn_val
    return title, isbn13 if isbn13 else isbn10

def process_mobi(file_path):
    """Extracts title and ISBN from a MOBI or AZW3 file."""
    book = mobi.MobiFile(file_path)
    book.parse()
    title = book.title().decode('utf-8', errors='ignore')
    isbn = None
    for record in book.exth_records:
        if record[0] == 113:
            isbn = record[1].decode('utf-8', errors='ignore')
            break
    return title, isbn

def process_pdf(file_path):
    """Extracts title from a PDF file (ISBN is unreliable)."""
    reader = PdfReader(file_path)
    meta = reader.metadata
    title = meta.title if meta.title else "Title not found"
    return title, None

def scan_ebook_folder(folder_path, output_file):
    """
    Scans a folder and its subfolders for various ebook files and extracts metadata.
    """
    print("--- Starting full library scan... ---")
    HANDLERS = {
        '.epub': process_epub,
        '.mobi': process_mobi,
        '.azw3': process_mobi,
        '.pdf': process_pdf,
    }
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("Ebook Titles and ISBNs\n")
            f.write("======================\n\n")
            for root, dirs, files in os.walk(folder_path):
                files.sort()
                for filename in files:
                    file_ext = os.path.splitext(filename)[1].lower()
                    if file_ext in HANDLERS:
                        file_path = os.path.join(root, filename)
                        relative_path = os.path.relpath(file_path, folder_path)
                        try:
                            handler = HANDLERS[file_ext]
                            title, isbn = handler(file_path)
                            f.write(f"File: {relative_path}\n")
                            f.write(f"Title: {title}\n")
                            f.write(f"ISBN: {isbn if isbn else 'Not found'}\n")
                            f.write("-" * 20 + "\n")
                        except Exception as e:
                            f.write(f"File: {relative_path}\n")
                            f.write(f"Error processing file: {e}\n")
                            f.write("-" * 20 + "\n")
        print(f"--- Scan complete. Report saved to {output_file} ---")
    except Exception as e:
        print(f"FATAL: Could not write to output file {output_file}. Error: {e}")

class ChangeHandler(FileSystemEventHandler):
    def __init__(self, scanner_func, debounce_seconds=30):
        self.scanner_func = scanner_func
        self.debounce_seconds = debounce_seconds
        self.timer = None

    def on_any_event(self, event):
        if event.is_directory:
            return
        if self.timer:
            self.timer.cancel()
        print(f"Change detected: {event.src_path}. Triggering scan in {self.debounce_seconds} seconds.")
        self.timer = threading.Timer(self.debounce_seconds, self.scanner_func)
        self.timer.start()


# --- [CORRECTED] MAIN EXECUTION WITH FULL DEBUG DUMP ---
if __name__ == "__main__":
    scan_path = '/ebooks'
    output_path = '/output/ebook_info.txt'
    STARTUP_DELAY_SECONDS = 10
    
    # Force flushing of all print statements
    sys.stdout.flush()

    print("--- STARTING FULL DIAGNOSTIC DUMP ---")
    print(f"--- Waiting {STARTUP_DELAY_SECONDS} seconds for volumes to mount before dumping info... ---")
    time.sleep(STARTUP_DELAY_SECONDS)

    # 1. Dump User and Environment Info
    print("\n[DEBUG] Running as user:")
    subprocess.run(["id"])
    
    # 2. Dump Filesystem Info
    print(f"\n[DEBUG] Checking for presence of scan path: {scan_path}")
    if os.path.exists(scan_path):
        print(f"[SUCCESS] Scan path {scan_path} exists.")
        print(f"\n[DEBUG] Recursive file listing of {scan_path}:")
        subprocess.run(["ls", "-lR", scan_path])
    else:
        print(f"[FAILURE] Scan path {scan_path} DOES NOT EXIST.")

    print("\n--- DIAGNOSTIC DUMP COMPLETE ---")
    
    # Resume normal operation
    print("\n--- Ebook Monitor Service ---")
    
    # Perform an initial scan on startup
    scan_ebook_folder(scan_path, output_path)

    # Set up the watchdog observer
    event_handler = ChangeHandler(lambda: scan_ebook_folder(scan_path, output_path))
    observer = Observer()
    observer.schedule(event_handler, scan_path, recursive=True)
    observer.start()
    
    print("--- Service is now running and watching for changes... ---")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        print("--- Observer stopped. Shutting down. ---")
    observer.join()
