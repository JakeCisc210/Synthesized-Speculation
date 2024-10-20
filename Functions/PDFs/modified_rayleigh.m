function value = modified_rayleigh(p,B)
    % p either a single number or in the form of [a:b]
    % center is the mean
    % spread is the standard deviation
    value = (p >= 3/10 & p <= 9/10).*pdf('Rayleigh',p-3/10,B)/(cdf('Rayleigh',3/5,B)-cdf('Rayleigh',0,B));
end   