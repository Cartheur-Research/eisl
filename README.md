# Easy-ISLisp

Easy-ISLisp(EISL) is an interpreter and compiler compatible with ISLisp standard.
EISL was written by Kenichi Sasagawa
https://qiita.com/sym_num/items/793adfe118514668e5b0

see [ISLisp](https://en.wikipedia.org/wiki/ISLISP)
youtube [introduction of Easy-ISLisp](https://www.youtube.com/watch?v=KfrRyKMcTw8&t=330s)

# Installation
Change to the git cloned or downloaded Easy-ISLisp directory.

In Linux  type "make" in terminal.

On Windows rename winmakefile -> makefile. and type "make" in terminal.
Requires MINGW GCC

We confirmed operation in the following environments.
- Ubuntu 16.04 GCC 5.4
- Ubuntu 18.04 GCC 7.3
- Raspberry Pi3 Raspbian GCC 6.3
- openSUSE Leap 42.3 GCC 4.8.5
- Debian GNU/Linux GCC 6.3 GCC 7.3
- Linux Mint GCC ver 5.4
- Linux Mint GCC ver9.3.0
- Windows10 MINGW GCC 5.3


# Invoke
- eisl (Windows)
- ./eisl (Linux)

In the Linux version,the REPL is editable. If you do not desire to use the editable REPL, invoke with -r option.

```
./eisl -r
```

# Editable REPL
key-bindings are as follows:

- ctrl+F  or → move right
- ctrl+B  or ← move left 
- ctrl+P  or ↑ recall history older
- ctrl+N  or ↓ recall history newer
- ctrl+A  move to begin of line
- strl+E  move to end of line 
- ctrl+J ctrl+M or return insert end of line
- ctrl+H  or back-space  backspace
- ctrl+D  delete one char
- ctrl+K  kill line from current positon
- ctrl+Y  yank killed line
- Esc Tab completion

# Goal
I hope that Lisp will become more popular. I hope many people enjoy Lisp. EISL aims at easy handling.

# Compiler
EISL has a compiler. it generates GCC code and generates object code.

```
Invoke with -c option
./eisl -c compiler.lsp

or (load "compiler.lsp")

(compile-file "foo.lsp")

(load "foo.o")

example
./eisl -c compiler.lsp
Easy-ISLisp Ver0.91
> (compile-file "tarai.lsp")
type inference
initialize
pass1
pass2
compiling PACK
compiling TARAI
compiling FIB
compiling FIB*
compiling ACK
compiling GFIB
compiling TAK
compiling LISTN
compiling TAKL
compiling CTAK
compiling CTAK-AUX

finalize
invoke GCC
T
> (load "tarai.o")
T
> (time (tarai 12 6 0))
Elapsed Time(second)=0.024106
<undef>
> (time (ack 4 1))
Elapsed Time(second)=3.728262
<undef>
>
```



# Compiler for CUDA
EISL has a compiler. it generates cuda code with nvcc and generates object code.

```
Invoke with -c option
./eisl -c compiler.lsp

or (load "compiler.lsp")

(compile-cuda "foo.lsp")

(load "foo.o")
```

# Invoke editor
edit function invoke Edlis editor.
see https://github.com/sasagawa888/Edlis

(edit file-name-string) example (edit "foo.lsp")

# WiringPi
Version for Raspberry Pi include library for wiringPi.

In order to use wiringPi, you need to compile wiringpi.lsp(in example folder) and invoke EISL with super user.

```
sudo ./eisl
```
and 

```
(load "wiringpi.o")
```
please see the example code "led.lsp"

"wiringpi.lsp" is the source code of wiringpi.o.

```
EISL <==================================> C
(wiringpi-spi-setup ch speed) <===> wiringPiSPISetup (SPI_CH, SPI_SPEED)
(wiringpi-setup-gpio ) <===> wiringPiSetupGpio()
(pin-mode n 'output) <====> pinMode(n, OUTPUT) or 'input -> INPUT 'pwm-output -> PWM-OUTPUT
(digital-write n v) <===> digitalWrite(n, v)
(digital-write-byte v) <===> digitalWriteByte(value)
(digital-read pin) <===> digitalRead(pin)
(delay howlong) <===> void delay(unsigned int howLong)
(pull-up-dn-control pin pud) <===> pullUpDnControl(pin,pud)
(pwm-set-mode 'pwm-mode-ms) <===> pwmSetMode(PWM_MODE_MS); or 'pwm-mode-bal -> PWM_MODE_BAL
(pwm-set-clock n) <===> pwmSetClock(n)
(pwm-set-range n) <===> pwmSetRange(n)
(pwm-write pin value) <===> pwmWrite(pin , value)
```

### Examples.

```
;;LED on/off

(defglobal pin 5)
(defglobal flag nil)

(defun test (n)
   (cond ((null flag) (wiringpi-setup-gpio)(setq flag t)))
   (pin-mode pin 'output)
   (for ((i 0 (+ i 1)))
        ((> i n) t)
        (digital-write pin 1)
        (delay 1000)
        (digital-write pin 0)
        (delay 1000)))


;;control servo moter.
;;SG90 Micro servo Digital 9g

(defun setup ()
  (cond ((null flag) (wiringpi-setup-gpio ) (setq flag t)))
  (pin-mode 18 'pwm-output)
  (pwm-set-mode 'pwm-mode-ms)
  (pwm-set-clock 400)
  (pwm-set-range 1024))

(defun test (n)
   (pwm-write 18 n))
```


# Functions for debug
- (trace fn1 fn2 ... fn)
- (untrace fn1 fn2 ... fn) or (untrace)
- (backtrace)
- (break)
- (macroexpand-1)

# Extended functions
- (random n) random-integer from 0 to n
- (random-real) random-float-number from 0 to 1
- (gbc) invoke garbage collection.
- (gbc t) display message when invoke GC.
- (gbc nil) not display message when invoke GC.
