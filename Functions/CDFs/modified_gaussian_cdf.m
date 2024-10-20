function value = modified_gaussian_cdf(p,center,spread)
    % p either a single number or in the form of [a:b]
    if p > center+2*spread
        value = 1;
    elseif p < center-2*spread
        value = 0;
    else
	    value = erf((p-center)./sqrt(2)./spread)./2./erf(sqrt(2)) + 1/2;
    end
end