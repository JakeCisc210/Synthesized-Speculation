function value = modified_gaussian(p,center,spread)
    % p either a single number or in the form of [a:b]
    % center is the mean
    % spread is the standard deviation
    value = (abs(p-center)<= 2.*spread) .* exp(-power(p-center,2)./2./power(spread,2))./sqrt(2.*pi)./spread./erf(sqrt(2)); 
end