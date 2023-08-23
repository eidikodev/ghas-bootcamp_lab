#!/bin/bash

echo "Executing code scanning alert script..."
jq --version

organization="eidikodev"
github_api_url='https://api.github.com'

echo id, api_url, html_url, severity, name, description, security_severity_level, html_url > alerts.csv

START=1
total_pages=2

for (( c=$START; c<=$total_pages; c++ ))
do
	echo "=============Navigating Page number: $c============="
	list_repos_url="${github_api_url}/orgs/${organization}/repos?per_page=50&page=${c}"
	echo "List Repo URL: $list_repos_url"
    all_repo_list=$(curl --location --request GET -H 'Accept: application/vnd.github.v3+json' -H "Authorization: token $github_token" $list_repos_url)
    
	echo "${all_repo_list}" | jq -c ".[]" | while read repo; do
		repo_name=$(echo $repo | jq '.name' | tr -d '"')
		api_url=$(echo $repo | jq '.url' | tr -d '"')
        
        alerts_url="${api_url}/code-scanning/alerts"
        alerts_response=$(curl -sSLX GET -H "Authorization: token $github_token" "$alerts_url")
        
        echo "${alerts_response}" | jq -c ".[]" | while read alert; do
            id=$(echo $alert | jq -r '.rule.id')
            api_url=$(echo $alert | jq -r '.url')
            html_url=$(echo $alert | jq -r '.html_url')
            severity=$(echo $alert | jq -r '.rule.severity')
            name=$(echo $alert | jq -r '.rule.name')
            description=$(echo $alert | jq -r '.rule.description')
            security_severity_level=$(echo $alert | jq -r '.rule.security_severity_level')
            
            echo "${id}, ${api_url}, ${html_url}, ${severity}, ${name}, ${description}, ${security_severity_level}, ${html_url}" >> alerts.csv
        done
	done
done
