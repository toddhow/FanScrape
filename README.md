# FanScrape (FansDB)

> [!NOTE]\
> This a fork of [dc_onlyfans_fansdb](https://github.com/stashapp/CommunityScrapers/tree/master/scrapers/dc_onlyfans_fansdb)

This script is a companion to the OnlyFans/Fansly data scrapers by DIGITALCRIMINAL and derivatives.\
Above tools download posts from OnlyFans/Fansly and save metadata to 'user_data.db' SQLite files.

> [!NOTE]\
> This script requires python3, stashapp-tools, and sqlite3.

## Scraper Support

[UltimaHoarder/UltimaScraper](https://github.com/UltimaHoarder/UltimaScraper)

[datawhores/OF-Scraper](https://github.com/datawhores/OF-Scraper)

> [!IMPORTANT]\
> If you are using datawhores/OF-Scraper you have two choices.
> Either you will need to change your scraper config or add a setting to the [config.json](#configuration) file.
> The options you need to change for OF-scraper can be found below.

```JSON
"dir_format": "{sitename}/{model_username}/{responsetype}/{value}/{mediatype}",
"metadata": "{save_location}/{sitename}/{model_username}/Metadata",
```

## Installation

> [!WARNING] 
> ***Breaking Change:***
> As of commit `76f80f4`, this code requires the Python module `markdown` installed where Stash runs (this could be inside your docker container). Likely a command such as:
> ```shell
> pip install markdown
> ```
> or
> ```shell
> pip3.12 install markdown --break-system-packages
> ```

### Managed

- Go to Settings > Metadata Providers > Available Scrapers.

- Click the `Add Source` button.

- Insert the following values into their corresponding field
```
Name: FanScrape
Source URL: https://toddhow.github.io/FanScrape/stable/index.yml
Local Path: fanscrape
```

- Select FanScrape, then press the `Install` button.

### Manual

Instructions for manually install scrapers can be found in [Stash's Documentation](https://docs.stashapp.cc/add-ons/scrapers/#installation)

## Scenes

The post information for scenes will be scraped from the metadata database based on file name.

Currently the scraper returns the following information for scenes:

- Title
- Details
- Date
- Code
- Studio
- URLs
- Performers
- Tags

Please refer to [Post Metadata](#post-metadata) for more information.

## Galleries

The post information for galleries will be scraped from the metadata database based on directory.

> [!IMPORTANT]\
> Since galleries are matched on directory, each post should be contained in a separate directory.

Currently the scraper returns the following information for galleries:

- Title
- Details
- Date
- Studio
- URLs
- Performers
- Tags

Please refer to [Post Metadata](#post-metadata) for more information.

## Post Metadata

### Title

In all cases, the title will be truncated on word boundaries (if possible) up to the configured `max_title_length` in `config.json` (default 64 characters).

- When post contains no text: `<username> - <post_date> [(<index_in_post>)]`\
  Example: `jonsnow - 2023-10-16 (2)`
- When first line of post text contains less than six (6) characters: `<first_line> - <post_date> [(<index_in_post>)]`\
  Example: `Hi! - 2023-10-16`
- When first line of post text does not contain alpha-numeric characters: `<first_line> - <post_date> [(<index_in_post>)]`\
  Example: `❤️❤️❤️❤️❤️❤️❤️❤️ - 2023-10-16 (4)`
- Else: `<first_line> [(<index_in_post>)]`\
  Example: `Lorem ipsum dolor sit amet, consectetur adipiscing elit.`

### Details

The details will contain the entirety of the post text.

### Date

The date will contain the date on which the post was created.

### Code

The code will contain the unique file id based on the value in either `<link>` or `<linked>` columns of the `medias` table.

### Studio

The creator studio name will be set to the following: `<username> (<network>)` e.g. `jonsnow (OnlyFans)`\
The creator studio URL will be set to the following:

- OnlyFans: `https://onlyfans.com/<username>`
- Fansly: `https://fansly.com/<username>`

The parent studio name will be set to the following: `<network> (network)` e.g. `Fansly (network)`\
The parent studio URL will be set to the following:

- OnlyFans: `https://onlyfans.com/`
- Fansly: `https://fansly.com/`

### URLs

For scenes and galleries, the URL will be set to the following:

- OnlyFans: `https://onlyfans.com/<post_id>/<username>`
- Fansly: `https://fansly.com/post/<post_id>`

### Performers

The performer username is taken from the name of the folder proceeding "OnlyFans" or "Fansly".

Example:\
`D:\stash-library\of-scraper\OnlyFans\<username>\...`

> [!NOTE]\
> The only performer that is being matched is the "owner" of the profile.

The scraper will try to resolve performer names by searching for performers with an alias matching the username.

By default, the scraper will search recursively from the performer directory for `.jpg` and `.png` files and base64 encode up to three (3) images for use as a performer image. These files are (by default) cached for 5 minutes by saving the base64 encoded images to disk to speed up bulk scraping.

If desired this behavior can be tweaked by changing these values in `config.json`:

```
  "max_performer_images": 3   # Maximum performer images to generate.
  "cache_time": 300           # Image expiration time (in seconds).
  "cache_dir": "cache"        # Directory to store cached base64 encoded images.
  "cache_file": "cache.json"  # File to store cache information in.
```

### Tags

By default, the scraper will tag scenes and galleries sent as messages with the tag `[FS: Messages]`.

This behaviour is configurable by changing these values in `config.json`:

```
  "tag_messages": True,                   # Whether to tag messages.
  "tag_messages_name": "[FS: Messages]",  # Name of tag for messages.
```

## Configuration

> [!IMPORTANT]\
> If you have enabled password protection on your Stash instance, filling in the `apikey` is required.

On first run, the scraper will write a default `config.json` file if it does not already exist.

Additionally, the `cache_dir` and `cache_file` will be created if they do not yet exist.

The values in the default config are as follows:

```
{
    "stash_connection": {
        "scheme": "http",
        "host": "localhost",
        "port": 9999,
        "apikey": ""
    },
    "max_title_length": 64,                 # Maximum length for scene/gallery titles.
    "tag_messages": True,                   # Whether to tag messages.
    "tag_messages_name": "[FS: Messages]",  # Name of tag for messages.
    "max_performer_images": 3,              # Maximum performer images to generate.
    "cache_time": 300,                      # Image expiration time (in seconds).
    "cache_dir": "cache",                   # Directory to store cached base64 encoded images.
    "cache_file": "cache.json",             # File to store cache information in.
    "meta_base_path": None,                 # Base path to search for 'user_data.db' files.
    "direct_db": {
        "override": False,
        "db_format": "/path/to/the/{network}/{username}/Metadata/user_data.db", # Format of the database path.
    },  # Allow overriding the database path.
}
```

## Thanks

Thank you to [WithoutPants](https://github.com/WithoutPants) for originally writing the script, and to [xantor](https://github.com/xantror) for maintaining the script as well as writing the README.
Additionally [Jakan-Kink](https://github.com/Jakan-Kink), who has been making some significant updates since the beginning of August 2024.
