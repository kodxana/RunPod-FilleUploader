import json
import os
import sys

def main(tus_id):
    workspace_dir = '/workspace'
    info_file_path = os.path.join(workspace_dir, f"{tus_id}.info")
    upload_file_path = os.path.join(workspace_dir, tus_id)

    try:
        with open(info_file_path, 'r') as f:
            info = json.load(f)
        original_filename = info['MetaData']['filename']
    except (FileNotFoundError, KeyError):
        print(f"Error: .info file not found or missing metadata for {tus_id}", file=sys.stderr)
        return

    new_file_path = os.path.join(workspace_dir, original_filename)
    try:
        os.rename(upload_file_path, new_file_path)
        print(f"Renamed {upload_file_path} to {new_file_path}", file=sys.stderr)
        # After successfully renaming the file, delete the .info file
        os.remove(info_file_path)
        print(f"Deleted .info file: {info_file_path}", file=sys.stderr)
    except OSError as e:
        print(f"Error renaming file or deleting .info file: {e}", file=sys.stderr)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: rename_uploaded_file.py TUS_ID", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1])
