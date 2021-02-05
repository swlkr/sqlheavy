(declare-project
  :name "sqlheavy"
  :description "Bits for janet sqlite applications"
  :dependencies ["https://github.com/janet-lang/sqlite3"]
  :author "Sean Walker"
  :license "MIT"
  :url "https://github.com/swlkr/sqlheavy"
  :repo "git+https://github.com/swlkr/sqlheavy")

(declare-source
  :source ["src/"])

(phony "auto-test" []
  (os/shell "find . -name '*.janet' | entr -c -r -d jpm test"))
