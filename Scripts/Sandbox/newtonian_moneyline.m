function [alpha_index,beta_index] = newtonian_moneyline(p_array,b_array)

    arguments
        p_array = .4+randi(200,1,100)/1000;
        b_array = randi(10000,1,100)/100;
    end

    prob_values = (1:999)/1000;
    pool_values = zeros(1,999);
    for ii = 1:length(p_array)
        pool_values( round(p_array(ii)*1000) ) = pool_values( round(p_array(ii)*1000) ) + b_array(ii);
    end

    empty_slot = (pool_values == 0);
    prob_values = prob_values(~empty_slot);
    pool_values = pool_values(~empty_slot);
    
    % plot(prob_values,pool_values)

    mesh_size = length(prob_values);

    % Loop over indexs for alpha and beta
    alpha_index = round(mesh_size/2);
    beta_index = alpha_index;

    counter = 0;
    while counter < 1000 

        % Partial Derivative: Prime Constraint vs p_alpha
        left_change = vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index)-vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index-1);
        left_slope = left_change/(prob_values(alpha_index)-prob_values(alpha_index-1));

        right_change = vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index+1)-vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index);
        right_slope = right_change/(prob_values(alpha_index+1)-prob_values(alpha_index));

        J11 = (left_slope+right_slope)/2;

        % Partial Derivative: Prime Constraint vs p_beta
        left_change = vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index)-vector_prime_constraint(prob_values,pool_values,beta_index-1,alpha_index);
        left_slope = left_change/(prob_values(beta_index)-prob_values(beta_index-1));

        right_change = vector_prime_constraint(prob_values,pool_values,beta_index+1,alpha_index)-vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index);
        right_slope = right_change/(prob_values(beta_index+1)-prob_values(beta_index));

        J12 = (left_slope+right_slope)/2;

        % Partial Derivative: Derived Constraint vs p_alpha
        left_change = vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index)-vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index-1);
        left_slope = left_change/(prob_values(alpha_index)-prob_values(alpha_index-1));

        right_change = vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index+1)-vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index);
        right_slope = right_change/(prob_values(alpha_index+1)-prob_values(alpha_index));

        J21 = (left_slope+right_slope)/2;

        % Partial Derivative: Derived Constraint vs p_beta
        left_change = vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index)-vector_derived_constraint(prob_values,pool_values,beta_index-1,alpha_index);
        left_slope = left_change/(prob_values(beta_index)-prob_values(beta_index-1));

        right_change = vector_derived_constraint(prob_values,pool_values,beta_index+1,alpha_index)-vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index);
        right_slope = right_change/(prob_values(beta_index+1)-prob_values(beta_index));

        J22 = (left_slope+right_slope)/2;

        % Jacobian and Updates
        J = [J11 J12; J21 J22];
        constraint_vector = [vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index); vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index)];
        if abs(det(J)) <= 100*eps; error('Singular Jacobian'); end
        
        step_sizes = -1*J\constraint_vector;

        new_p_alpha = prob_values(alpha_index)+step_sizes(1)
        [~,new_alpha_index] = min( abs(new_p_alpha-prob_values) );

        new_p_beta = prob_values(beta_index)+step_sizes(2)
        [~,new_beta_index] = min( abs(new_p_beta-prob_values) );

        % In Case of a Tie:
        new_alpha_index = new_alpha_index(1); new_beta_index = new_beta_index(1);

        if new_alpha_index == alpha_index && new_beta_index == beta_index
            break
        else
            alpha_index = new_alpha_index;
            beta_index = new_beta_index;

            % Prevent Edge Cases
            if alpha_index == mesh_size; alpha_index = mesh_size-1; end
            if beta_index == 1; beta_index = 2; end
        end

        counter = counter + 1;
    end


end