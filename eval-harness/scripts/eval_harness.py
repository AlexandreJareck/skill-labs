#!/usr/bin/env python3
"""Validate skill-eval cases and grade deterministic observations."""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path
from typing import Any, Iterable


CASE_VERSION = "skill-eval-case/v1"
OBS_VERSION = "skill-eval-observation/v1"
CATEGORIES = {
    "explicit_trigger", "implicit_trigger", "non_trigger", "incomplete_input",
    "ambiguous_input", "edge_case", "scope_expansion", "safety_boundary",
    "known_regression", "missed_trigger", "false_positive_trigger",
    "incomplete_workflow", "incorrect_output", "unsafe_action",
    "unauthorized_write", "hallucinated_fact", "missing_validation",
    "ignored_constraint", "excessive_tool_use", "portability_failure",
    "infrastructure_failure",
}
SEVERITIES = {"critical", "high", "medium", "low"}
ASPECTS = {"outcome", "process", "style", "efficiency"}
CHECK_TYPES = {
    "trigger_equals", "output_contains", "output_not_contains",
    "artifact_present", "artifact_absent", "tool_used", "tool_not_used",
    "write_present", "write_absent", "exit_code_equals", "max_tool_calls",
}
ID_PATTERN = re.compile(r"^[a-z0-9][a-z0-9._-]*$")


def load_jsonl(path: str) -> list[dict[str, Any]]:
    stream = sys.stdin if path == "-" else Path(path).open("r", encoding="utf-8-sig")
    try:
        records = []
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                value = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"line {line_number}: invalid JSON: {exc.msg}") from exc
            if not isinstance(value, dict):
                raise ValueError(f"line {line_number}: expected a JSON object")
            value["__line__"] = line_number
            records.append(value)
        return records
    finally:
        if stream is not sys.stdin:
            stream.close()


def validate_cases(cases: Iterable[dict[str, Any]]) -> list[str]:
    errors: list[str] = []
    seen: set[str] = set()
    required = {
        "schema_version", "id", "description", "prompt", "category",
        "should_trigger", "expected_behavior", "forbidden_behavior",
        "expected_artifacts", "checks", "rubric", "severity", "origin",
    }
    for case in cases:
        line = case.get("__line__", "?")
        prefix = f"line {line}"
        missing = sorted(required - case.keys())
        if missing:
            errors.append(f"{prefix}: missing fields: {', '.join(missing)}")
            continue
        case_id = case["id"]
        if not isinstance(case_id, str) or not ID_PATTERN.fullmatch(case_id):
            errors.append(f"{prefix}: invalid id")
        elif case_id in seen:
            errors.append(f"{prefix}: duplicate id '{case_id}'")
        seen.add(case_id)
        if case["schema_version"] != CASE_VERSION:
            errors.append(f"{prefix}: unsupported schema_version")
        if case["category"] not in CATEGORIES:
            errors.append(f"{prefix}: invalid category")
        if case["severity"] not in SEVERITIES:
            errors.append(f"{prefix}: invalid severity")
        if case["should_trigger"] not in (True, False, None):
            errors.append(f"{prefix}: should_trigger must be true, false, or null")
        for field in ("description", "prompt"):
            if not isinstance(case[field], str) or not case[field].strip():
                errors.append(f"{prefix}: {field} must be a non-empty string")
        for field in ("expected_behavior", "forbidden_behavior", "expected_artifacts", "checks", "rubric"):
            if not isinstance(case[field], list):
                errors.append(f"{prefix}: {field} must be an array")
        if isinstance(case["expected_behavior"], list) and not case["expected_behavior"]:
            errors.append(f"{prefix}: expected_behavior must not be empty")
        check_ids: set[str] = set()
        for check in case["checks"] if isinstance(case["checks"], list) else []:
            if not isinstance(check, dict):
                errors.append(f"{prefix}: each check must be an object")
                continue
            if not {"id", "aspect", "type", "value", "severity"} <= check.keys():
                errors.append(f"{prefix}: check is missing required fields")
                continue
            if check["id"] in check_ids:
                errors.append(f"{prefix}: duplicate check id '{check['id']}'")
            check_ids.add(check["id"])
            if check["aspect"] not in ASPECTS or check["type"] not in CHECK_TYPES or check["severity"] not in SEVERITIES:
                errors.append(f"{prefix}: invalid check enum in '{check['id']}'")
            expected_type = bool if check["type"] == "trigger_equals" else int if check["type"] in {"exit_code_equals", "max_tool_calls"} else str
            if type(check["value"]) is not expected_type:
                errors.append(f"{prefix}: invalid value type for check '{check['id']}'")
        for rubric in case["rubric"] if isinstance(case["rubric"], list) else []:
            if not isinstance(rubric, dict) or not {"id", "aspect", "criterion", "severity"} <= rubric.keys():
                errors.append(f"{prefix}: rubric item is missing required fields")
            elif rubric["aspect"] not in ASPECTS or rubric["severity"] not in SEVERITIES:
                errors.append(f"{prefix}: invalid rubric enum in '{rubric['id']}'")
        origin = case["origin"]
        if not isinstance(origin, dict) or origin.get("type") not in {"designed", "incident", "external"} or not origin.get("reference"):
            errors.append(f"{prefix}: invalid origin")
    return errors


