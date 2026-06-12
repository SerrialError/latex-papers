$integral^pi_1 cos(ln x) / x^2 d x$

$u := ln x$

$d u = 1 / x d x$

$integral^(ln pi)_0 (cos u) / e^u d u$

$w := cos u$ $d v := 1 / e^u d u$

$d w = -sin u d u$ $v = -1 / e^u$

$-(cos u) / e^u |^(ln pi)_0 - integral^(ln pi)_0 (sin u) / e^u d u$

$t := sin u$

$d t = cos u d u$

$-cos(ln pi) / pi + 1 - (-(sin u) / e^u |^(ln pi)_0 + integral^(ln pi)_0 (cos u) / e^u d u) = integral^(ln pi)_0 (cos u) / e^u d u$

$integral^(ln pi)_0 (cos u) / e^u d u = -cos(ln pi) / pi + 1 + (sin u) / e^u |^(ln pi)_0 - integral^(ln pi)_0 (cos u) / e^u d u$

$2 integral^(ln pi)_0 (cos u) / e^u d u = -cos(ln pi) / pi + 1 + sin(ln pi) / pi$

$integral^(ln pi)_0 (cos u) / e^u d u = (-cos(ln pi) / pi + sin(ln pi) / pi + 1) / 2$
