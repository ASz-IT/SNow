#!/bin/bash

# ServiceNow Change Request Details Fetcher
# Usage: SNOW_INSTANCE=<instance> SNOW_USERNAME=<username> SNOW_PASSWORD=<password> ./get_chg_details.sh <change_number>
# 
# Environment Variables:
#   SNOW_INSTANCE - Your ServiceNow instance name (e.g., your-instance)
#   SNOW_USERNAME - Your ServiceNow username
#   SNOW_PASSWORD - Your ServiceNow password

set -e

# Check if all required environment variables are set
if [ -z "$SNOW_INSTANCE" ]; then
    echo "Error: SNOW_INSTANCE environment variable is not set"
    echo "Usage: SNOW_INSTANCE=<instance> SNOW_USERNAME=<username> SNOW_PASSWORD=<password> $0 <change_number>"
    echo "Example: SNOW_INSTANCE=your-instance SNOW_USERNAME=admin SNOW_PASSWORD=yourpassword $0 CHG0001234"
    exit 1
fi

if [ -z "$SNOW_USERNAME" ]; then
    echo "Error: SNOW_USERNAME environment variable is not set"
    echo "Usage: SNOW_INSTANCE=<instance> SNOW_USERNAME=<username> SNOW_PASSWORD=<password> $0 <change_number>"
    echo "Example: SNOW_INSTANCE=your-instance SNOW_USERNAME=admin SNOW_PASSWORD=yourpassword $0 CHG0001234"
    exit 1
fi

if [ -z "$SNOW_PASSWORD" ]; then
    echo "Error: SNOW_PASSWORD environment variable is not set"
    echo "Usage: SNOW_INSTANCE=<instance> SNOW_USERNAME=<username> SNOW_PASSWORD=<password> $0 <change_number>"
    echo "Example: SNOW_INSTANCE=your-instance SNOW_USERNAME=admin SNOW_PASSWORD=yourpassword $0 CHG0001234"
    exit 1
fi

# Check if change number argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: SNOW_INSTANCE=<instance> SNOW_USERNAME=<username> SNOW_PASSWORD=<password> $0 <change_number>"
    echo "Example: SNOW_INSTANCE=your-instance SNOW_USERNAME=admin SNOW_PASSWORD=yourpassword $0 CHG0001234"
    exit 1
fi

INSTANCE="$SNOW_INSTANCE"
USERNAME="$SNOW_USERNAME"
PASSWORD="$SNOW_PASSWORD"
CHANGE_NUMBER="$1"

# Validate instance format
if [[ ! "$INSTANCE" =~ ^[a-zA-Z0-9-]+$ ]]; then
    echo "Error: Instance name should contain only letters, numbers, and hyphens"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    echo "macOS: brew install jq"
    echo "Ubuntu/Debian: sudo apt-get install jq"
    echo "CentOS/RHEL: sudo yum install jq"
    exit 1
fi

echo "Fetching details for change request: $CHANGE_NUMBER"
echo "Instance: $INSTANCE"
echo "----------------------------------------"

# Make the API call to ServiceNow
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -u "$USERNAME:$PASSWORD" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    "https://$INSTANCE.service-now.com/api/now/table/change_request?sysparm_query=number=$CHANGE_NUMBER&sysparm_display_value=true&sysparm_exclude_reference_link=true")

# Extract HTTP status code (last line)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
# Extract response body (all lines except last)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

# Check if the request was successful
if [ "$HTTP_CODE" -eq 200 ]; then
    # Check if any records were found
    RECORD_COUNT=$(echo "$RESPONSE_BODY" | jq '.result | length')
    
    if [ "$RECORD_COUNT" -eq 0 ]; then
        echo "No change request found with number: $CHANGE_NUMBER"
        exit 1
    elif [ "$RECORD_COUNT" -eq 1 ]; then
        echo "Change Request Details:"
        echo "========================"
        
        # Extract and display key fields
        echo "$RESPONSE_BODY" | jq -r '.result[0] | {
            "Number": .number,
            "Short Description": .short_description,
            "State": .state,
            "Priority": .priority,
            "Category": .category,
            "Requested By": .requested_by,
            "Assigned To": .assigned_to,
            "Created": .sys_created_on,
            "Updated": .sys_updated_on,
            "Start Date": .start_date,
            "End Date": .end_date,
            "Description": .description,
            "Justification": .justification,
            "Risk": .risk,
            "Impact": .impact,
            "Urgency": .urgency
        }' | jq -r 'to_entries[] | "\(.key): \(.value // "N/A")"'
        
        echo ""
        echo "Full JSON Response:"
        echo "==================="
        echo "$RESPONSE_BODY" | jq '.'
        
    else
        echo "Multiple records found. Showing all:"
        echo "$RESPONSE_BODY" | jq '.result[] | {number, short_description, state, priority}'
    fi
    
elif [ "$HTTP_CODE" -eq 401 ]; then
    echo "Error: Authentication failed. Please check your username and password."
    exit 1
elif [ "$HTTP_CODE" -eq 403 ]; then
    echo "Error: Access forbidden. Please check your permissions."
    exit 1
elif [ "$HTTP_CODE" -eq 404 ]; then
    echo "Error: Service not found. Please check your instance name."
    exit 1
else
    echo "Error: HTTP $HTTP_CODE"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi
