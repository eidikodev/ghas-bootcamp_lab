#!/bin/bash

echo "Executing code scanning alert script..."
jq --version

organization="eidikodev"
github_api_url='https://api.github.com'

echo "id, repository_name, repository_url, created_at, closed_at, number, state, severity, tool, details_url, message, description, file_path, code, name, api_url, html_url, severity, name, description, security_severity_level, html_url" > alerts.csv

START=1
total_pages=2

for (( c=$START; c<=$total_pages; c++ ))
do
    echo "=============Navigating Page number: $c============="
    list_repos_url="${github_api_url}/orgs/${organization}/repos?per_page=50&page=${c}"
    echo "List Repo URL: $list_repos_url"
    all_repo_list=$(curl --location --request GET -H 'Accept: application/vnd.github.v3+json' -H "Authorization: token $github_token" $list_repos_url)

    echo "${all_repo_list}" | jq -c ".[]" | while read repo; do
        repo_name=$(echo "$repo" | jq -r '.name')
        api_url=$(echo "$repo" | jq -r '.url')

        alerts_url="${api_url}/code-scanning/alerts"
        alerts_response=$(curl -sSLX GET -H "Authorization: token $github_token" "$alerts_url")

        echo "${alerts_response}" | jq -c ".[]" | while read alert; do
            id=$(echo "$alert" | jq -r '.rule.id')
            repository_name=$(echo "$alert" | jq -r '.repository.name')
            repository_url=$(echo "$alert" | jq -r '.repository.html_url')
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
            severity=$(echo "$alert" | jq -r '.rule.severity')
            name=$(echo "$alert" | jq -r '.rule.name')
            
            # Sanitize fields to avoid newline characters causing empty rows
            repository_name=$(echo "$repository_name" | tr -d '\n')
            message=$(echo "$message" | tr -d '\n')
            description=$(echo "$description" | tr -d '\n')
            file_path=$(echo "$file_path" | tr -d '\n')
            code=$(echo "$code" | tr -d '\n')
            
            echo "${id}, ${repository_name}, ${repository_url}, ${created_at}, ${closed_at}, ${number}, ${state}, ${severity}, ${tool}, ${details_url}, ${message}, ${description}, ${file_path}, ${code}, ${name}, ${api_url}, ${html_url}, ${severity}, ${name}, ${security_severity_level}, ${html_url}" >> alerts.csv
        done
    done
done
