#!/bin/bash

echo "Executing code scanning alert script..."
jq --version

organization="eidikodev"
github_api_url='https://api.github.com'

echo id, repository_name, repository_url, created_at, closed_at, number, state, severity, tool, details_url, message, description, file_path, code, security_severity_level, api_url, html_url > alerts.csv

for repo in $(curl -sSLX GET -H "Authorization: token $github_token" "${github_api_url}/orgs/${organization}/repos?per_page=100" | jq -c '.[]'); do
    repo_name=$(echo "$repo" | jq -r '.name')
    repo_url=$(echo "$repo" | jq -r '.html_url')
    repo_alerts_url=$(echo "$repo" | jq -r '.url')/code-scanning/alerts

    for alert in $(curl -sSLX GET -H "Authorization: token $github_token" "$repo_alerts_url" | jq -c '.[]'); do
        id=$(echo "$alert" | jq -r '.rule.id')
        created_at=$(echo "$alert" | jq -r '.created_at')
        closed_at=$(echo "$alert" | jq -r '.closed_at')
        number=$(echo "$alert" | jq -r '.number')
        state=$(echo "$alert" | jq -r '.state')
        severity=$(echo "$alert" | jq -r '.severity')
        tool=$(echo "$alert" | jq -r '.tool')
        details_url=$(echo "$alert" | jq -r '.details_url')
        message=$(echo "$alert" | jq -r '.message')
        description=$(echo "$alert" | jq -r '.description')
        file_path=$(echo "$alert" | jq -r '.file.path')
        code=$(echo "$alert" | jq -r '.code')
        security_severity_level=$(echo "$alert" | jq -r '.security_severity_level')
        api_url=$(echo "$alert" | jq -r '.url')
        html_url=$(echo "$alert" | jq -r '.html_url')
        
        echo "${id}, ${repo_name}, ${repo_url}, ${created_at}, ${closed_at}, ${number}, ${state}, ${severity}, ${tool}, ${details_url}, ${message}, ${description}, ${file_path}, ${code}, ${security_severity_level}, ${api_url}, ${html_url}" >> alerts.csv
    done
done
