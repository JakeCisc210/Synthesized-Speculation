function value = vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index)
    p_alpha = prob_values(alpha_index);
    p_beta = prob_values(beta_index);
    favorite_pool = sum(pool_values(alpha_index:end));
    underdog_pool = sum(pool_values(1:beta_index));

    value = p_alpha*underdog_pool - (1-p_beta)*favorite_pool;
end