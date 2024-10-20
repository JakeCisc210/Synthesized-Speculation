function value = modified_rayleigh_cdf(p,B)
    % p either a single number or in the form of [a:b]
    if p < 3/10
        value = 0;
    elseif p > 9/10
        value = 1;
    else
        value = cdf('Rayleigh',p-3/10,B)/(cdf('Rayleigh',3/5,B)-cdf('Rayleigh',0,B));
    end
end   
        
        
        
        
