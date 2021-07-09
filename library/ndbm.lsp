(c-include "<ndbm.h>")
(c-include "<fcntl.h>")

(defun ndbm-rdonly ()
   (c-lang "res = O_RDONLY | INT_FLAG;"))
(defun ndbm-wronly ()
   (c-lang "res = O_WRONLY | INT_FLAG;"))
(defun ndbm-rdwr ()
   (c-lang "res = O_RDWR | INT_FLAG;"))
(defun ndbm-creat ()
   (c-lang "res = O_CREAT | INT_FLAG;"))

(defun ndbm-open (file flags mode)
   (the <string> file)(the <fixnum> flags)(the <fixnum> mode)
   (c-lang "char *res_str;")
   (c-lang "res_str = fast_sprint_hex_long(dbm_open(Fgetname(FILE), FLAGS & INT_MASK, MODE & INT_MASK));")
   (c-lang "res = Fmakefaststrlong(res_str);"))

(defun ndbm-insert ()
   (c-lang "res = DBM_INSERT | INT_FLAG;"))
(defun ndbm-replace ()
   (c-lang "res = DBM_REPLACE | INT_FLAG;"))

(defun ndbm-store (db key content store-mode)
   (the <longnum> db)(the <string> key)(the <string> content)(the <fixnum> store-mode)
   (c-lang "datum key, content;");
   (c-lang "key.dptr = Fgetname(KEY); key.dsize = strlen(key.dptr);")
   (c-lang "content.dptr = Fgetname(CONTENT); content.dsize = strlen(content.dptr) + 1;")
   (c-lang "res = dbm_store(Fgetlong(DB), key, content, STORE_MODE & INT_MASK);"))

(defun ndbm-fetch (db key)
   (the <longnum> db)(the <string> key)
   (c-lang "datum key, content;")
   (c-lang "key.dptr = Fgetname(KEY); key.dsize = strlen(key.dptr);")
   (c-lang "content = dbm_fetch(Fgetlong(DB), key);")
   (c-lang "res = Fmakestr(content.dptr);"))

(defun ndbm-delete (db key)
   (the <longnum> db)(the <string> key)
   (c-lang "datum key;")
   (c-lang "key.dptr = Fgetname(KEY); key.dsize = strlen(key.dptr);")
   (c-lang "res = dbm_delete(Fgetlong(DB), key);"))

(defun ndbm-close (db)
   (the <longnum> db)
   (c-lang "res = NIL; dbm_close(Fgetlong(DB));"))
