#!/bin/bash

set -x  # Enable debugging mode

echo "Executing code scanning alert script..."

jq --version

organization="eidikodev"

github_api_url="https://api.github.com"

#code_scanning_alert_url_array=$(curl -sSLX GET -H "Authorization: token $github_token" "$github_api_url/orgs/$organization/code-scanning/alerts?per_page=100&page=2" | jq -r '.[] | .url')
curl -sSLX GET -H "Authorization: token $github_token" "$github_api_url/orgs/$organization/code-scanning/alerts?per_page=100&page=2"

# Replace 'API_RESPONSE_JSON' with the actual JSON response from the API
API_RESPONSE_JSON=$(curl -sSLX GET -H "Authorization: token $github_token" "$github_api_url/orgs/$organization/code-scanning/alerts?per_page=100&page=2")
URLS=$(echo "$API_RESPONSE_JSON" | jq -r '.[] | .url')
echo "Extracted URLs: $URLS"

echo id, api_url, html_url, severity, name, description, security_severity_level, html_url > code-scan_alert.csv

for url in $code_scanning_alert_url_array; do
    alert=$(curl -sSLX GET -H "Authorization: token $github_token" "$url")

    alert_line=$(echo "$alert" | jq '.rule | [.id, .severity, .name, .description, .security_severity_level] | @csv')

    html_url=$(echo "$alert" | jq -r '.html_url')

    id=$(echo "$alert" | jq -r '.rule.id')
    severity=$(echo "$alert" | jq -r '.rule.severity')
    name=$(echo "$alert" | jq -r '.rule.name')
    description=$(echo "$alert" | jq -r '.rule.description')
    security_severity_level=$(echo "$alert" | jq -r '.rule.security_severity_level')

    echo "${id}, ${url}, ${html_url}, ${severity}, ${name}, ${description}, ${security_severity_level}, ${html_url}" >> code-scan_alert.csv
done
