Let $f : RR -> RR$ where $f(x) = x + 1/x$. Compute:

$integral^1_0 f(f(x)) / f(x) d x$

$f(f(x)) / f(x) = (x + 1/x + 1 / (x + 1/x)) / (x + 1/x)$

$f(f(x)) / f(x) = 1 + (1 / (x + 1/x)) / (x + 1/x)$

$f(f(x)) / f(x) = 1 + 1 / (x^2 + 2 + 1/x^2)$

$f(f(x)) / f(x) = 1 + x^2 / (x^4 + 2 x^2 + 1)$

$f(f(x)) / f(x) = 1 + x^2 / (x^4 + 2 x^2 + 1)$

$f(f(x)) / f(x) = 1 + x^2 / (x^2 + 1)^2$

$f(f(x)) / f(x) = 1 + x^2 / (x^2 + 1)^2$

$integral^1_0 (1 + x^2 / (x^2 + 1)^2) d x$

$1 + integral^1_0 x^2 / (x^2 + 1)^2 d x$

$x = tan theta quad d x = sec^2 theta d theta$

$1 + integral^(pi/4)_0 (tan^2 theta) / (sec^4 theta) sec^2 theta d theta$

$1 + integral^(pi/4)_0 (tan^2 theta) / (sec^2 theta) d theta$

$1 + integral^(pi/4)_0 sin^2 theta d theta$

$1 + integral^(pi/4)_0 (1 - cos 2 theta) / 2 d theta$

$1 + pi/8 - 1/2 integral^(pi/4)_0 cos 2 theta d theta$

$u := 2 theta quad d u = 2 d theta$

$1 + pi/8 - 1/4 integral^(pi/2)_0 cos u d u$

$1 + pi/8 - 1/4 sin u |^(pi/2_0)$

$1 + pi/8 - 1/4$

$3/4 + pi/8$
