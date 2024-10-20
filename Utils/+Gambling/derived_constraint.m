function value = derived_constraint(density,gamma,pbeta,palpha)
% Takes density, gamma, vLow, vHigh
% Assumes maximum value of palpha is 1e6

% Returns the value of the equation corresponding to the second equation
% for the optimized classical money line as derived by Lagrange Multipliers
        term1 = gamma(pbeta).*(gamma(1e6)-gamma(palpha));
        term2 = palpha.*(1-palpha).*density(palpha).*gamma(pbeta);
        term3 = pbeta.*(1-pbeta).*density(pbeta).*(gamma(1e6)-gamma(palpha));
        term4 = (palpha-pbeta).*(1-pbeta).*palpha.*density(palpha).*density(pbeta);
        value = term1 + term2 + term3 - term4;
end