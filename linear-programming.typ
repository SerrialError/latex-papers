Given

$F_y = m_1 + m_2 + o_1 + o_2 + m_3 + m_4$

$F_x = m_1 - m_2 - m_3 + m_4$

The bounds of $m_i$ are denoted by $[l_i, u_i]$ which are constants

The bounds of $o_i$ are denoted by $[l_(o i), u_(o i)]$ which are constants

Goal:

Find the bounds of $F_y$ based upon $F_x$

Let $A = m_1 + m_4$, $B = m_2 + m_3$, $O = o_1 + o_2$, and $R = F_x$

Then the bounds of $A$ are $[l_1 + l_4, u_1 + u_4]$, the bounds of $B$ are $[l_2 + l_3, u_2 + u_3]$, and the bounds of $O$ are $[l_(o 1) + l_(o 2), u_(o 1) + u_(o 2)]$

Let $l_1 + l_4 = A_("min")$, $u_1 + u_4 = A_("max")$, $l_2 + l_3 = B_("min")$, $u_2 + u_3 = B_("max")$, $l_(o 1) + l_(o 2) = O_("min")$, and $u_(o 1) + u_(o 2) = O_("max")$

$A in [A_("min"), A_("max")]$, $B in [B_("min"), B_("max")]$, and $[O_("min"), O_("max")]$ by substitution

$F_y = A + B + O$ and $F_x = A - B$ by substitution

$R = A - B$ by substitution

$-A = -R - B$ by subtraction

$A = R + B$ by division

$F_y = 2 B + R + O$ by the transitive property

$R + B in [A_("min"), A_("max")]$ by substitution

Therefore $A_("min") lt.eq R + B lt.eq A_("max")$

$A_("min") - R lt.eq B lt.eq A_("max") - R$

Therefore $B in [B_("min"), B_("max")] inter [A_("min") - R, A_("max") - R]$

Let $B_("feas,min") = max{B_("min"), A_("min") - R}$ and $B_("feas,max") = min{B_("max"), A_("max") - R}$

Therefore $B in [B_("feas,min"), B_("feas,max")]$

$F_y = 2 B + F_x + O$ by substitution

Define function $F_y$ as $F_y (F_x) = 2 B + F_x + O$

Therefore $F_("y,min") = 2 B_("feas,min") + R + O_("min")$ and $F_("y,max") = 2 B_("feas,max") + R + O_("max")$

Therefore $F_y in [F_("y,min"), F_("y,max")]$

Goal:

Find the bounds of $F_x$ based upon $F_y$

Let $S$ be $F_y$ and $T$ be $A + B$

$S = A + B + O$, $T = A + B$, $F_x = A - B$ by substitution

Define $F_x$ as $F_x (S) = A - B$

$S - O = A + B$ by substraction

$S - O  = T$ by substitution

Therefore the bounds of $T$ are $[S - O_("max"), S - O_("min")]$ and $A + B in [A_("min") + B_("min"), A_("max") + B_("max")]$

$T in [A_("min") + B_("min"), A_("max") + B_("max")]$

Therefore $T in [S - O_("max"), S - O_("min")] inter [A_("min") + B_("min"), A_("max") + B_("max")]$

Let $T_("min") = max{A_("min") + B_("min"), S - O_("max")}$ and $T_("max") = max{A_("max") + B_("max"), S - O_("min")}$

Therefore the bounds of $A + B$ are $[T_("min"), T_("max")]$

By extremizing $F_x = A - B$ we find $F_("x,max") (S) = max{T_("max") - 2 B_("min"), 2 A_("max") - T_("min")}$ and $F_("x,min") (S) = min{T_("min") - 2 B_("max"), 2 A_("min") - T_("max")}$

$F_x = A - B$ we find $F_("x,max") (F_y) = max{T_("max") - 2 B_("min"), 2 A_("max") - T_("min")}$ and $F_("x,min") (F_y) = min{T_("min") - 2 B_("max"), 2 A_("min") - T_("max")}$ by substitution

Therefore $F_x in [F_("x,min") (F_y), F_("x,max") (F_y)]$

