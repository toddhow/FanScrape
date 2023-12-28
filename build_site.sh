#!/bin/bash

# outputs to _site with the following structure:
# index.yml
# <scraper_id>.zip
# Each zip file contains the scraper.yml file and any other files in the same directory
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

    ignore=$(grep "^# ignore:" "$f" | cut -c 10- | sed -e 's/\r//')

    ignore="-x $ignore package"

    zip -r "$zipfile" . ${ignore} > /dev/null
    popd > /dev/null

    # write to spec index

  name: "fanscrape"
  version: $version
  date: $updated
  path: fanscrape.zip
  sha256: $(sha256sum "$zipfile" | cut -d' ' -f1)" >> "$outdir"/index.yml"

    echo "" >> "$outdir"/index.yml
}

buildScraper "$f"
