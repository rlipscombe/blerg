# Installation

## Installing Erlang

Follow the instructions at https://www.erlang-solutions.com/downloads/download-erlang-otp

## Installing postgres

sudo apt-get install postgresql

## Upstart script

See `scripts/blerg.conf`

## Install the DB

Read the top of `blerg.sql`.

## Backing up / Restoring the DB

This is useful for development, to clone the production database first:

On `prod`:

    pg_dump -C blerg -U blerg | bzip2 > blerg.pg_dump.bz2

On `dev`:

    scp prod:blerg.pg_dump.bz2 .
    sudo -l postgres dropdb blerg
    sudo -l postgres createdb blerg
    bunzip2 < blerg.pg_dump.bz2 | psql -U blerg

