import os
import sys
import subprocess
import shutil

def run_command(cmd, env=os.environ.copy()):
    """
    Wrapper for subprocess.run to not repeat decoding the output too much
    """
    out = subprocess.run(cmd, capture_output=True, env=env)
    out = out.stdout.decode("utf-8").splitlines()
    return out

LOGS_DIR="ci_logs"
MANUAL_TESTS_LIST="scripts/ci/regression-scope/configs/tests-list.txt"
env = os.environ.copy()
env["ALLOW_DIRTY"]="1"
env["MANUAL_TESTS_LIST"]=MANUAL_TESTS_LIST
shutil.rmtree(LOGS_DIR, ignore_errors=True)
os.makedirs(LOGS_DIR)

for i in range(2):
    logs_dir = f"{LOGS_DIR}/run{i}"
    os.makedirs(logs_dir)
    env["LOGS_DIR"]=logs_dir
    out = run_command(
        ["./scripts/ci/develop_pr_auto_regression.sh"],
        env=env
    )
    print("\n".join(out))
