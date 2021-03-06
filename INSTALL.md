# Installation

These are an aide-memoire right now, rather than comprehensive installation
instructions.

## Installing Erlang

Follow the instructions at
https://www.erlang-solutions.com/downloads/download-erlang-otp

## Installing postgres

sudo apt-get install postgresql

## Upstart script

See `init/blerg.conf`

## Install the DB

Read the top of `blerg.sql`.

## Backing up / Restoring the DB

This is useful for development, to clone the production database first:

On `prod`:

    pg_dump -C blerg -U blerg | bzip2 > blerg.pg_dump.bz2

On `dev`:

    scp prod:blerg.pg_dump.bz2 .
    sudo -u postgres dropdb blerg
    sudo -u postgres createdb blerg
    bunzip2 < blerg.pg_dump.bz2 | psql -U blerg

Note that this emits some warnings when transferring from Linux to OS X. Ignore them.

## Upgrading

On the dev box:

    make tarball
    scp blerg*.tar.gz prod:.

On production:

    # Log into the production box:
    ssh prod

    # Pull the new code:
    sudo bash
    cd /opt
    tar xfz path/to/blerg-whatever.tar.gz
    
    # Run migrations (not automatic at this point):
    psql -U blerg < migrations/whatever
    exit        # back to original user

    sudo restart blerg
