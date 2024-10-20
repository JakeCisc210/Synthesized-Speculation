function value = prime_constraint(~,gamma,pbeta,palpha)
% Takes density, gamma, vLow, vHigh

% Returns the value of the equation corresponding to the balance constraint
% of a classical money line
    value = palpha.*gamma(pbeta) - (1-pbeta).*(gamma(1e6)-gamma(palpha));
end
