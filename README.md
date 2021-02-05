# sqlheavy

_A sqlite janet library for CRUD operations_

## Installation

Add it to your global janet deps

```sh
jpm install https://github.com/swlkr/sqlheavy
```

or to your `project.janet` file:

```clojure
{:depedencies ["https://github.com/swlkr/sqlheavy"]}
```

## Usage

To get to the model-y goodness you have to do a few things first:

1. Import the library

```clojure
; # your-project.janet
(import sqlheavy :as db)
```

2. Connect to the database

```clojure
; # your-project.janet
(db/connect "sqlheavy.sqlite3")
```

3. Create a table (you can do this any way you want, this is for example purposes)

```clojure
; # your-project.janet
(db/query "create table if not exists users (id integer primary key, name text)")
```

4. Define the model

```clojure
; # attempts naive lowercase + appends an "s" to determine table name
(db/model User)
```

5. Start querying!

```clojure
(:find User 1) ; # => nil

(def- user (:insert User {:name "name"})) ; # => @{:id 1 :name "name"}

(:update user {:name "Name"}) ; # => @{:id 1 :name "Name"}

(:all User) ; # => @[@{:id 1 :name "Name"}]

(:delete user) ; # => {:id 1 :name "Name"} (immutable struct returned since you can't do much with a deleted record)
```

## Advanced Usage

There is another option for importing if you want to see `defmodel` happen like I do

```clojure
(use sqlheavy/sqlheavy)

(defmodel User)
```

This scopes everything to `db/` still but leaves `defmodel` by itself. It's the little things.

There's one more thing that sqlheavy does when you define a model, it looks for an `updated_at` column with type `integer`
and if that exists on the table, when you call `:update` it will fill in that value with the current epoch time:

```clojure
(use sqlheavy/sqlheavy)

(db/query "create table if not exists posts (id integer primary key, title text, body text, updated_at integer)")

(defmodel Post)

(let [post (:insert Post {:title "title" :body "body"})]
  (:update post {:title "Title"}))
```

## Logging

sqlheavy logs all sql queries and their parameters by default, you can turn this off by setting `db/log-sql?` to false:

```clojure
(set db/log-sql? false)
```

Happy hacking!
