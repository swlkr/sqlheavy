(import tester :prefix "" :exit true)
(use ../src/sqlheavy/sqlheavy)

# setup
(set db/log-sql? false)
(db/connect "sqlheavy.sqlite3") # uses DATABASE_URL by default

(db/query "drop table if exists users")
(db/query "create table if not exists users (id integer primary key, name text, updated_at integer)")

(defmodel User)

(defsuite "no prefix"
  (test "insert"
    (is (deep= @{:id 1 :name "name"}
               (:insert User {:name "name"}))))

  (test "find"
    (is (deep= @{:id 1 :name "name"}
               (:find User 1))))

  (test "all"
    (is (deep= @[@{:id 1 :name "name"}]
               (:all User))))

  (test "update"
    (let [user (:find User 1)
          record (:update user {:name "Name"})
          updated-at (get record :updated_at)
          record* (put record :updated_at nil)]

      (is (and (deep= @{:id 1 :name "Name"}
                      record*)
               (not (nil? updated-at))))))

  (test "delete"
    (is (deep= @{:id 1 :name "Name"}
               (let [user (:find User 1)]
                (put (merge {} (:delete user))
                     :updated_at nil))))))
