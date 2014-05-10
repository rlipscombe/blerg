ALTER TABLE users ADD COLUMN password_hash VARCHAR(60);
UPDATE users SET password_hash = '!';
ALTER TABLE users ALTER COLUMN password_hash SET NOT NULL;
