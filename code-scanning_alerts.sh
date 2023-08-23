#!/bin/bash

echo "Fetching code scanning alerts for the organization..."

# Set your GitHub token here
github_token="$SECRET_TOKEN"

organization="eidikodev"
github_api_url="https://api.github.com"

# Fetch repositories for the organization
repos_url="${github_api_url}/orgs/${organization}/repos?per_page=100"
repos_response=$(curl -sSLX GET -H "Authorization: token $github_token" "$repos_url")

# Extract repository names from the response
repo_names=$(echo "$repos_response" | jq -r '.[].name')

# Loop through repositories and fetch code scanning alerts
echo "repo_name,alert_id,severity,name,description,created_at" > code_scanning_alerts.csv

for repo in $repo_names; do
    alerts_url="${github_api_url}/repos/${organization}/${repo}/code-scanning/alerts"
    alerts_response=$(curl -sSLX GET -H "Authorization: token $github_token" "$alerts_url")
    
    # Extract alerts information and write to CSV
    echo "$alerts_response" | jq -r '.alerts[] | [$repo, .databaseId, .severity, .rule.name, .rule.description, .createdAt] | @csv' >> code_scanning_alerts.csv
done

echo "Code scanning alerts fetched and saved to code_scanning_alerts.csv"
