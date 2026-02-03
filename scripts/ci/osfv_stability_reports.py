from pathlib import Path
from robot.api import ExecutionResult

ROOT = Path("ci_logs")

GREEN = "\033[32m"
RED = "\033[31m"
YELLOW = "\033[33m"
CLEAR = "\033[0m"

def suite_pass_percentage(out_xml: Path) -> float:
    result = ExecutionResult(out_xml)
    stats = result.statistics.total
    total = stats.passed + stats.failed
    if total == 0:
        return 0.0
    return stats.passed / total * 100


def suite_runtime_seconds(out_xml: Path) -> float:
    result = ExecutionResult(out_xml)
    return result.suite.elapsedtime / 1000.0



total_runs = 0
total_pass_pct_sum = 0.0

passes_per_device = {}
passes_per_suite = {}


run_runtimes = {}
runtime_per_device = {}
runtime_per_suite = {}


for run_dir in ROOT.glob("run*"):
    if not run_dir.is_dir():
        continue

    run_name = run_dir.name
    run_total_time = 0.0

    for device_dir in run_dir.iterdir():
        if not device_dir.is_dir():
            continue

        device = device_dir.name

        for suite_dir in device_dir.iterdir():
            if not suite_dir.is_dir():
                continue

            out_files = list(suite_dir.glob("*_out.xml"))
            if not out_files:
                continue

            out_xml = out_files[0]

            pct = suite_pass_percentage(out_xml)
            total_runs += 1
            total_pass_pct_sum += pct
            passes_per_device.setdefault(device, []).append(pct)

            suite_name = suite_dir.name.split("_")[0]
            passes_per_suite.setdefault(suite_name, []).append(pct)

            runtime = suite_runtime_seconds(out_xml)
            run_total_time += runtime
            runtime_per_device.setdefault(device, []).append(runtime)
            runtime_per_suite.setdefault(suite_name, []).append(runtime)

    if run_total_time > 0:
        run_runtimes[run_name] = run_total_time



total_pass_percentage = (
    total_pass_pct_sum / total_runs if total_runs else 0.0
)

passes_per_device_pct = {
    dev: sum(v) / len(v)
    for dev, v in passes_per_device.items()
}

passes_per_suite_pct = {
    suite: sum(v) / len(v)
    for suite, v in passes_per_suite.items()
}

average_run_time = (
    sum(run_runtimes.values()) / len(run_runtimes)
    if run_runtimes else 0.0
)

average_runtime_per_device = {
    dev: sum(v) / len(v)
    for dev, v in runtime_per_device.items()
}

average_runtime_per_suite = {
    suite: sum(v) / len(v)
    for suite, v in runtime_per_suite.items()
}


print(f"Total PASS percentage: {GREEN}{total_pass_percentage:.2f}{CLEAR}%")

print(f"Per device PASS percentages:")
for device in passes_per_device_pct:
    print(f"\t{device}: {GREEN}{passes_per_device_pct[device]:.2f}{CLEAR}%")

print(f"Per suite PASS percentages:")
for suite in passes_per_suite_pct:
    print(f"\t{suite}: {GREEN}{passes_per_suite_pct[suite]:.2f}{CLEAR}%")

print()

print(f"Average run time: {YELLOW}{average_run_time:.2f}{CLEAR}s")

print(f"Average run time per device:")
for device in average_runtime_per_device:
    print(f"\t{device}: {YELLOW}{average_runtime_per_device[device]:.2f}{CLEAR}s")

print(f"Average run time per suite:")
for suite in average_runtime_per_suite:
    print(f"\t{suite}: {YELLOW}{average_runtime_per_suite[suite]:.2f}{CLEAR}s")
