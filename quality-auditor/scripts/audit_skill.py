#!/usr/bin/env python3
"""Read-only mechanical checks for an Agent Skill bundle."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


SENSITIVE_NAMES = {
    ".env", ".env.local", "credentials", "credentials.json", "id_rsa",
    "id_ed25519", "secrets.json", "token.json",
}
LOCAL_LINK = re.compile(r"\[[^\]]*\]\((?![a-z]+:|#)([^)]+)\)", re.IGNORECASE)
FRONTMATTER = re.compile(r"\A---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|\Z)", re.DOTALL)


def finding(code: str, severity: str, path: Path, message: str) -> dict[str, str]:
    return {"code": code, "severity": severity, "path": path.as_posix(), "message": message}


def parse_simple_frontmatter(text: str) -> tuple[dict[str, str], str | None]:
    match = FRONTMATTER.match(text)
    if not match:
        return {}, "Missing or unterminated YAML frontmatter"
    values: dict[str, str] = {}
    for number, raw in enumerate(match.group(1).splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if raw[:1].isspace() or ":" not in raw:
            continue
        key, value = raw.split(":", 1)
        key = key.strip()
        value = value.strip().strip("\"'")
        if key in values:
            return values, f"Duplicate top-level frontmatter key: {key}"
        values[key] = value
    return values, None


def audit(root: Path) -> dict[str, object]:
    root = root.resolve()
    if not root.is_dir():
        raise ValueError(f"Not a directory: {root}")
    files = [p for p in root.rglob("*") if p.is_file()]
    manifests = [p for p in files if p.name.lower() == "skill.md"]
    findings: list[dict[str, str]] = []
    if len(manifests) != 1:
        findings.append(finding("STR-001", "ERROR", root, f"Expected exactly one SKILL.md; found {len(manifests)}"))
    manifest = manifests[0] if len(manifests) == 1 else None
    referenced: set[Path] = set()
    if manifest:
        text = manifest.read_text(encoding="utf-8-sig", errors="replace")
        meta, error = parse_simple_frontmatter(text)
        if error:
            findings.append(finding("STR-002", "ERROR", manifest, error))
        for key in ("name", "description"):
            if not meta.get(key, "").strip():
                findings.append(finding("STR-003", "ERROR", manifest, f"Missing or empty {key}"))
        if meta.get("name") and meta["name"] != root.name:
            findings.append(finding("STR-004", "WARNING", manifest, f"Frontmatter name '{meta['name']}' differs from directory '{root.name}'"))
        description = meta.get("description", "")
        if description and not re.search(r"\b(use|when|for)\b", description, re.IGNORECASE):
            findings.append(finding("DSC-002", "WARNING", manifest, "Description may not explain when to use the skill"))
        for raw_target in LOCAL_LINK.findall(text):
            target = raw_target.split("#", 1)[0].replace("%20", " ")
            if not target:
                continue
            resolved = (manifest.parent / target).resolve()
            try:
                resolved.relative_to(root)
            except ValueError:
                findings.append(finding("STR-005", "ERROR", manifest, f"Local reference escapes the skill boundary: {raw_target}"))
                continue
            referenced.add(resolved)
            if not resolved.exists():
                findings.append(finding("STR-005", "ERROR", manifest, f"Missing local reference: {raw_target}"))
    for path in files:
        lowered = path.name.lower()
        if lowered in SENSITIVE_NAMES or lowered.endswith((".pem", ".key", ".pfx", ".trace", ".log")):
            findings.append(finding("STR-008", "ERROR", path, "Potentially sensitive or local file present; contents were not inspected"))
        if path == manifest or "agents" in path.parts or "scripts" in path.parts:
            continue
        if path not in referenced:
            findings.append(finding("STR-006", "WARNING", path, "Auxiliary file is not referenced from SKILL.md"))
    return {
        "target": root.as_posix(),
        "file_count": len(files),
        "findings": findings,
        "note": "Mechanical checks only; semantic review is still required.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", type=Path)
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args()
    try:
        result = audit(args.target)
    except (OSError, ValueError) as exc:
        print(json.dumps({"error": str(exc)}), file=sys.stderr)
        return 2
    print(json.dumps(result, indent=2 if args.pretty else None, ensure_ascii=False))
    return 1 if any(item["severity"] == "ERROR" for item in result["findings"]) else 0


if __name__ == "__main__":
    raise SystemExit(main())

