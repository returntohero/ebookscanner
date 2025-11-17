import os
from ebooklib import epub
import mobilib
from pypdf import PdfReader

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
    book = mobilib.MobiFile(file_path)
    book.parse()
    
    title = book.title().decode('utf-8', errors='ignore')
    isbn = None
    
    # EXTH record 113 is typically the ISBN
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
    # ISBN is not a standard metadata field in PDFs
    isbn = None 
    
    return title, isbn

def scan_ebook_folder(folder_path, output_file):
    """
    Scans a folder and its subfolders for various ebook files and extracts metadata.
    """
    # Map file extensions to their respective processing functions
    HANDLERS = {
        '.epub': process_epub,
        '.mobi': process_mobi,
        '.azw3': process_mobi, # AZW3 is handled by the mobi library
        '.pdf': process_pdf,
    }

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("Ebook Titles and ISBNs\n")
        f.write("======================\n\n")

        # Use os.walk() to traverse the directory tree
        for root, dirs, files in os.walk(folder_path):
            files.sort() # Process files in a consistent order
            for filename in files:
                file_ext = os.path.splitext(filename)[1].lower()
                
                if file_ext in HANDLERS:
                    file_path = os.path.join(root, filename)
                    # Get a cleaner path relative to the root scan folder for the report
                    relative_path = os.path.relpath(file_path, folder_path) 
                    try:
                        handler = HANDLERS[file_ext]
                        title, isbn = handler(file_path)

                        f.write(f"File: {relative_path}\n")
                        f.write(f"Title: {title}\n")
                        f.write(f"ISBN: {isbn if isbn else 'Not found'}\n")
                        f.write("-" * 20 + "\n")
                        print(f"Processed: {relative_path}")

                    except Exception as e:
                        f.write(f"File: {relative_path}\n")
                        f.write(f"Error processing file: {e}\n")
                        f.write("-" * 20 + "\n")
                        print(f"Error processing {relative_path}: {e}")

    print(f"\nScan complete. Information saved to {output_file}")

if __name__ == "__main__":
    folder_to_scan = '/ebooks'
    output_filename = '/output/ebook_info.txt'
    scan_ebook_folder(folder_to_scan, output_filename)
