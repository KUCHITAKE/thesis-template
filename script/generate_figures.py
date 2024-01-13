import hashlib
import os
import glob
import subprocess


def calculate_hash(file_path):
    hasher = hashlib.sha256()
    with open(file_path, 'rb') as file:
        buffer = file.read(8192)
        while buffer:
            hasher.update(buffer)
            buffer = file.read(8192)
    return hasher.hexdigest()


def load_previous_hashes(file_path):
    hashes = {}
    if os.path.exists(file_path):
        with open(file_path, 'r') as file:
            for line in file:
                path, hash_value = line.strip().split(': ')
                hashes[path] = hash_value
    return hashes


def process_drawio(file_path):
    output_path = file_path.replace(
        '/fig/drawio/', '/fig/gen/').replace('.drawio', '.pdf')
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    subprocess.run(["bash", "script/drawio_export.sh", file_path, output_path])
    print(f"Generated PDF from {file_path} to {output_path}")


def process_file(file_path):
    print(f"Processing file: {file_path}")
    if file_path.endswith('.drawio'):
        process_drawio(file_path)
    elif file_path.endswith('.plantuml'):
        print(f"Processing .plantuml file: {file_path}")


def check_and_update_files(directory_patterns, hash_file):
    previous_hashes = load_previous_hashes(hash_file)
    current_hashes = {}

    for pattern in directory_patterns:
        for file_path in glob.glob(pattern, recursive=True):
            current_hash = calculate_hash(file_path)
            current_hashes[file_path] = current_hash
            if previous_hashes.get(file_path) != current_hash:
                process_file(file_path)

    with open(hash_file, 'w') as file:
        for path, hash_value in current_hashes.items():
            file.write(f"{path}: {hash_value}\n")


patterns = ['./tex/sections/*/fig/drawio/*.drawio',
            './tex/sections/*/fig/plantuml/*.plantuml']
check_and_update_files(patterns, 'out/fig_hash')
