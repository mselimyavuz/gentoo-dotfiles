#!/usr/bin/env python3
import sys
import collections
import shutil
import re
import os

def get_sort_key(atom):
    clean_atom = re.sub(r'^[<>=!~]+', '', atom)
    clean_atom = re.split(r'-\d', clean_atom)[0]
    return clean_atom.lower()

def process_path(target_path):
    if not os.path.exists(target_path):
        return

    is_dir = os.path.isdir(target_path)
    consolidated = collections.defaultdict(set)

    files_to_read = []
    if is_dir:
        for f in sorted(os.listdir(target_path)):
            full_p = os.path.join(target_path, f)
            if os.path.isfile(full_p) and not f.endswith(".bak"):
                files_to_read.append(full_p)
    else:
        files_to_read.append(target_path)

    for filepath in files_to_read:
        with open(filepath, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                
                parts = line.split('#')[0].split()
                if not parts:
                    continue
                
                atom = parts[0]
                flags = parts[1:]
                consolidated[atom].update(flags)

    if not is_dir:
        shutil.copy2(target_path, target_path + ".bak")
        output_path = target_path
    else:
        output_path = target_path + ".consolidated"

    sorted_atoms = sorted(consolidated.keys(), key=get_sort_key)

    with open(output_path, 'w') as f:
        for atom in sorted_atoms:
            flags_list = sorted(list(consolidated[atom]))
            f.write(f"{atom} {' '.join(flags_list)}\n")

if __name__ == "__main__":
    if os.geteuid() != 0:
        os.execvp("sudo", ["sudo", "python3"] + sys.argv)

    if len(sys.argv) > 1:
        process_path(sys.argv[1])
    else:
        process_path("/etc/portage/package.use")

