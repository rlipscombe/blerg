CREATE TABLE tags(
    id serial primary key,
    name varchar(60)
);

CREATE UNIQUE INDEX tags_name_idx ON tags(name);

CREATE TABLE post_tags(
    id serial primary key,
    post_id integer references posts(id),
    tag_id integer references tags(id)
);

CREATE INDEX post_tags_tag_id_idx ON post_tags(tag_id);
CREATE UNIQUE INDEX post_tags_post_id_tag_id_idx ON post_tags(post_id, tag_id);

