(use gauche.uvector)
(use gauche.sequence)

(load "./lazyk/lazier.scm")
(load "./lazyk/prelude.scm")
(load "./lazyk/prelude-numbers.scm")

(lazy-def 'hello
  (fold-right (^(e a) `(cons ,e ,a)) 'end-of-output (string->u8vector "Hello, world!")))

(print-as-unlambda (laze '(#t hello)))
