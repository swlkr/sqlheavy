(import ./init :as db :export true)


(defmacro defmodel [model-name]
  ~(db/model ,model-name))
