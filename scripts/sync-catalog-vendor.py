#!/usr/bin/env python3
"""Refresh the unreleased, first-party catalog additions used by vendored CI.

Remove this bridge after coordinated module releases and normal `go mod vendor`.
Run only with matching sibling checkouts. No third-party dependencies are changed.
"""
from pathlib import Path
import shutil
root = Path(__file__).resolve().parents[2]
for repo in ('nibble-api-engine', 'nibble-go-data-store'):
    vendor = root / repo / 'vendor'
    target = vendor / 'github.com/ChristianDenniss/go-data-model/catalog'
    target.mkdir(parents=True, exist_ok=True)
    for name in ('catalog.go', 'branch_matches.json'):
        shutil.copyfile(root / 'nibble-go-data-model/catalog' / name, target / name)
    modules = vendor / 'modules.txt'
    text = modules.read_text()
    package = 'github.com/ChristianDenniss/go-data-model/catalog\n'
    if package not in text:
        anchor = 'github.com/ChristianDenniss/go-data-model/category/entity\n'
        text = text.replace(anchor, package + anchor)
    modules.write_text(text)
store = root / 'nibble-api-engine/vendor/github.com/ChristianDenniss/go-data-store'
for name in ('catalog.go', 'migrations/0005_catalog.sql'):
    shutil.copyfile(root / 'nibble-go-data-store' / name, store / name)
