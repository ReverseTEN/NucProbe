#!/bin/bash

nuclei_templates="/root/nuclei-templates"
output_dir="./output"
previous_output="$output_dir/previous_output.txt"
#diff_output="$output_dir/diff_output.txt"
log_file="$output_dir/scan_log.txt"
update_log="$output_dir/update_log.txt"
targets_file="targets.txt"
templates_version_file="$output_dir/templates_version.txt"
DIRECTORY="./templates"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Function to send notifications
send_notification() {
    echo -e "$1" | notify -silent -id nucprobe -bulk
}

# Function to update Nuclei engine
update_engine() {
    log "Checking for Nuclei engine update..."
    current_version=$(nuclei -version | awk '{print $3}')
    latest_version=$(curl -s https://api.github.com/repos/projectdiscovery/nuclei/releases/latest | grep tag_name | awk '{print $2}' | tr -d '",')
    if [[ "$current_version" == "$latest_version" ]]; then
        log "Nuclei engine is already up to date."
        send_notification "Nuclei engine is already up to date."
        return 0
    else
        log "Nuclei engine update found. Updating to version $latest_version..."
        update_output=$(nuclei -update 2>&1)
        if [[ $update_output =~ "nuclei is already updated to latest version" ]]; then
            log "Nuclei engine is already up to date."
            send_notification "Nuclei engine is already up to date."
            return 0
        else
            log "Nuclei engine update completed."
            send_notification "Nuclei engine update completed,Starting nuclei scanning with new engine."
            return 1
        fi
    fi
}

update_templates() {
    log "Checking for Nuclei templates update..."
    current_templates_version=$(nuclei -templates-version 2>&1)
    stored_templates_version=$(cat "$templates_version_file" 2>/dev/null)
    
    if [[ -z "$stored_templates_version" ]]; then
        log "No stored templates version found. Updating templates..."
        send_notification "No stored templates version found. Updating templates..."
        nuclei -update-templates >> "$update_log" 2>&1
        log "Nuclei templates update completed."
        send_notification "Nuclei templates update completed,Starting nuclei scanning with new templates."
        echo "$current_templates_version" > "$templates_version_file"  # Update the stored templates version
        return 1
    elif [[ "$current_templates_version" != "$stored_templates_version" ]]; then
        log "Nuclei templates update found. Updating..."
        send_notification "Nuclei templates update found. Updating..."
        nuclei -update-templates >> "$update_log" 2>&1
        log "Nuclei templates update completed."
        send_notification "Nuclei templates update completed,Starting nuclei scanning with new templates."
        echo "$current_templates_version" > "$templates_version_file"  # Update the stored templates version
        return 1
    else
        log "Nuclei templates are already up to date."
        send_notification "Nuclei templates are already up to date."
        if [[ -z "$stored_templates_version" ]]; then
            echo "$current_templates_version" > "$templates_version_file"  # Update the stored templates version
        fi
        return 0
    fi
}


# Function to perform Nuclei scan
perform_scan() {
    local current_output="$1"
    log "Running Nuclei scan on targets..."
    nuclei -t "$nuclei_templates" -l "$targets_file" -o "$current_output" -severity low,medium,high,critical,unknown >> "$log_file" 2>&1
    if [[ $? -eq 0 ]]; then
        log "Nuclei scan completed. Output saved to $current_output"
    else
        log "Nuclei scan failed. Check $log_file for details."
    fi
}


# Function to compare current and previous outputs
compare_outputs() {
    local current_output="$1"
    if [[ -f "$previous_output" && -f "$current_output" ]]; then
        added_output=$(cat "$current_output" | anew "$previous_output")
        if [[ -z "$added_output" ]]; then
            log "No new items found in the current output."
            send_notification "No new items found in the current output."
        else
            log "New items found in the current output and updated in $previous_output"

            summary=$(echo "$added_output" | awk '{print "- Added:", $0}')
            send_notification "New items added:\n\`\`\`$summary\`\`\`"

        fi
    fi
}
TemplateFetcher() {
  local core_output=$(./TemplateFetcher.sh)

  if [[ "$core_output" == "No new files detected" ]]; then
    # No new files found, send message on Discord
    send_notification "No new templates found in the repository."
  else
    # New files found, run Nuclei scan against new templates
    # Send notification and Discord message
    send_notification "New templates detected. Starting nuclei scanning with new templates."

    # Find the last timestamped directory
    LAST_DIR=$(ls -td "$DIRECTORY"/*/ | head -n 1)

    # Check if any timestamped directory exists
    if [ -n "$LAST_DIR" ]; then
      LAST_TIMESTAMP=$(basename "$LAST_DIR")
      echo "Last timestamped directory: $LAST_TIMESTAMP"

      # Run Nuclei scan and capture the output
      scan_output=$(nuclei -t "$DIRECTORY/$LAST_TIMESTAMP" -l "$targets_file" -o "$current_output" -severity low,medium,high,critical,unknown 2>&1)

      if [ -z "$scan_output" ]; then
        # Scan output is empty, send message indicating no findings
        send_notification "Nuclei scan completed. No findings were detected."
      else
        # Scan output is not empty, send the output as a notification
        send_notification "Nuclei scan completed with findings:\n\`\`\`$scan_output\`\`\`"
        
      fi
    else
      echo "No timestamped directories found"
    fi
  fi
}

TemplateFetcher

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Check if previous output file exists
if [[ ! -f "$previous_output" ]]; then
    # Scenario 1: Previous output not found
    current_templates_version=$(nuclei -templates-version 2>&1)
    stored_templates_version=$(cat "$templates_version_file" 2>/dev/null)
    echo "$current_templates_version" > "$templates_version_file"
    perform_scan "$previous_output"

else
    # Check for Nuclei engine update
    update_engine_status=0
    if ! update_engine; then
        update_engine_status=1
    fi

    # Check for Nuclei templates update
    update_templates_status=0
    if ! update_templates; then
        update_templates_status=1
    fi

    # If either the engine or templates need updating, perform scan
    if [[ $update_engine_status -eq 1 || $update_templates_status -eq 1 ]]; then
        # Run Nuclei scan and save the output
        current_output="$output_dir/output_$(date +'%Y%m%d%H%M%S').txt"
        perform_scan "$current_output"

        # Compare the current output with the previous output
        compare_outputs "$current_output"
    else
        log "No updates found. Skipping Nuclei scan."
    fi
fi
