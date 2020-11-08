;; load all test code ./test
(gbc)
(load "tests/object-test.lsp")
(load "tests/arithmetic-test.lsp")
(load "tests/array-test.lsp")
(load "tests/controle-test.lsp")
(load "tests/convert-test.lsp")
(load "tests/list-test.lsp")
(load "tests/predicate-test.lsp")
(load "tests/symbol-test.lsp")

(format (standard-output) "All tests are done!~%")
