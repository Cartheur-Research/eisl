# Test 
Simple macro for unit testing.

# Usage

```lisp
(import "test")
```

# Specification

```lisp
(test test-S-expression result-S-Expression)
```

If eval of test-S-expression is same as result-S-expression, print nothing.
If eval of test-S-expression is not same as result-S-expression, print a message.
The `equal` function is used for comparison.

```lisp
(test test-S-expression result-S-Expression pred-function)
```

`pred-function` is used for comparison, e.g. eq, =, eql, ...

```lisp
($eval form)
```
Evaluate form. Ignore top level check. 

```lisp
($error form error-class)
```
Error check. Error class of form is error-class?

```lisp
($error1 form error-class)
```
Error check. Error class of form is error-class? Not ignore top-level check.


# Code

See following macro code

```lisp
(defmacro test (form1 form2 :rest pred)
  (if (null pred)
      `(progn
          (ignore-toplevel-check t)
          (let ((ans ,form1))
            (if (equal ans ',form2)
              (format (standard-output) "" ',form1)
              (format (standard-output) "~S is bad. correct is ~A but got ~A ~%" ',form1 ',form2 ans)))
          (ignore-toplevel-check nil)
      )
      `(progn
          (ignore-toplevel-check t)
          (let ((ans ,form1))
            (if (,@pred ans ',form2)
              (format (standard-output) "" ',form1)
              (format (standard-output) "~S is bad. correct is ~A but got ~A ~%" ',form1, ',form2 ans)))
          (ignore-toplevel-check nil)
      )))

(defmacro $eval (form)
  `(progn 
        (ignore-toplevel-check t)
        (eval ',form)
        (ignore-toplevel-check nil)))

(defmacro $error (form name)
  `(progn
      (ignore-toplevel-check t)
      (let ((ans (catch 'c-parse-error
              (with-handler 
                (lambda (c) (throw 'c-parse-error c))
                ,form))))
          (if (equal (class-of ans) (class ,name))
              (format (standard-output) "" ',form)
              (format (standard-output) "~S is bad. correct is ~A but got ~A ~%" ',form (class ,name) (class-of ans))))
      (ignore-toplevel-check nil)))


(defmacro $error1 (form name)
  `(progn
      (let ((ans (catch 'c-parse-error
              (with-handler 
                (lambda (c) (throw 'c-parse-error c))
                ,form))))
          (if (equal (class-of ans) (class ,name))
              (format (standard-output) "" ',form)
              (format (standard-output) "~S is bad. correct is ~A but got ~A ~%" ',form (class ,name) (class-of ans))))))


(defmacro $ap (n name :rest page)
    (if (null page)
        `(format (standard-output) "~A ~A~%" ,n ,name)
        `(format (standard-output) "~A ~A ~A ~%",n ,name ',page)))

(defmacro $argc (x1 x2 x3 x4) `nil)
(defmacro $predicate (x1 x2 :rest x3) `nil)
(defmacro $type (x1 x2 x3 :rest x4) `nil)
(defmacro $stype (x1 x2 x3 :rest x4) `nil)
```
