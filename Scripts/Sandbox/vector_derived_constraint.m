function value = vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index)
    p_alpha = prob_values(alpha_index);
    p_beta = prob_values(beta_index);
    favorite_pool = sum(pool_values(alpha_index:end));
    underdog_pool = sum(pool_values(1:beta_index));
    p_alpha_density = pool_values(alpha_index);
    p_beta_density = pool_values(beta_index);    

    term1 = underdog_pool*favorite_pool;
    term2 = p_alpha.*(1-p_alpha)*p_alpha_density*underdog_pool;    
    term3 = p_beta.*(1-p_beta).*p_beta_density*favorite_pool;    
    term4 = (p_alpha-p_beta)*(1-p_beta)*p_alpha*p_alpha_density*p_beta_density;
    value = term1 + term2 + term3 - term4;
end