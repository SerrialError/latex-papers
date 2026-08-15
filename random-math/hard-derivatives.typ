1. $y = (x^2 + 1)^(sin x) / e^(x cos x)$ find $y'$

$y' = (x^2 + 1)^(sin x) e^(-x cos x)$

$f := (x^2 + 1)^(sin x) quad g := e^(-x cos x)$

$ln f = sin x ln (x^2 + 1) quad g' = (-cos x + x sin x) e^(-x cos x)$

$f' / f = cos x ln (x^2 + 1) + sin x (2 x) / (x^2 + 1)$

$f' = (cos x ln (x^2 + 1) + (2x sin x) / (x^2 + 1)) f$

$y' = f' g + f g'$

$y' = (cos x ln (x^2 + 1) + (2x sin x) / (x^2 + 1)) f e^(-x cos x) + (-cos x + x sin x) e^(-x cos x) f$ 

$y' = e^(-x cos x) (x^2 + 1)^(sin x) ((cos x ln (x^2 + 1) + (2x sin x) / (x^2 + 1)) + (-cos x + x sin x))$

2. $y = ln sqrt(1 + x^2) / (1 + sin x)$ find $y'$

$f := sqrt(1 + x^2) / (1 + sin x)$

$y = ln f$

$y' = f' / f$

$f' = (x (1 + sin x) / sqrt(1 + x^2) - sqrt(1 + x^2) cos x) / (1 + sin x)^2$

$y' = (x (1 + sin x) / sqrt(1 + x^2) - sqrt(1 + x^2) cos x) / (1 + sin x)^2 / (sqrt(1 + x^2) / (1 + sin x))$

$y' = (x (1 + sin x) / sqrt(1 + x^2) - sqrt(1 + x^2) cos x) / ((1 + sin x) sqrt(1 + x^2))$ 

$y' = x / (1 + x^2) - (cos x) / (1 + sin x)$

3. $y = arctan ((2x) / (1 - x^2))$ find $y'$

$f := (2x) / (1 - x^2)$

$y = arctan f$

$y' = f' / (1 + f^2)$

$f' = (2 (1 - x^2) + 4x^2) / (1 - x^2)^2$

$f' = (2 - 2 x^2 + 4x^2) / (1 - x^2)^2$

$f' = 2 (x^2 + 1) / (1 - x^2)^2$

$y' = 2 ((x^2 + 1) / (1 - x^2)^2) / (1 + ((2x) / (1 - x^2))^2)$

$y' = 2 (x^2 + 1) / ((1 - x^2)^2 + 4x^2)$

$y' = 2 (x^2 + 1) / (1 - 2x^2 + x^4 + 4x^2)$

$y' = 2 (x^2 + 1) / (x^4 + 2x^2 + 1)$

$y' = 2 (x^2 + 1) / (x^2 + 1)^2$

$y' = 2 / (x^2 + 1)$
