Pubmed Fetcher in Ruby
----------------------

This is a small Ruby application for calling Pubmed APIs and storing abstracts in a local database. This app is written to be part of the BioNaVisT project, and may change to fit into its infrastructure. However, it could still be ran on as a standalone application, and may serve as an example of a lightweight and scalable Ruby application.

### Tech Stack

* Ruby
* ActiveRecord
  * provides a simple ORM that I use to store with minimal fuss
* PostgreSQL
  * any relational database works fine
  * can be easily swapped to other databases by installing gems


### Usage

Make sure the tech stack is on your computer, and create a database in Postgres. I named mine `crea`.

Also configure `main.rb` to your database's credentials.

The initial run:
```bash
psql -U postgres -d crea < db/db_def.sql          # import database tables
bundle install                                    # install all required gems
ruby main.rb                                      # run application
```
It may be useful to keep track of logs:
```bash
tail -f -n100 fetch.log
```
Furthermore, you can keep track of the number of entries in the database already with this command: 
```bash
watch -n 0.3 "psql -U postgres -d crea -c \"SELECT count(*) FROM pubmed_abstracts;\""
```

### Details

* The application runs by looking up, one by one, the terms inside `docs/terms`. Adjust the file accordingly. 
* The schema is: 
  ```
  id, pmid, title, authors, search_term, section_name, section_body
  
  ```
  If an abstract has separate sections, they will be stored as separate entries. Otherwise, it will be stored as one entry with the `section_name` as "ALL".
* There are some abstracts that are neglected as being unsuccessful, because the body does not exist, or was not recognized. The recognition uses some basic regular expressions to match certain parts of the abstract, and may not be perfect. 
