Given

$V = I R + E_("mf")$

$E_("mf") = omega kappa_e$

$tau = I kappa_t$

$tau = J alpha + B omega + tau_("load")$

Find V voltage at some initial angular velocity $omega$, the wanted angular acceleration $alpha$

We know I, J, $tau_("load")$, R, B, $omega$, $alpha$, $kappa_t$, and $kappa_e$. So therefore we only need to find V as it is the only remaining variable.

$I kappa_t = J alpha + B omega + tau_("load")$ By substitution

$I = (J alpha + B omega + tau_("load"))/(kappa_t)$ By Division

$- I R = E_("mf") - V$ By Subtraction

$I = (E_("mf") - V)/(-R)$ By Division

$(E_("mf") - V)/(-R) = (J alpha + B omega + tau_("load"))/(kappa_t)$ By substitution

$(omega kappa_e - V)/(-R) = (J alpha + B omega + tau_("load"))/(kappa_t)$ By substitution

$omega kappa_e - V = (J alpha + B omega + tau_("load"))/(kappa_t) (-R)$ By multiplication

$- V = (J alpha + B omega + tau_("load"))/(kappa_t) (-R) - omega kappa_e$ By subtraction

$V = - ((J alpha + B omega + tau_("load"))/(kappa_t) (-R) - omega kappa_e)$ By division

$V = ((J alpha + B omega + tau_("load"))/(kappa_t) (R) + omega kappa_e)$ By substitution

Define a function $V:RR arrow RR$ by $V(omega, alpha) = ((J alpha + B omega + tau_("load"))/(kappa_t) (R) + omega kappa_e)$

End of Proof

Find the maximum $alpha$ angular acceleration at some angular velocity

Note, the VEX motor controller has current limits so we must also account for those.

Define $I_("min")$ and $I_("max")$ as the current limits and define $I_("clamp")$ as the clamped value of I

$I_("clamp") = min(max(I, I_("min")), I_("max"))$ by the definition of clamping

$I_("clamp") = min(max(((E_("mf") - V)/(-R)), I_("min")), I_("max"))$ by substitution

$I_("clamp") = min(max(((omega kappa_e - V)/(-R)), I_("min")), I_("max"))$ by substitution

Define $V_("max") = V$ as the max voltage

$I_("clamp") = min(max(((omega kappa_e - V_("max"))/(-R)), I_("min")), I_("max"))$ by substitution

Restrict I by $I_("clamp") = I$ by the note

$- J alpha = B omega + tau_("load") - tau$ by Subtraction

$alpha = (B omega + tau_("load") - tau)/(-J)$ by Division

$alpha = (B omega + tau_("load") - I kappa_t)/(-J)$ by Substitution

$alpha = (B omega + tau_("load") - I_("clamp") kappa_t)/(-J)$ by Substitution

Define a function $alpha$ by $alpha (omega) = (B omega + tau_("load") - I_("clamp") kappa_t)/(-J)$
