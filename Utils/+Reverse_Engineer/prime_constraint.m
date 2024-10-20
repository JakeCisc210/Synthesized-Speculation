function value = prime_constraint(~,gamma,pbeta,palpha,mu,sigma)
% Takes density, gamma, vLow, vHigh

% Returns the value of the equation corresponding to the balance constraint
% of a classical money line
    value = palpha.*gamma(pbeta,mu,sigma) - (1-pbeta).*(gamma(1e6,mu,sigma)-gamma(palpha,mu,sigma));
end
