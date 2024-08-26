#!/bin/bash

# outputs to _site with the following structure:
# index.yml
# This script is from the stashapp/CommunityScrapers repo https://github.com/stashapp/CommunityScrapers/blob/stable/build_site.sh

# Directory where the repo is cloned
repo_dir=$(pwd)
stable_dir="$1"

buildScraper()
{
    branch=$1

    echo "Processing branch: $branch"

    # Checkout the branch
    git checkout $branch
    git pull origin $branch

    # Get the latest commit hash and date for the branch
    version=$(git log -n 1 --pretty=format:%h)
    updated=$(TZ=UTC0 git log -n 1 --date="format-local:%F %T" --pretty=format:%ad)

    # Create a directory for the output (if not already existing)
    outdir="${stable_dir}/output_${branch}"
    mkdir -p "$outdir"

    # Define the zip file path
    zipfile=$(realpath "$outdir/fanscrape_${branch}.zip")

    # Zip the specific files
    zip -r "$zipfile" fanscrape.py fanscrape.yml requirements.txt

    # Determine the name to use in index.yml
    if [ "$branch" = "main" ]; then
        name="fanscrape"
    else
        name="fanscrape-$branch"
    fi

    # Write to index.yml
    echo "- id: $name
  name: \"$name\"
  version: $version
  date: $updated
  path: output_${branch}/fanscrape_${branch}.zip
  sha256: $(sha256sum "$zipfile" | cut -d' ' -f1)" >> "$stable_dir"/index.yml

    echo "" >> "$stable_dir"/index.yml
}

# Ensure the stable directory exists and clear previous outputs
rm -rf "$stable_dir"
mkdir -p "$stable_dir"

for remote in `git branch -r | grep -v /HEAD | grep -v $(git rev-parse --abbrev-ref HEAD)`; do git checkout --track $remote ; done
# Save a list of all branches to the branches variable
branches=$(git for-each-ref --format='%(refname:short)' refs/heads/)

# Loop over each branch and process it
for branch in $branches; do
    buildScraper $branch
done

# Print completion message
echo "Zipping complete, and index.yml has been updated for all branches."