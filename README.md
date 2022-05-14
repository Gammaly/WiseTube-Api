# WiseTube API

API to store and retrieve confidential development files (configuration, credentials)

## Routes

All routes return Json

- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST `api/v1/accounts`: Create a new account
- GET  `api/v1/playlists/[playlist_id]/links/[link_id]`: Get a link
- GET  `api/v1/playlists/[playlist_id]/links`: Get list of links for playlist
- POST `api/v1/playlists/[playlist_id]/links`: Upload link for a playlist
- GET  `api/v1/playlists/[playlist_]`: Get information about a playlist
- GET  `api/v1/playlists`: Get list of all playlists
- POST `api/v1/playlists`: Create new playlist

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this playlist:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release?
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this playlist:

```shell
rake db:seed
```

## Execute

Launch the API using:

```shell
rackup
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release?
```