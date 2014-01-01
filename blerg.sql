/*
 Add "local all blerg trust" to pg_hba.conf
 Also "host all blerg 127.0.0.1/32 trust" to pg_hba.conf

 echo "CREATE ROLE blerg LOGIN CREATEDB" | sudo -u postgres psql
 sudo -u postgres dropdb blerg
 echo "CREATE DATABASE blerg" | sudo -u postgres psql
 psql -U blerg < blerg.sql
*/

CREATE TABLE users (
  id serial primary key,
  name varchar(80)
);

CREATE TABLE posts (
  id serial primary key,
  url varchar(80),
  title varchar(250),
  author_id integer references users(id),
  created_at timestamp,
  body text
);

INSERT INTO users(id, name) VALUES(1, 'roger');

