#import "@preview/cetz:0.4.1"

#let r = 10
#let h = r * (calc.sin(50deg))/(calc.sin(65deg))
#let x = r - h*(calc.cos(65deg))
#let y = h*(calc.sin(65deg))
#cetz.canvas({
  import cetz.draw: *

  arc((r,0), start: 0deg, stop: 50deg, radius: r, mode: "PIE", name: "myarc")
  content((0.5,0.2), $ theta $)
  content((-.2,-0.2), $B$)
  content((9.5,0.3), $ alpha $)
  content((10.2,-0.2), $A$)
  content((6.4,7.9), $C$)
  line((r,0),(x, y))
  line((x, y),(x,0))
  content((7.5,-0.2), $ Delta x $)
  content((6.4,-0.2), $ M $)
  content((6,4), $ Delta y $)
  content((9,5), $ l $)
  rect((7, -3),(13, 3))
  line((8.5,-.5),(8.5,.5))
})

Given the measures of $l$ and $theta$; AC is an arc; find $Delta x$ and $Delta y$

The measures of $l$ and $theta$ and AC is an arc because they are given

$c$ is a radius by the definition of a radius

$c tilde.equiv r$ by the reflexive property

$c = r$ by the definition of $tilde.equiv$ segments

$l = r theta$ by the arc length formula in radians

$l = c theta$ by substitution

$l / theta = c$ by division

$sin(theta) = "opposite" / "hypotenuse"$ by the definition of sine in right angle trigonometry

$cos(theta) = "adjacent" / "hypotenuse"$ by the definition of cosine in right angle trigonometry

$overline(A B) tilde.equiv c$ because radii $tilde.equiv$

$Delta x tilde.equiv overline(M A)$ by the reflexive property

$A B = c$ and $M A = Delta x$ by the definition of $tilde.equiv$ segments

$A B = B M + M A$ by the sement addition postulate

$A B - M A = B M$ by subtraction

$c - Delta x = B M$ by substitution

$l / theta - Delta x = B M$ by substitution

$Delta y$ is an opposite side to $angle theta$ by the definition of an opposite side.

$overline(B M)$ is an adjacent side to $angle theta$ by the definition of an adjacent side

$c$ is the hypotenuse of $triangle.stroked.t B M C$ by as the side opposite to the right $angle$ of a $triangle.stroked.t$ is the hypotenuse

$Delta y tilde.equiv Delta y$, $overline(B M) tilde.equiv overline(B M)$, and $c tilde.equiv c$ by the reflexive property

$Delta y = Delta y$, $B M = B M$, and $c = c$ by the definition of congurent segments

$Delta y = "opposite"$, $B M = "adjacent"$, and $c = "hypotenuse"$ by substitution

$sin(theta) = (Delta y) / c$, $cos(theta) = (B M) / c$ by substitution

$sin(theta) = (Delta y) / (l / theta)$, $cos(theta) = (c - Delta x) / c$ by substitution

$(l / theta) sin(theta) = Delta y$, $c cos(theta) = c - Delta x$ by multiplication

$c cos(theta) - c = - Delta x$ by substraction

$- c cos(theta) + c = Delta x$ by division

$- c (cos(theta) + 1) = Delta x$ by substitution

$- (l / theta) (cos(theta) + 1) = Delta x$ by substitution

$(l / theta) (cos(theta) + 1) = Delta x$ by the magnitude of $overline(B A)$
