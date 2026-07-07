"""Build release zips and publish a GitHub release on the configured fork."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RELEASE_ENV = ROOT / "release.env"


def read_env_file() -> dict[str, str]:
    values: dict[str, str] = {}
    if not RELEASE_ENV.is_file():
        return values
    for line in RELEASE_ENV.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def read_version() -> str:
    cargo = (ROOT / "noita_proxy" / "Cargo.toml").read_text(encoding="utf-8")
    match = re.search(r'^version = "(.+)"', cargo, re.MULTILINE)
    if match is None:
        raise RuntimeError("Could not read version from noita_proxy/Cargo.toml")
    return match.group(1)


def run(cmd: list[str], **kwargs) -> None:
    print("+", " ".join(cmd))
    subprocess.run(cmd, cwd=ROOT, check=True, **kwargs)


def main() -> None:
    env = read_env_file()
    repo = env.get("EW_GITHUB_REPO")
    if not repo:
        print("EW_GITHUB_REPO missing in release.env", file=sys.stderr)
        sys.exit(1)

    version = read_version()
    tag = f"v{version}"

    run(["python", "scripts/package_fork_release.py"])

    zip_paths = [TARGET / "quant.ew.zip", TARGET / "noita_proxy-win.zip"]
    for path in zip_paths:
        if not path.is_file():
            print(f"Expected archive missing: {path}", file=sys.stderr)
            sys.exit(1)

    notes = f"Fork release {tag}\n\nIncludes duplicate-wand fork changes."
    run(
        [
            "gh",
            "release",
            "create",
            tag,
            "target/quant.ew.zip",
            "target/noita_proxy-win.zip",
            "--repo",
            repo,
            "--title",
            tag,
            "--notes",
            notes,
        ]
    )
    print(f"Published {tag} to https://github.com/{repo}/releases/tag/{tag}")


if __name__ == "__main__":
    main()
