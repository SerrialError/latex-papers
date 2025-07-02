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
$forall t in T$ and $n in N_t$, we have

$ k^"min"_(t n) lt.eq F_(t n) lt.eq k^"max"_(t n) $

Now we want to make some way to input $theta F_(r)$, $tau_r$, and $forall t in T$ and $n in N_t$: $k^"min"_{t n}$ and $k^"max"_{t n}$ and then somehow get out $forall t in T$ and $n in N_t$: $F_{t n}$ that maximizes $F_(r x) + F_(r y)$

First let's find the "objective function". Substituting we get

$ F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4) + F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) $

Simplifying we then get

$ 2 F_(m 2) + 2 F_(m 3) + F_(o 1) + F_(o 2) $

We can then use the simplex algorithm to solve this. It says to maximize $c^T$ x subject to $A x lt.eq b$ and $x gt.eq k$ where

- $A$ is an $m times n$ matrix
- $b in RR^m$
- $c in RR^n$
- $x in RR^n$ are the decision variables
- $x$ is the decision variable vector
- $c$ is the objective-coefficient vector
- $c^T x$ is the objective function
- $A$ is the constraint matrix
- $b$ is the right-hand side vector
- $k in RR$

First, let's put down what we know. We know the decision variable vector $x$ would be $F_(m 1),F_(m 2),F_(m 3),F_(m 4),F_(o 1),F_(o 2)$.

Back from what we found before because of that we know the decision variable vector $c$ is $0, 2, 2, 0, 1, 1$.

So $c^T x = 2 F_(m 2) + 2 F_(m 3) + F_(o 1) + F_(o 2)$ (what we found earlier).

Now we are really close, all we have to worry about is $A$. So first we know a bunch of the inequalities:

$forall t in T$ and $n in N_t$

$ k^"min"_(t n) lt.eq F_(t n) lt.eq k^"max"_(t n) $

we need to then put it in the form $A x lt.eq b$ so we get

$forall t in T$ and $n in N_t$

$F_(t n) lt.eq k^"max"_(t n)$
$-F_(t n) lt.eq -k^"min"_(t n)$

rearranging so $x$ and $A$ are on the same side we get

$forall t in T$ and $n in N_t$

$1/k^"max"_(t n) F_(t n) lt.eq 1$
$1/k^"min"_(t n) F_(t n) lt.eq 1$

So we know some of the constraints. The next constraint is the angle of force contraint.  
Now we need to linearize $theta F_r$.

First we flip around the trig function to get

$tan(theta F_r)  = (F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2))/(F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4))$

Then simplifying we get

$ F_(m 1) + F_(m 2) + F_(m 3) + F_(m 4) + F_(o 1) + F_(o 2) - tan(theta F_r) (F_(m 2) + F_(m 3) - F_(m 1) - F_(m 4)) = 0 $

we can then factorize to get

$ F_(m 1) (1 + tan(theta F_r)) + F_(m 2) (1 - tan(theta F_r)) + F_(m 3) (1 - tan(theta F_r)) + F_(m 4) (1 + tan(theta F_r)) + F_(o 1) + F_(o 2) = 0 $

We can then take the factors to the decision variables to get a vector

$a_"ang" = {1 + tan(theta F_r), 1 - tan(theta F_r), 1 - tan(theta F_r), 1 + tan(theta F_r), 1, 1}$

Which we can convert into two inequalities

$ a^T_"ang" x lt.eq 0 $ $ -a^T_"ang" x lt.eq 0 $

Now onto the last and final constraint we have is the torque constraint which we can apply the same steps and factorize getting the new vector

$a_tau = {-(L+W)/4, (L+W)/4, -(L+W)/4, (L+W)/4, -W/2, W/2}$

giving the following two inequalities

$ a^T_tau x lt.eq tau_r $ $ -a^T_tau x lt.eq tau_r $

This gives us the total matrix $A$

