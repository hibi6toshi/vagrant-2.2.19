#!/usr/bin/env bash

# packet and job configuration
export SLACK_USERNAME="Vagrant"
export SLACK_ICON="https://media.giphy.com/media/yIQ5glQeheYE0/200.gif"
export SLACK_TITLE="Vagrant-Spec Test Runner"
export PACKET_EXEC_DEVICE_NAME="${PACKET_EXEC_DEVICE_NAME:-spec-ci-boxes}"
export PACKET_EXEC_DEVICE_SIZE="${PACKET_EXEC_DEVICE_SIZE:-baremetal_0,baremetal_1,baremetal_1e}"
export PACKET_EXEC_PREFER_FACILITIES="${PACKET_EXEC_PREFER_FACILITIES:-iad1,iad2,ewr1,dfw1,dfw2,sea1,sjc1,lax1}"
export PACKET_EXEC_OPERATING_SYSTEM="${PACKET_EXEC_OPERATING_SYSTEM:-ubuntu_18_04}"
export PACKET_EXEC_PRE_BUILTINS="${PACKET_EXEC_PRE_BUILTINS:-InstallVagrant,InstallVirtualBox,InstallVmware,InstallHashiCorpTool,InstallVagrantVmware}"
export PACKET_EXEC_QUIET="1"
export PKT_VAGRANT_CLOUD_TOKEN="${VAGRANT_CLOUD_TOKEN}"
export VAGRANT_PKG_VERSION="2.2.7" # need to figure out how to make this latest instead
###


csource="${BASH_SOURCE[0]}"
while [ -h "$csource" ] ; do csource="$(readlink "$csource")"; done
root="$( cd -P "$( dirname "$csource" )/../" && pwd )"

. "${root}/.ci/common.sh"

pushd "${root}" > "${output}"

# Define a custom cleanup function to destroy any orphan guests
# on the packet device
function cleanup() {
    (>&2 echo "Cleaning up packet device")
    unset PACKET_EXEC_PERSIST
    pkt_wrap_stream "cd vagrant;VAGRANT_CWD=test/vagrant-spec/ VAGRANT_VAGRANTFILE=Vagrantfile.spec vagrant destroy -f" \
                "Vagrant command failed"
}

# Ensure we have a packet device to connect
echo "Creating packet device if needed..."

packet-exec info

if [ $? -ne 0 ]; then
    wrap_stream packet-exec create \
                "Failed to create packet device"
fi

echo "Finished creating spec test packet instance"
