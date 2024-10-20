function value = modified_beta_inverse_cdf(percentile,mu,sigma)
    % p either a single number or in the form of [a:b]
	value = 1/4+1/2*betainv(percentile,(4*mu-1)*(4*mu-1)*(3-4*mu)/32/sigma/sigma-2*mu+1/2,(4*mu-1)*(3-4*mu)*(3-4*mu)/32/sigma/sigma+2*mu-3/2);
end