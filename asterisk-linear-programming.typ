$F_(r x m) = F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4)$, $F_(r x o) = 0$

$F_(r y m) = F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4)$, $F_(r y o) = F_(o 1) + F_(o 2)$

$theta F_(r m) = tan^-1(F_(r y m)/F_(r x m))$, $theta F_(r o) = 0$

$F_(r x) = F_(r x m)$, $F_(r y) = F_(r y m) + F_(r y o)$, $theta F_(r) = tan^(-1)(F_(r y)/F_(r x))$

$ F_(r x) = F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4) $

$ F_(r y) = F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) $

$ theta F_(r) = tan^(-1)((F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2))/(F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4))) $

$F_(r i m) = F_(m 2) + F_(m 4)$

$F_(l m) = F_(m 1) + F_(m 3)$

$tau_(r m) = (L+W)/4(F_(r i m) - F_(l m))$

$tau_(r o) = W/2(F_(o 2)-F_(o 1))$

$tau_r = tau_(r m) + tau_(r o)$

$tau_r = (L+W)/4(F_(r i m) - F_(l m)) + W/2(F_(o 2)-F_(o 1))$

$ tau_r = (L+W)/4(F_(m 2) + F_(m 4) - F_(m 1) - F_(m 3)) + W/2(F_(o 2)-F_(o 1)) $

Let $T = \{m, o\}$, $N_m = \{1, 2, 3, 4\}$ and $N_o = \{1, 2\}$.  
For all $t in T$ and $n in N_t$, we have

$ k^"min"_{t n} ≤ F_{t n} ≤ k^"max"_{t n} $

Now we want to make some way to input $theta F_(r)$, $tau_r$, and for all $t in T$ and $n in N_t$: $k^"min"_{t n}$ and $k^"max"_{t n}$ and then somehow get out for all $t in T$ and $n in N_t$: $F_{t n}$ that maximizes $F_(r x) + F_(r y)$

First let's find the "objective function". Substituting we get

$ F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4) + F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) $

Simplifying we then get

$ 2 F_(m 2) + 2 F_(m 3) + F_(o 1) + F_(o 2) $

We can then use the simplex algorithm to solve this. It says to maximize $c^T$ x subject to $A x lt.eq b$ and $x gt.eq 0$ where

- $A$ is an $m times n$ matrix
- $b in RR^m$
- $c in RR^n$
- $x in RR^n$ are the decision variables

In this case the decision variables or $x$ vector would be $F_(m 1),F_(m 2),F_(m 3),F_(m 4),F_(o 1),F_(o 2)$

Now we need to linearize $theta F_r$.

First we flip around the trig function to get

$tan(theta F_r)  = (F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2))/(F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4))$

Then simplifying we get

$ F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) - tan(theta F_r) (F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4)) = 0 $
