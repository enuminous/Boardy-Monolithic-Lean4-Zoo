"""Build, regress and audit the local candidate model; no network or mail access."""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def run(*args):
    result = subprocess.run(args, cwd=ROOT, text=True, capture_output=True)
    print(result.stdout, end="")
    print(result.stderr, end="")
    result.check_returncode()
    return result.stdout


def main():
    modules = ("BoardyStudy", "ReplayProtected")
    regressions = ("Regression.lean", "ReplayRegression.lean")
    for name in tuple(f"{module}.lean" for module in modules) + regressions:
        text = (ROOT / name).read_text()
        if re.search(r"\b(sorry|admit|axiom|native_decide|unsafe)\b", text):
            raise RuntimeError(f"Disallowed proof escape in {name}")
    roster = json.loads((ROOT / "study/zoo-coverage.json").read_text())["animals"]
    assert len(roster) == len({x["name"] for x in roster}) == 46
    assert {x["id"] for x in roster} == set(range(1, 47))
    assert all(x["execution"] == "not_run" and x["evidence_status"] == "unresolved"
               for x in roster)
    run("lake", "build")
    for regression in regressions:
        run("lake", "env", "lean", "-DwarningAsError=true", regression)
    names = [f"{module}.{name}" for module in modules
             for name in re.findall(r"^theorem\s+(\w+)",
                                    (ROOT / f"{module}.lean").read_text(), re.MULTILINE)]
    audit = ROOT / ".lake/BoardyAudit.lean"
    audit.write_text("\n".join(f"import {module}" for module in modules) + "\n" + "\n".join(
        f"#print axioms {name}" for name in names) + "\n")
    output = run("lake", "env", "lean", "-DwarningAsError=true", str(audit))
    reports = re.findall(r"depends on axioms:\s*\[([^\]]*)\]", output)
    no_axioms = output.count("does not depend on any axioms")
    assert len(reports) + no_axioms == len(names), "Missing axiom audit report"
    allowed = {"propext", "Classical.choice", "Quot.sound"}
    for report in reports:
        used = {s.strip() for s in report.split(",") if s.strip()}
        assert used <= allowed, f"Unexpected axioms: {used - allowed}"
    counts = {name: len(re.findall(r"^example\s*:", (ROOT / name).read_text(), re.MULTILINE))
              for name in regressions}
    print(f"PASS: {len(names)} named theorems audited; regression examples {counts}; "
          "46 Zoo entries explicitly unresolved for Boardy.")


if __name__ == "__main__":
    main()
