#!/usr/bin/env python3
"""Compile notebook.typ to notebook.pdf using the Typst Python compiler binding."""
from __future__ import annotations

from pathlib import Path
import sys

try:
    import typst
except ImportError as exc:
    raise SystemExit(
        "The typst Python package is not importable. Install it with `python -m pip install typst` "
        "or set PYTHONPATH to the package directory used in this environment."
    ) from exc

ROOT = Path(__file__).resolve().parent
INPUT = ROOT / "notebook.typ"
OUTPUT = ROOT / "notebook.pdf"

if not INPUT.exists():
    raise SystemExit(f"Missing input file: {INPUT}")

result = typst.compile_with_warnings(str(INPUT), output=str(OUTPUT), root=str(ROOT))
# typst.compile_with_warnings returns (document, warnings) when output is not supplied in some builds;
# with output supplied here, the first item is None and the second item is the warning list.
warnings = result[1] if isinstance(result, tuple) and len(result) > 1 else []

if warnings:
    print("Typst compiled with warnings:", file=sys.stderr)
    for warning in warnings:
        print(warning, file=sys.stderr)
else:
    print(f"Compiled {INPUT.name} -> {OUTPUT.name} with Typst {typst.__version__}; no warnings.")
