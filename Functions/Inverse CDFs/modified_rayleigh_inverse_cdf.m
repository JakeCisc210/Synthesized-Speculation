function value = modified_rayleigh_inverse_cdf(percentile,B)
    % p either a single number or in the form of [a:b]
	value = 3/10 + icdf('Rayleigh',(cdf('Rayleigh',3/5,B)-cdf('Rayleigh',0,B))*percentile,B);
end