(def null :null)


(defn null? [val]
  (= val null))


(defn null-or-column [[k v]]
  (if (null? v) "null" (string ":" k)))


(defn null-or-param [join [k v]]
  (string k " " join " " (null-or-column [k v])))


(defn params-string [join sep prs]
  (as-> prs ?
        (map (partial null-or-param join) ?)
        (string/join ? sep)))

(def where-string (partial params-string "is" " and "))
(def set-string (partial params-string "=" ","))


(defn insert [table-name pairs]
  (string/format "insert into %s (%s) values (%s);"
                 (string table-name)
                 (string/join (map first pairs) ",")
                 (as-> pairs ?
                       (map null-or-column ?)
                       (string/join ? ","))))


(defn inserted [table-name]
  (string/format "select * from %s where rowid = :rowid limit 1;"
                 (string table-name)))


(defn update [table-name where-pairs prs]
  (string/format "update %s set %s where %s;"
                 (string table-name)
                 (set-string prs)
                 (where-string where-pairs)))


(defn find [table-name prs]
  (string/format "select * from %s where %s limit 1"
                 (string table-name)
                 (where-string prs)))


(defn all [table-name prs]
  (string/format "select * from %s %s;"
                 (string table-name)
                 (if (or (nil? prs) (empty? prs))
                  ""
                  (string "where " (where-string prs)))))


(defn delete [table-name prs]
  (string/format "delete from %s where %s"
                  (string table-name)
                  (where-string prs)))
