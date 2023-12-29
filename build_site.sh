#!/bin/bash

# outputs to _site with the following structure:
# index.yml
# This script is from the stashapp/CommunityScrapers repo https://github.com/stashapp/CommunityScrapers/blob/stable/build_site.sh

outdir="$1"
if [ -z "$outdir" ]; then
    outdir="_site"
fi

rm -rf "$outdir"
mkdir -p "$outdir"

buildScraper() 
{
    f=$1
    dir=$(dirname "$f")

    echo "Processing $scraper_id"

    # create a directory for the version
    version=$(git log -n 1 --pretty=format:%h -- "$dir")
    updated=$(TZ=UTC0 git log -n 1 --date="format-local:%F %T" --pretty=format:%ad -- "$dir")

    zipfile=$(realpath "$outdir/fanscrape.zip")

    zip -r "$zipfile" fanscrape.py fanscrape.yml requirements.txt

    # write to spec index
    
    echo $outdir

    echo "- id: fanscrape
  name: "fanscrape"
  version: $version
  date: $updated
  path: fanscrape.zip
  sha256: $(sha256sum "$zipfile" | cut -d' ' -f1)" >> "$outdir"/index.yml

    echo "" >> "$outdir"/index.yml
}

buildScraper "$f"
