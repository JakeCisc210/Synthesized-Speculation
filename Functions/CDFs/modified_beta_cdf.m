function value = modified_beta_cdf(p,mu,sigma)
    % p either a single number or in the form of [a:b]
    if p < 1/4
        value = 0;
    elseif p > 3/4
        value = 1;
    else
	    value = betacdf(2*p-1/2,(4*mu-1).*(4*mu-1).*(3-4*mu)/32./sigma./sigma-2*mu+1/2,(4*mu-1).*(3-4*mu).*(3-4*mu)/32./sigma./sigma+2*mu-3/2);
    end
end