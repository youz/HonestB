(use gauche.uvector)
(use gauche.sequence)
(use util.match)

(load "./lazyk/lazier.scm")
(load "./lazyk/prelude.scm")
(load "./lazyk/prelude-numbers.scm")

(define (print-as-hb expr)
  (match expr
    ('s    (write-string "スロー"))
    ('k    (write-string "クイック"))
    ('i    (write-string "クイッククイックスロー\u2764\u2764"))
    ((f g) (print-as-hb g) (print-as-hb f) (write-string "\u2764"))))

(lazy-def 'hello
  (fold-right (^(e a) `(cons ,e ,a)) 'end-of-output (string->u8vector "Hello, world!")))

(print-as-hb (laze '(#t hello)))
