DROP TABLE IF EXISTS pubmed_abstracts CASCADE;


CREATE TABLE pubmed_abstracts (
  id BIGSERIAL PRIMARY KEY,
  pmid INTEGER NOT NULL,
  title TEXT NOT NULL,
  authors TEXT NOT NULL,
  section_name TEXT NOT NULL,
  section_body TEXT NOT NULL
);

GRANT SELECT, INSERT, UPDATE, DELETE ON pubmed_abstracts TO crea_user;
