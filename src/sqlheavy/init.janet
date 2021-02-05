(import sqlite3)
(import ./sql)

# configuration
(var log-sql? :public "log-sql? can either be true or false. true by default. Set to false to disable sql logging" true)


# database functions
(defn- nilify [dict]
  (var output @{})

  (eachp [k v] dict
    (if (sql/null? v)
        (put output k nil)
        (put output k v)))

  output)


(var connection nil)
(defn connect [&opt url]
  (default url (os/getenv "DATABASE_URL"))
  (set connection (sqlite3/open url))
  (sqlite3/eval connection "PRAGMA foreign_keys = ON;"))


(defn- log-sql [sql]
  (when log-sql?
    (printf "%M" sql))

  sql)


(defn query [sql & params]
  (sqlite3/eval connection ;(log-sql [sql ;params])))


(defmacro- transaction [& body]
  ~(defer (sqlite3/eval connection "end transaction;")
     (sqlite3/eval connection "begin transaction;")
     (do ,;body)))


(defn- find [table-name dict]
  (as-> (sql/find table-name (pairs dict)) ?
        (query ? (nilify dict))
        (first ?)))


(defn- all [table-name &opt dict]
  (default dict {})

  (def- prs (pairs dict))
  (def- sql (sql/all table-name prs))

  (sqlite3/eval connection ;(log-sql [sql (nilify dict)])))


(defn- insert [table-name dict]
  (def- insert-sql (sql/insert table-name (pairs dict)))
  (def- inserted-sql (sql/inserted table-name))

  (transaction
    (sqlite3/eval connection ;(log-sql [insert-sql (nilify dict)]))
    (as-> (sqlite3/eval connection ;(log-sql ["select last_insert_rowid() as rowid"])) ?
          (first ?)
          (sqlite3/eval connection ;(log-sql [inserted-sql ?]))
          (first ?))))


(defn- update [table-name where-dict dict]
  (let [where-dict {:id (where-dict :id)}
        where-pairs (pairs where-dict)
        set-pairs (pairs dict)
        update-sql (sql/update table-name where-pairs set-pairs)
        find-sql (sql/find table-name where-pairs)]

    (transaction
      (sqlite3/eval connection ;(log-sql [update-sql (nilify (merge where-dict dict))]))
      (first (sqlite3/eval connection ;(log-sql [find-sql (nilify where-dict)]))))))


(defn- delete [table-name dict]
  (def- prs (pairs dict))
  (def- delete-sql (sql/delete table-name prs))
  (def- find-sql (sql/find table-name prs))
  (var- deleted nil)
  (def- params (nilify dict))

  (transaction
    (set deleted (first (sqlite3/eval connection ;(log-sql [find-sql params]))))
    (sqlite3/eval connection ;(log-sql [delete-sql params]))
    deleted))


(defmacro model [model-name]
  (def- table-name (string (string/ascii-lower model-name) "s"))

  (var- has-updated_at? false)
  (let [table-info (query (string/format "PRAGMA table_info(%s);" table-name))]
    (set has-updated_at?
         (as-> table-info ?
               (filter |(and (= "updated_at" (get $ :name))
                             (= "integer" (get $ :type)))
                       ?)
               (first ?))))

  (def- row @{:table table-name

              :update (fn [self params]
                        (let [params (if has-updated_at?
                                       (merge params {:updated_at (os/time)})
                                       params)
                              record (update (self :table) {:id (self :id)} params)]
                          (table/setproto (merge {} record) self)))

              :delete (fn [self]
                        (delete (self :table) {:id (self :id)}))})

  (def- model @{:table table-name

                :find (fn [self id-or-params]
                        (def- params (if (dictionary? id-or-params)
                                       id-or-params
                                       {:id id-or-params}))

                        (when-let [record (find (self :table) params)]
                          (table/setproto (merge {} record) row)))

                :all (fn [self]
                       (as-> (all (get self :table)) ?
                             (map |(table/setproto (merge {} $) row) ?)))


                :insert (fn [self params]
                          (table/setproto
                            (merge {} (insert (self :table) params))
                            row))})

  (defglobal model-name model))
