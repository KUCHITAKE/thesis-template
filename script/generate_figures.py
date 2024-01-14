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


def get_output_path(file_path):
    if file_path.endswith('.drawio'):
        return file_path.replace('/fig/drawio/', '/fig/gen/').replace('.drawio', '.pdf')
    if file_path.endswith('.dot'):
        return file_path.replace('/fig/dot/', '/fig/gen/').replace('.dot', '.pdf')
    if file_path.endswith('.pu'):
        return file_path.replace('/fig/pu/', '/fig/gen/').replace('.pu', '.pdf')
    return None


def process_drawio(file_path):
    output_path = get_output_path(file_path)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    env_vars = os.environ.copy()
    env_vars.pop("ELECTRON_RUN_AS_NODE", None)
    subprocess.run(
        ["bash", "../script/drawio_export.sh", file_path, output_path], env=env_vars)
    print(f"Generated PDF from {file_path} to {output_path}")


def process_dot(file_path):
    output_path = get_output_path(file_path)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    subprocess.run(
        ["dot", "-Tpdf", file_path, "-o", output_path])
    print(f"Generated PDF from {file_path} to {output_path}")


def process_plantuml(file_path):
    output_path = get_output_path(file_path)
    command = f"cat {
        file_path} | plantuml -tsvg -p | rsvg-convert -f pdf > {output_path}"
    subprocess.run(command, shell=True)
    print(f"Generated PDF from {file_path} to {output_path}")


def process_file(file_path):
    print(f"Processing file: {file_path}")
    if file_path.endswith('.drawio'):
        process_drawio(file_path)
    elif file_path.endswith('.dot'):
        process_dot(file_path)
    elif file_path.endswith('.pu'):
        process_plantuml(file_path)


def check_and_update_files(directory_patterns, hash_file):
    previous_hashes = load_previous_hashes(hash_file)
    current_hashes = {}

    for pattern in directory_patterns:
        for file_path in glob.glob(pattern, recursive=True):
            current_hash = calculate_hash(file_path)
            current_hashes[file_path] = current_hash
            output_path = get_output_path(file_path)
            if previous_hashes.get(file_path) != current_hash or (output_path and not os.path.exists(output_path)):
                print(f"File changed: {file_path}")
                process_file(file_path)

    with open(hash_file, 'w') as file:
        for path, hash_value in current_hashes.items():
            file.write(f"{path}: {hash_value}\n")


patterns = ['sections/*/fig/drawio/*.drawio',
            'sections/*/fig/dot/*.dot',
            'sections/*/fig/pu/*.pu']
check_and_update_files(patterns, 'out/fig_hash')
