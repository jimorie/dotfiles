#!/usr/bin/env python3

import argparse
import getpass
import os
import subprocess
import sys
import tempfile


REPOS = {
    'opsview-orchestrator': {
        'source_directory': 'opsview-orchestrator/opsview',
        'target_directory': '/opt/opsview/orchestrator/venv3/lib/python3.9/site-packages/opsview',
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('host', help='Network address of the target instance')
    parser.add_argument('--source', '-s', help='Source file or directory, relative to the repo root')
    parser.add_argument('--target', '-t', help='Absolute path to the root live directory')
    parser.add_argument('--password', '-p', action='store_true', help='Copy SSH ID to instance')
    return parser.parse_args()


def get_changed(source_directory: str) -> list:
    proc = subprocess.run(['git', 'st', source_directory, '--porcelain', '--untracked=no'], capture_output=True)
    return [line[2:].strip() for line in proc.stdout.decode().splitlines()]


def get_git_root() -> str:
    proc = subprocess.run(['git', 'rev-parse', '--show-toplevel'], capture_output=True)
    return proc.stdout.decode().strip()


def ssh_copy_id(host):
    subprocess.run(['ssh-copy-id', host])


def main():
    args = parse_args()
    git_root = get_git_root()
    git_name = os.path.basename(git_root)
    host = args.host
    source_directory = args.source
    target_directory = args.target
    if not source_directory:
        if git_name in REPOS:
            source_directory = os.path.join(git_root, REPOS[git_name]['source_directory'])
        else:
            raise SystemExit('No --source given')
    else:
        source_directory = os.path.abspath(source_directory)
    if not target_directory:
        if git_name in REPOS:
            target_directory = REPOS[git_name]['target_directory']
        else:
            raise SystemExit('No --target given')
    if args.password:
        ssh_copy_id(host)
    for changed_path in get_changed(source_directory):
        source_path = os.path.join(git_root, changed_path)
        target_path = os.path.join(target_directory, source_path[len(source_directory):].strip('/'))
        print(f'{changed_path} -> {target_path}')
        rsync_cmd = [
            'rsync',
            '--rsync-path',
            'sudo rsync',
            source_path,
            f'{host}:{target_path}'
        ]
        proc = subprocess.run(rsync_cmd)
        proc.check_returncode()
    enable_livehack_cmd = "find . -name '\\''*.py'\\'' -exec mv -v '\\''{}c'\\'' '\\''{}c.orig'\\'' \\;"
    proc = subprocess.run(f'ssh {host} "{enable_livehack_cmd}"')
    proc.check_returncode()


if __name__ == '__main__':
    sys.exit(main())