def evaluate_check(check: dict[str, Any], obs: dict[str, Any]) -> tuple[str, str]:
    kind, value = check["type"], check["value"]
    field_map = {
        "trigger_equals": "skill_triggered", "output_contains": "output_text",
        "output_not_contains": "output_text", "artifact_present": "artifacts",
        "artifact_absent": "artifacts", "tool_used": "tools", "tool_not_used": "tools",
        "write_present": "writes", "write_absent": "writes",
        "exit_code_equals": "exit_code", "max_tool_calls": "metrics",
    }
    field = field_map[kind]
    if field not in obs or (kind == "max_tool_calls" and "tool_calls" not in obs.get("metrics", {})):
        return "NOT_RUN", f"observation lacks {field}"
    if kind == "trigger_equals":
        actual, passed = obs[field], obs[field] is value
    elif kind == "output_contains":
        actual, passed = value, value in obs[field]
    elif kind == "output_not_contains":
        actual, passed = value, value not in obs[field]
    elif kind in {"artifact_present", "tool_used", "write_present"}:
        actual, passed = value, value in obs[field]
    elif kind in {"artifact_absent", "tool_not_used", "write_absent"}:
        actual, passed = value, value not in obs[field]
    elif kind == "exit_code_equals":
        actual, passed = obs[field], obs[field] == value
    else:
        actual, passed = obs["metrics"]["tool_calls"], obs["metrics"]["tool_calls"] <= value
    return ("PASS" if passed else "FAIL"), f"expected {value!r}; observed {actual!r}"


def grade(cases: list[dict[str, Any]], observations: list[dict[str, Any]]) -> str:
    obs_by_id = {item.get("case_id"): item for item in observations}
    rows, category_counts, aspect_counts, totals = [], Counter(), Counter(), Counter()
    for case in cases:
        case_id = case["id"]
        obs = obs_by_id.get(case_id)
        details: list[tuple[str, str, str]] = []
        if not obs:
            status = "NOT_RUN"
        elif obs.get("schema_version") != OBS_VERSION:
            status, details = "INFRASTRUCTURE_FAILURE", [("observation", "NOT_RUN", "unsupported observation schema")]
        elif obs.get("status") == "infrastructure_failure":
            status, details = "INFRASTRUCTURE_FAILURE", [("infrastructure", "NOT_RUN", obs.get("infrastructure_error", "unspecified"))]
        elif obs.get("status") != "completed":
            status = "NOT_RUN"
        else:
            for check in case["checks"]:
                result, evidence = evaluate_check(check, obs)
                details.append((check["id"], result, evidence))
                aspect_counts[(check["aspect"], result)] += 1
            status = "FAIL" if any(x[1] == "FAIL" for x in details) else "NOT_RUN" if any(x[1] == "NOT_RUN" for x in details) or case["rubric"] else "PASS"
        totals[status] += 1
        category_counts[(case["category"], status)] += 1
        rows.append((case_id, case["category"], status, details, len(case["rubric"])))
    lines = ["# Skill evaluation summary", "", f"- Total cases: {len(cases)}"]
    for key in ("PASS", "FAIL", "NOT_RUN", "INFRASTRUCTURE_FAILURE"):
        lines.append(f"- {key}: {totals[key]}")
    lines.extend(["", "## Results by category", "", "| Category | Pass | Fail | Not run | Infrastructure |", "|---|---:|---:|---:|---:|"])
    for category in sorted({case["category"] for case in cases}):
        lines.append(f"| {category} | {category_counts[(category, 'PASS')]} | {category_counts[(category, 'FAIL')]} | {category_counts[(category, 'NOT_RUN')]} | {category_counts[(category, 'INFRASTRUCTURE_FAILURE')]} |")
    lines.extend(["", "## Deterministic checks by aspect", "", "| Aspect | Pass | Fail | Not run |", "|---|---:|---:|---:|"])
    for aspect in ("outcome", "process", "style", "efficiency"):
        lines.append(f"| {aspect} | {aspect_counts[(aspect, 'PASS')]} | {aspect_counts[(aspect, 'FAIL')]} | {aspect_counts[(aspect, 'NOT_RUN')]} |")
    lines.extend(["", "## Case evidence", ""])
    for case_id, category, status, details, rubric_count in rows:
        lines.append(f"### {case_id} — {status}")
        lines.append(f"Category: `{category}`.")
        for check_id, result, evidence in details:
            lines.append(f"- `{check_id}`: **{result}** — {evidence}")
        if rubric_count:
            lines.append(f"- Semantic rubric items pending: {rubric_count}")
        if not details and status == "NOT_RUN":
            lines.append("- No completed observation was supplied.")
        lines.append("")
    lines.extend(["## Limitations", "", "This deterministic report does not grade semantic rubric items or infer unobserved process details."])
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    validate = sub.add_parser("validate")
    validate.add_argument("cases")
    grader = sub.add_parser("grade")
    grader.add_argument("cases")
    grader.add_argument("observations")
    args = parser.parse_args()
    try:
        cases = load_jsonl(args.cases)
        errors = validate_cases(cases)
        if errors:
            print("\n".join(errors), file=sys.stderr)
            return 1
        if args.command == "validate":
            print(f"Valid: {len(cases)} case(s)")
            return 0
        observations = load_jsonl(args.observations)
        print(grade(cases, observations))
        return 0
    except (OSError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())

