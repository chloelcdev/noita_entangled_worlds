"""Package quant.ew.zip and noita_proxy-win.zip for fork releases."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TARGET = ROOT / "target"
RELEASE = ROOT / "release"
PROXY_STAGE = ROOT / "noita_proxy" / "target" / "release"


def main() -> None:
    proxy_exe = Path(os.environ.get("PROXY_EXE", PROXY_STAGE / "noita_proxy.exe"))
    if not proxy_exe.is_file():
        print(f"Proxy exe not found: {proxy_exe}", file=sys.stderr)
        sys.exit(1)

    PROXY_STAGE.mkdir(parents=True, exist_ok=True)
    shutil.copy2(proxy_exe, PROXY_STAGE / "noita_proxy.exe")

    steam_src = ROOT / "redist" / "steam_api64.dll"
    if steam_src.is_file():
        shutil.copy2(steam_src, PROXY_STAGE / "steam_api64.dll")

    subprocess.run(
        [sys.executable, "scripts/ci_make_archives.py", "mod"],
        cwd=ROOT,
        check=True,
    )
    subprocess.run(
        [sys.executable, "scripts/ci_make_archives.py", "windows"],
        cwd=ROOT,
        check=True,
    )

    RELEASE.mkdir(exist_ok=True)
    for name in ("quant.ew.zip", "noita_proxy-win.zip"):
        src = TARGET / name
        if not src.is_file():
            print(f"Expected archive missing: {src}", file=sys.stderr)
            sys.exit(1)
        shutil.copy2(src, RELEASE / name)
        print(f"Staged {RELEASE / name}")


if __name__ == "__main__":
    main()
