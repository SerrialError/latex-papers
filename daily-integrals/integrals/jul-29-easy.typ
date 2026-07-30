#import "@preview/auto-div:0.1.0": poly-div-working

$integral^(pi/4)_0 (cos^3 2 x) / (1 + sin^2 2 x) d x$

$u := 2 x quad d u = 2 d x$

$1/2 integral^(pi/2)_0 (cos^2 u cos u) / (1 + sin^2 u) d u$

$1/2 integral^(pi/2)_0 ((1 - sin^2 u) cos u) / (1 + sin^2 u) d u$

$w := sin u quad d w = cos u d u$

$1/2 integral^1_0 (1 - w^2) / (1 + w^2) d w$

$#poly-div-working((-1, 0, 1), (1, 0, 1))$

$1/2 integral^1_0 (-1 + 2 / (1+w^2)) d w$

$1/2 (-w + 2 arctan w)|^1_0$

$1/2 (-1 + pi/2)$

$-1/2 + pi/4$

$pi/4 - 1/2$
