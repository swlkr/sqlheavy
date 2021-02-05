(import ../src/sqlheavy :as db)
(import tester :prefix "" :exit true)

# connect to database
(set db/log-sql? false)
(db/connect "sqlheavy.sqlite3")

# create posts table
(db/query "drop table if exists posts;")
(db/query "create table if not exists posts (id integer primary key, title text, body text);")

# create model
(db/model Post)

(defsuite "crud"
  (test "insert"
    (is (deep= @{:id 1 :title "title" :body "body"}
               (:insert Post {:title "title" :body "body"}))))

  (test "find"
    (is (deep= @{:id 1 :title "title" :body "body"}
               (:find Post 1))))

  (test "update"
    (is (deep= @{:id 1 :title "changed title" :body "body"}
               (let [post (:find Post 1)]
                (:update post {:title "changed title"})))))

  (test "all"
    (is (deep= @[@{:id 1 :title "changed title" :body "body"}]
               (:all Post))))

  (test "delete"
    (is (= {:id 1 :title "changed title" :body "body"}
           (let [post (:find Post 1)]
            (:delete post))))))
