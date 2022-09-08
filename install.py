#!/usr/bin/env python3
import argparse
import json
import os
import platform
import re
import subprocess
import sys

from typing import List, Union


def parse_args(args: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser()

    parser.add_argument("-o", "--os", default=None,
                        help="Manually set the operating system")
    parser.add_argument("-c", "--config", default="PackageConfig.json")
    parser.add_argument("-g", "--gui", action="store_true",
                        default=False, help="Install GUI configurations")
    parser.add_argument("-y", "--yes", action="store_true",
                        default=False, help="Assume yes for all prompts")

    return parser.parse_args(args)


def get_os_name() -> str:
    os_name = platform.system()
    if os_name == "Linux":
        potential_filenames = (
            "/etc/lsb-release",
            "/etc/os-release",
            "/usr/lib/os-release"
        )
        for filename in potential_filenames:
            if os.path.isfile(filename):
                with open(filename) as f:
                    match = re.match(r'NAME="([^"]*)"', f.read())
                    if match:
                        os_name = match.group(1)
                        break
    return os_name


def load_package_config(path: str) -> dict:
    with open(path) as f:
        return json.load(f)


def select_packages(
    os_name: str,
    config: Union[dict, List[str]],
    gui: bool
) -> List[str]:
    # If it is just a list of packages, use the list
    if config is list:
        return config

    # If it is a dictionary, look for "base" and "gui" to select accordingly
    packages = []

    # Fetch the base packages first
    if "base" not in config:
        print(
            f"Could not find base package configuration for {os_name}",
            file=sys.stderr
        )
    else:
        packages.extend(config["base"])

    # Only bother with GUI packages if the GUI config is desired
    if gui:
        if "gui" not in config:
            print(
                f"Could not find GUI package configuration for {os_name}",
                file=sys.stderr
            )
        else:
            packages.extend(config["gui"])

    return packages


def stow_packages(packages: List[str], assume_yes: bool):
    home_dir = os.environ.get("HOME") or os.environ.get("USERPROFILE") or "~"
    command = ["stow", "-t", home_dir, "-R"] + packages

    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    stdout, stderr = process.communicate()

    if stderr:
        failed = []
        for line in str(stderr, "utf-8").split("\n"):
            failed_file = re.match(
                r".*existing target is neither a link nor a directory: (.+)",
                line
            )
            if failed_file:
                failed.append(failed_file.group(1))

        # There could have been duplicates
        failed = list(set(failed))

        print("Conflicts:")
        for file in failed:
            print(f"  - {file}")

        delete = assume_yes or input(
            "Delete files? [y/N] "
        ).lower().startswith("y")

        if delete:
            for file in failed:
                os.remove(os.path.join(home_dir, file))

            stow_packages(packages, assume_yes)


def main(arguments: List[str]):
    args = parse_args(arguments)
    os_name = args.os or get_os_name()
    config = load_package_config(args.config)

    if os_name not in config:
        print(f"No packages found for {os_name}", file=sys.stderr)
        exit(1)

    packages = select_packages(os_name, config[os_name], args.gui)
    stow_packages(packages, args.yes)


if __name__ == "__main__":
    main(sys.argv[1:])
