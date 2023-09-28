(use gauche.uvector)
(use gauche.sequence)

(load "./lazyk/lazier.scm")
(load "./lazyk/prelude.scm")
(load "./lazyk/prelude-numbers.scm")

; 10進数を各桁の数字のリストとして表現する (下位の方が先頭)
(lazy-def 'dec1 '(cons 1 ()))

; 10進数のイクリメント
(lazy-def 'succ-dec
  '(Y (lambda (self d)
	(if (null? d) (cons 1 ())
	    (if<= (car d) 8
		  (cons (succ (car d)) (cdr d))
		  (cons 0 (self (cdr d))))))))

; 10進数の文字列化
; 下位の桁(リスト先頭側)から文字化(+48)しつつcontにconsして行く
; contはリストを生成する継続
(lazy-def 'print-dec
  '(Y (lambda (self d cont)
	 (if (null? d) cont
	     (self (cdr d) (cons (+ 48 (car d)) cont))))))

; prelude-numbersには0-128と256しか用意されてないので
; ASCII外の文字も印字できるよう129-255を作る
(dotimes (i 128)
  (let1 c (+ i 128)
    (unless (assv c lazy-defs)
      (lazy-def c `(+ ,i 128)))))

; 固定文字列生成
; リストを生成する継続を引数に取り、固定文字列をconsする
(define (genstrf name s)
  (lazy-def `(,name cont)
    (fold-right (lambda (a b) `(cons ,a ,b))
		'cont (string->u8vector s))))

; (genstrf 'print-fizz "Fizz")
; (genstrf 'print-buzz "Buzz")

(genstrf 'print-fizz "ご友人…")
(genstrf 'print-buzz "素敵だ…")

; 倍数判定用無限リスト
(lazy-def 'c3 '(Y (lambda (self) (cons #f (cons #f (cons #t (self)))))))
(lazy-def 'c5 '(Y (lambda (self) (cons #f (cons #f (cons #f (cons #f (cons #t (self)))))))))

; consのようにふるまうfizzbuzz関数
(lazy-def 'fizzbuzz
  '(Y (lambda (self dec c3 c5)
	 ((lambda (cont)
	    (if (and (car c3) (car c5))
		(print-fizz (print-buzz cont))
		(if (car c5)
		    (print-buzz cont)
		    (if (car c3)
			(print-fizz cont)
			(print-dec dec cont)))))
	  (cons 10 (if (or (null? (cdr dec)) (null? (cdr (cdr dec))))
		       (self (succ-dec dec) (cdr c3) (cdr c5))
		       end-of-output))))))

(print-as-unlambda (laze '(#t (fizzbuzz dec1 c3 c5))))
