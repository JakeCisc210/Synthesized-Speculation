function value = derived_constraint(my_pdf,my_cdf,pbeta,palpha,mu,sigma)
% Takes density, gamma, vLow, vHigh
% Assumes maximum value of palpha is 1e6

% Returns the value of the equation corresponding to the second equation
% for the optimized classical money line as derived by Lagrange Multipliers
        term1 = my_cdf(pbeta,mu,sigma).*(my_cdf(1e6,mu,sigma)-my_cdf(palpha,mu,sigma));
        term2 = palpha.*(1-palpha).*my_pdf(palpha,mu,sigma).*my_cdf(pbeta,mu,sigma);
        term3 = pbeta.*(1-pbeta).*my_pdf(pbeta,mu,sigma).*(my_cdf(1e6,mu,sigma)-my_cdf(palpha,mu,sigma));
        term4 = (palpha-pbeta).*(1-pbeta).*palpha.*my_pdf(palpha,mu,sigma).*my_pdf(pbeta,mu,sigma);
        value = term1 + term2 + term3 - term4;
end