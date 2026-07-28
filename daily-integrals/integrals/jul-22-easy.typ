$integral^1_0 sqrt(1 - root(3, 1-x)) d x$

$u := 1-x$

$d u = -d x$

$integral^1_0 sqrt(1 - root(3, u)) d u$

$y = sqrt(1 - root(3, u))$

$y^2 = 1 - root(3, u) forall y "s.t." 1 - root(3, u) gt.eq 0$

$root(3, u) lt.eq 1$

$u lt.eq 1 in [1, 0]$

$u = (1 - y^2)^3$

$d u = -6 y (1 - y^2)^2 d y$

$d u = -6 y (1 - 2 y^2 + y^4) d y$

$d u = -6 (y - 2 y^3 + y^5) d y$

$-6 integral^0_1 y (y - 2 y^3 + y^5) d y$

$6 integral^1_0 (y^6 - 2 y^4 + y^2) d y$

$6(1/7 y^7 - 1/5 y^5 + 1/3 y^3)|^1_0$

$6/7 - 6/5 + 1/3$

$16/35$
