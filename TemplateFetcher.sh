#!/bin/bash

# Replace <YOUR_GITHUB_TOKEN> with your actual GitHub token
TOKEN="<YOUR_GITHUB_TOKEN>"
REPO="projectdiscovery/nuclei-templates"
OUTPUT_DIR="./templates"
PREVIOUS_FILE_LIST="./previous_files.txt"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to send a notification
send_notification() {
  # Add your notification logic here (e.g., sending an email, using a messaging service, etc.)
  echo "$1"
}

# Function to download a YAML file given the URL and desired filename
download_yaml() {
  local YAML_URL=$1
  local FILE_NAME=$2
  local OUTPUT_DIR=$3

  # Download the YAML file and save it to the output directory
  OUTPUT_FILE="$OUTPUT_DIR/$FILE_NAME"
  wget -q --header="Authorization: token $TOKEN" "$YAML_URL" -O "$OUTPUT_FILE"
}

# Check if the previous file list exists
if [ -f "$PREVIOUS_FILE_LIST" ]; then
  # Read the previous file list into an array
  mapfile -t PREVIOUS_FILES < "$PREVIOUS_FILE_LIST"
else
  # Create an empty array if the previous file list doesn't exist
  PREVIOUS_FILES=()
fi

# Get the list of commit hashes from the GitHub API
COMMITS=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$REPO/commits" | grep '"sha":' | awk -F'"' '{print $4}')

# Array to store the newly downloaded files
NEW_FILES=()

# Iterate over the commit hashes and download YAML files in parallel
for COMMIT in $COMMITS; do
  # Get the commit details from the GitHub API
  COMMIT_DETAILS=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/repos/$REPO/commits/$COMMIT")

  # Extract the YAML file URL and filename from the commit details
  YAML_URL=$(echo "$COMMIT_DETAILS" | grep -oP '(?<="raw_url": ")[^"]+')
  FILE_NAME=$(echo "$COMMIT_DETAILS" | grep -oP '(?<="filename": ")[^"]+' | sed 's#.*/##')

  # Check if the file has the .yaml extension and has not already been downloaded
  if [[ $FILE_NAME == *.yaml && ! " ${PREVIOUS_FILES[@]} " =~ " $FILE_NAME " ]]; then
    # Download the YAML file
    download_yaml "$YAML_URL" "$FILE_NAME" "$OUTPUT_DIR"
    NEW_FILES+=("$FILE_NAME")
    PREVIOUS_FILES+=("$FILE_NAME")
  fi
done

# Save the updated list of downloaded files for future comparison
printf "%s\n" "${PREVIOUS_FILES[@]}" > "$PREVIOUS_FILE_LIST"

# Check if new files were downloaded
if [ ${#NEW_FILES[@]} -gt 0 ]; then
  # Create a new directory with a timestamped name
  TIMESTAMP=$(date +"%Y%m%d%H%M%S")
  NEW_DIR="$OUTPUT_DIR/$TIMESTAMP"

  # Move the downloaded files to the new directory
  mkdir -p "$NEW_DIR"
  for FILE in "${NEW_FILES[@]}"; do
    mv "$OUTPUT_DIR/$FILE" "$NEW_DIR/$FILE"
  done

  send_notification "New files detected: ${NEW_FILES[*]}. Saved in directory: $NEW_DIR"
else
  send_notification "No new files detected"
fi
