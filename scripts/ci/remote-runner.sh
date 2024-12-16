#!/usr/bin/env bash

# Function to display help
display_help() {
    echo "Usage: $0 <user@remote-host> <local-src-dir> <qemu-mode> <action> <firmware>"
    echo
    echo "This script continuously syncs a local directory to a remote"
    echo "directory and runs a QEMU instance according to parameters on"
    echo "the remote machine."
    echo
    echo "Arguments:"
    echo "  user@remote-host    The username and host of the remote machine."
    echo "  local-src-dir       The local source directory to sync."
    echo "  qemu-mode           The QEMU mode nographic/vnc/graphic/..."
    echo "  action              The QEMU actions like os/os_install"
    echo "  firmware            The QEMU actions like uefi/seabios"
    echo
    echo "Check ./scripts/ci/qemu-run.sh help for more information."
    echo
    echo "Options:"
    echo "  -h, --help          Display this help message and exit."
    echo
    exit 1
}

# Check for the required parameters
if [ "$#" -ne 5 ]; then
    display_help
fi

# Check for help option
for arg in "$@"
do
    if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
        display_help
    fi
done

# Function to clean up background processes when the script exits
cleanup() {
	echo "Cleaning up..."
	# Kill the inotifywait background process
	kill $INOTIFY_PID
}

# Set trap to call cleanup function when the script exits
trap cleanup exit

REMOTE_USER_HOST="$1"
LOCAL_SRC_DIR="$2" # Local source directory provided as the second parameter
SELF_TEST_TYPE="$3"
SELF_TEST_ACTION="$4"
SELF_TEST_FW="$5"
REMOTE_SRC_DIR="/tmp/osfv"

# Function to continuously sync local directory with remote directory
start_sync() {
	ssh $REMOTE_USER_HOST "rm -rf $REMOTE_SRC_DIR"
	rsync -avz --exclude={'.git/','logs/','venv/'} $LOCAL_SRC_DIR $REMOTE_USER_HOST:$REMOTE_SRC_DIR
	ssh $REMOTE_USER_HOST "cd $REMOTE_SRC_DIR && virtualenv venv && source venv/bin/activate && pip install -r requirements.txt && pip install --upgrade pip"
	inotifywait -m -r -e modify,create,delete --exclude '\.git|logs|venv' --format '%w%f' $LOCAL_SRC_DIR | while read file; do
		# Check if the changed file is not inside .git directory
		if [[ $file != *".git"* ]]; then
			rsync -avz --exclude={'.git/','logs/','venv/'} $LOCAL_SRC_DIR $REMOTE_USER_HOST:$REMOTE_SRC_DIR
		fi
	done &
	INOTIFY_PID=$!
}

# Function to run HTTP server
run_qemu() {
  ssh $REMOTE_USER_HOST 'pkill -f "qemu-system-x86_64"'
  if [ -n "$QEMU_FW_FILE" ]; then
    rsync -avz $QEMU_FW_FILE $REMOTE_USER_HOST:$REMOTE_SRC_DIR

    ssh $REMOTE_USER_HOST "export QEMU_FW_FILE=$REMOTE_SRC_DIR/$(basename $QEMU_FW_FILE) \
    && HDD_PATH=~/qemu-data/hdd.qcow2 \
    INSTALLER_PATH=~/qemu-data/ubuntu-24.04.1-desktop-amd64.iso \
    ${REMOTE_SRC_DIR}/scripts/ci/qemu-run.sh $1 $2 $3"

  else
    ssh $REMOTE_USER_HOST "${REMOTE_SRC_DIR}/scripts/ci/qemu-run.sh $1 $2 $3"
  fi
}

# Function to check if a command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Check for required commands
if ! command_exists rsync; then
	echo "rsync is not installed. Please install it."
	exit 1
fi

if ! command_exists inotifywait; then
	echo "inotify-tools is not installed. Please install it."
	exit 1
fi

# Start continuous synchronization in the background
start_sync

# Run QEMU
run_qemu "${SELF_TEST_TYPE}" "${SELF_TEST_ACTION}" "${SELF_TEST_FW}"

# After the QEMU and self-test script exits, kill the background sync process
kill $!
