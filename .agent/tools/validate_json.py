#!/usr/bin/env python3
"""Validate a JSON document against a local schema if jsonschema is installed."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("document")
    p.add_argument("schema")
    args = p.parse_args()

    try:
        import jsonschema
    except ImportError:
        print("jsonschema is not installed; install it in the project environment.", file=sys.stderr)
        return 2

    document = json.loads(Path(args.document).read_text(encoding="utf-8"))
    schema = json.loads(Path(args.schema).read_text(encoding="utf-8"))
    jsonschema.validate(document, schema)
    print("VALID")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
