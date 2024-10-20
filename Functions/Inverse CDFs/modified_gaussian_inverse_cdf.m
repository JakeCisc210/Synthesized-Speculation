function value = modified_gaussian_inverse_cdf(percentile,center,spread)
    % p either a single number or in the form of [a:b]
	value = sqrt(2)*spread*erfinv(2*erf(sqrt(2)).*(percentile-1/2))+center;
end