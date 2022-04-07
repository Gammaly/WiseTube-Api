# WiseTube-Api

API to store and retrieve wisetube link entity.

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/link/`: returns all link IDs
- GET `api/v1/link/[ID]`: returns details about a single link with given ID
- POST `api/v1/link/`: creates a new link

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```