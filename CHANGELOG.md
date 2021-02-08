# Changelog

## 02/05/2021 Version 1.0

- Initial release! 🚀
- Connect to the database with `db/connect`
- Set `db/log-sql?` to true or false to get logs to stdout?
- Use `defmodel` to define models
- Two top level imports, `(import sqlheavy :as db)` or `(use sqlheavy-no-prefix)`
- Five methods on model objects: `:all :find :update :delete :insert`

## 02/08/2021 Version 1.1

- Fix null handling in where clauses in `:find`
