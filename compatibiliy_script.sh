#!/bin/zsh --no-rcs
# shellcheck shell=bash

# This script is a modified version of this script: https://github.com/macadmins/sofa/blob/main/tool-scripts/macOSCompatibilityCheck-EA.sh
# It is meant to provide output for Addigy custom facts about macOS compatibility based on the SOFA feed.

# Error Codes:
# 1: JSON Cache file not found 
# 2: JSON data could not be obtained during Python check
# 3: JSON data could not be obtained during Plist check

# Set LOG_MODE to false for simple number output (such as for Addigy custom facts which need just 1 line of output)
# Set LOG_MODE to true for verbose output, such as Addigy custom software or commands
LOG_MODE=false 


# Function to log output if LOG_MODE is set to true
function log {
    if [[ "$LOG_MODE" = true ]]; then
        echo "$1"
    fi
}

# Get current system OS
system_version=$( /usr/bin/sw_vers -productVersion )
system_os=$(cut -d. -f1 <<< "$system_version")
log "System Version: $system_version"

if [[ $system_os -ge 12 ]]; then
    # use plistlib
    os_compatibility="current"
else
    # use python 2.7
    os_compatibility="legacy"
    python_path="/usr/bin/python"
fi

# URL to the online JSON data
online_json_url="https://sofafeed.macadmins.io/v1/macos_data_feed.json"
user_agent="SOFA-macOSCompatibilityCheck/1.0"

# local store
json_cache_dir="/var/tmp/sofa"
json_cache="$json_cache_dir/macos_data_feed.json"
etag_cache="$json_cache_dir/macos_data_feed_etag.txt"

# ensure local cache folder exists
/bin/mkdir -p "$json_cache_dir"

# check local vs online using etag (only available on macOS 12+)
if [[ -f "$etag_cache" && -f "$json_cache" ]]; then
    etag_old=$(/bin/cat "$etag_cache")
    /usr/bin/curl --compressed --silent --etag-compare "$etag_cache" --etag-save "$etag_cache" --header "User-Agent: $user_agent" "$online_json_url" --output "$json_cache"
    etag_new=$(/bin/cat "$etag_cache")
    if [[ "$etag_old" == "$etag_new" ]]; then
        log "Cached ETag matched online ETag - cached json file is up to date"
    else
        log "Cached ETag did not match online ETag, so downloaded new SOFA json file"
    fi

elif [[ "$os_compatibility" == "legacy" ]]; then
    log "OS not compatible with e-tags, proceeding to download SOFA json file"
    /usr/bin/curl --compressed --location --max-time 3 --silent --header "User-Agent: $user_agent" "$online_json_url" --output "$json_cache"
else
    log "No e-tag cached, proceeding to download SOFA json file"
    /usr/bin/curl --compressed --location --max-time 3 --silent --header "User-Agent: $user_agent" "$online_json_url" --etag-save "$etag_cache" --output "$json_cache"
fi

if [[ ! -f "$json_cache" ]]; then
    log "Could not obtain data"
    echo "Error 1"
    exit
elif [[ "$os_compatibility" == "legacy" ]]; then
    if ! "$python_path" -c 'import sys, json; print json.load(sys.stdin)["UpdateHash"]' < "$json_cache" > /dev/null; then
        log "Could not obtain data"
        echo "Error 2"
        exit
    fi
elif ! /usr/bin/plutil -extract "UpdateHash" raw "$json_cache" > /dev/null; then
    log "Could not obtain data"
    echo "Error 3"
    exit
fi

# Get model (DeviceID)
model=$(/usr/sbin/sysctl -n hw.model)
log "Model Identifier: $model"

# check that the model is virtual or is in the feed at all
if [[ $model == "VirtualMac"* ]]; then
    # if virtual, we need to arbitrarily choose a model that supports all current OSes. Plucked for an M1 Mac mini
    model="Macmini9,1"
elif ! grep -q "$model" "$json_cache"; then
    log "Model not found in SOFA feed"
    echo "Unsupported"
    exit
fi

if [[ "$os_compatibility" == "current" ]]; then
    # identify the latest major OS (macOS 12+ method)
    latest_os=$(/usr/bin/plutil -extract "OSVersions.0.OSVersion" raw -expect string "$json_cache" | /usr/bin/head -n 1)
    # idenfity latest compatible major OS (macOS 12+ method)
    latest_compatible_os=$(/usr/bin/plutil -extract "Models.$model.SupportedOS.0" raw -expect string "$json_cache" | /usr/bin/head -n 1)
else
    # identify the latest major OS (macOS 11- method)
    latest_os=$("$python_path" -c 'import sys, json; print json.load(sys.stdin)["OSVersions"][0]["OSVersion"]' < "$json_cache" | /usr/bin/head -n 1)
    # idenfity latest compatible major OS (macOS 11- method)
    latest_compatible_os=$("$python_path" -c 'import sys, json; print(json.load(sys.stdin)["Models"]["'"$model"'"]["SupportedOS"][0])' < "$json_cache" | /usr/bin/head -n 1)
fi
log "Latest macOS: $latest_os"
log "Latest Compatible macOS: $latest_compatible_os"
trimmed_os_version=$(echo "$latest_compatible_os" | awk '{print $NF}')

echo "$trimmed_os_version"