#!/bin/bash

STAND_IP=${RTE_IP:=192.168.4.233}
PXE_IP=${PXE_IP:=192.168.20.206}
PLATFORM=${PLATFORM:=msi-z690-a-ddr5}
AUTOFILL=${AUTOFILL:="0"}
CLOUD=${CLOUD:="0"}
SNIPEIT=${SNIPEIT:="0"}

if [ $# -lt 1 ]; then
    echo ""
    echo "Usage: ./regression.sh <coreboot_rom>"
    echo "  <coreboot_rom> - full path to coreboot.rom binary"
    echo ""
    echo "Environment variables:"
    echo "  STAND_IP - STAND IP address (default: $RTE_IP)"
    echo "  PXE_IP   - PXE server IP address (default: $PXE_IP)"
    echo "  PLATFORM   - platform specific config - available:"
    echo "               - MSI PRO Z690-A DDR5: msi-pro-z690-a-ddr5"
    echo "  AUTOFILL - fill up spreadsheet with the test results (default: $AUTOFILL)"
    echo "  CLOUD - send logs from test to the cloud"
    exit
fi

if [ $AUTOFILL = "0" ]; then
    echo "AUTOFILL set to \"$AUTOFILL\". Spreadsheet will NOT be automatically updated"
else
    echo "AUTOFILL set to \"$AUTOFILL\". Spreadsheet will be automatically updated"
fi

if [ $CLOUD = "0" ]; then
    echo "SENDING LOGS TO THE CLOUD set to \"$CLOUD\". Logs will NOT be automatically sent"
else
    echo "SENDING LOGS TO THE CLOUD set to \"$CLOUD\". Logs will be automatically sent"
fi

if [ ! $(command -v robot) ]; then
    echo "ERROR: robot command doesn't exist. Please load virtualenv with robot"
    echo "framework installed"
    exit 1
fi

COREBOOT_ROM=$1

if [ ! -f $COREBOOT_ROM ]; then
    echo "ERROR: file $COREBOOT_ROM doesn't exist"
    exit 1
fi

COREBOOT_VERSION=$(strings ${COREBOOT_ROM} |grep COREBOOT_ORIGIN_GIT_TAG| tr "\n" "+" | cut -d" " -f3|tr -d \")
if [ -z "$COREBOOT_VERSION" ]; then
	COREBOOT_VERSION=$(strings ${COREBOOT_ROM} |grep CONFIG_LOCALVERSION| tr "\n" "+" | cut -d"=" -f2|tr -d \")
	if [ -z "$COREBOOT_VERSION" ]; then
		COREBOOT_VERSION=$(strings ${COREBOOT_ROM} |grep -w COREBOOT_VERSION| tr "\n" "+" | cut -d" " -f3|tr -d \")
	fi
fi

COREBOOT_VERSION=${COREBOOT_VERSION%+*}

echo "$PLATFORM regression against coreboot $COREBOOT_VERSION on $RTE_IP"

if [ -d $PLATFORM ]; then
    rm -rf $PLATFORM
fi

mkdir $PLATFORM

# checkout platfom on snipeIT reservation system
./snipeit out $RTE_IP jenkins
if [ $? -ne 0 ]; then
   echo "snipeIT scripts not found or error occured. Please check snipeIT reservation system manually
   or install from
   https://gitlab.com/3mdeb/rte/docs/blob/master/docs/snipeIT_theory_of_operation.md#reservation-system-via-terminal"
   exit 1
fi

LOG_PREFIX="$PLATFORM/log-$COREBOOT_VERSION"
REPORT_PREFIX="$PLATFORM/report-$COREBOOT_VERSION"
OUTPUT_PREFIX="$PLATFORM/output-$COREBOOT_VERSION"
RF_STD_OPTIONS="-L TRACE -v rte_ip:$RTE_IP -v pxe_ip:$PXE_IP -v platform:$PLATFORM -v config:$CONFIG -v firmware:$FIRMWARE -v snipeit:no"

START_TIME=`date +%s`

robot -o ${OUTPUT_PREFIX}-dasharo-compatibility -r ${REPORT_PREFIX}-dasharo-compatibility \
	-l ${LOG_PREFIX}-dasharo-compatibility.html $RF_STD_OPTIONS -v fw_file:$COREBOOT_ROM \
	-v coreboot_version:$COREBOOT_VERSION ./dasharo-compatibility

END_TIME=`date +%s`
RUNTIME=$((END_TIME-START_TIME))
((H = RUNTIME / 3600))
((M = RUNTIME % 3600 / 60))
((S = RUNTIME % 3600 % 60))

echo -e "\n$PLATFORM regression against coreboot $COREBOOT_VERSION on $RTE_IP"
echo -e "Elapsed time:" $H"h" $M"m" $S"s\n"

# checkin platform on snipeIT reservation system
./snipeit in $RTE_IP

# Take credentials from CI variables
user=
password=
# If credentails.py exists use credentials specified there
if [ -f credentials.py ]; then
    source credentials.py
fi

UPLOADER_URL="https://cloud.3mdeb.com/remote.php/dav/files/gitlabci-bot/projects/3mdeb/Dasharo/TAT/regression-logs/${PLATFORM}"
zip ${PLATFORM}/${PLATFORM}-logs.zip ${PLATFORM}/log* ${PLATFORM}/out*
curl -k -u $user:$password -X MKCOL ${UPLOADER_URL}/${COREBOOT_VERSION}/
curl --fail -k -u $user:$password -T ${PLATFORM}/${PLATFORM}-logs.zip ${UPLOADER_URL}/${COREBOOT_VERSION}/
