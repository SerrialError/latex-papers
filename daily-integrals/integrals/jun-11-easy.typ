$integral^2_1 (e^x (x - 1))/(x + 1)^3 d x$

$u := x + 1$

$d u = d x$

$integral^3_2 (e^(u - 1) (u - 2)) / u^3 d u$

$integral^3_2 (e^(u - 1) u) / u^3 d u - 2 integral^3_2 e^(u - 1) / u^3 d u$

$integral^3_2 e^(u - 1) / u^2 d u - 2 integral^3_2 e^(u - 1) / u^3 d u$

$w := 1 / u^2$ $d v := e^(u - 1) d u$

$d w = - 2 / (u^3) d u$ $v := e^(u - 1)$

$e^(u - 1) / u^2 |^3_2 + 2 integral^3_2 e^(u-1) / u^3 d u - 2 integral^2_1 e^(u - 1) / u^3 d u$ 

$e^2 / 9 - e / 4$ 
