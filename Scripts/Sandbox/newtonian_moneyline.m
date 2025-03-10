function [alpha_index,beta_index] = newtonian_moneyline(p_array,b_array)

    arguments
        % p_array = .4+randi(200,1,1000)/1000;
        % b_array = randi(10000,1,1000)/100;
        p_array = round(normrnd(.55,.1,1,1000),3);
        b_array = 5*ones(1,1000);
    end

    prob_values = (1:999)/1000;
    pool_values = zeros(1,999);
    for ii = 1:length(p_array)
        pool_values( round(p_array(ii)*1000) ) = pool_values( round(p_array(ii)*1000) ) + b_array(ii);
    end

    empty_slot = (pool_values == 0);
    prob_values = prob_values(~empty_slot);
    pool_values = pool_values(~empty_slot);
 
    mesh_size = length(prob_values);

    % Loop over indexs for alpha and beta
    alpha_index = round(mesh_size/2);
    beta_index = alpha_index;

    % Error Trackers
    prime_constraint_errors = zeros(1,1000);
    derived_constraint_errors = zeros(1,1000);    

    counter = 1;
    while counter <= 1000 

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
        if abs(det(J)) <= 100*eps; error('Singular Jacobian'); end

        constraint_vector = [vector_prime_constraint(prob_values,pool_values,beta_index,alpha_index); vector_derived_constraint(prob_values,pool_values,beta_index,alpha_index)];
        prime_constraint_errors(counter) = constraint_vector(1);
        derived_constraint_errors(counter) = constraint_vector(2);
        
        step_sizes = -1*J\constraint_vector;

        new_p_alpha = prob_values(alpha_index)+step_sizes(1)
        [~,new_alpha_index] = min( abs(new_p_alpha-prob_values) );

        new_p_beta = prob_values(beta_index)+step_sizes(2)
        [~,new_beta_index] = min( abs(new_p_beta-prob_values) );

        % In Case of a Tie:
        new_alpha_index = new_alpha_index(1); new_beta_index = new_beta_index(1);

        % Prevent Edge Cases
        if new_alpha_index == mesh_size; new_alpha_index = mesh_size-1; end
        if new_beta_index == 1; new_beta_index = 2; end


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

    if counter == 1001; warning('While Loop Hit Maximum Iterations'); counter = 1000; end

    prime_constraint_errors = prime_constraint_errors(1:counter);
    derived_constraint_errors = derived_constraint_errors(1:counter);

    [moneyline_profit,palpha_final,pbeta_final] = classical_profit_from_sample(p_array,b_array,10,'include_waitbar',1)

%% Plotting the Solution

    % The Money Line and Pool Values
    figure
    hold on

    % Adding the Green Area
    green_probs = prob_values(1:beta_index);
    green_pools = pool_values(1:beta_index);
    plot(green_probs,green_pools,'Color',[144,238,144]/255,'LineWidth',.5);
    green_plot = plot(-2,0,'Color',[144,238,144]/255,'LineWidth',10);
    green_x = horzcat(green_probs,flip(green_probs));
    green_y = horzcat(green_pools,zeros(1,beta_index));
    patch(green_x,green_y,[144,238,144]/255,'LineWidth',.5)

    % Adding the Red Area
    red_probs = prob_values(alpha_index:end);
    red_pools = pool_values(alpha_index:end);
    plot(red_probs,red_pools,'Color',[255,114,118]/255,'LineWidth',.5);
    red_plot = plot(-2,0,'Color',[255,114,118]/255,'LineWidth',10);
    red_x = horzcat(red_probs,flip(red_probs));
    red_y = horzcat(red_pools,zeros(1,length(red_probs)));
    patch(red_x,red_y,[255,114,118]/255,'LineWidth',.5)

    % Adding the Gray Area
    gray_probs = prob_values((beta_index+1):(alpha_index-1));
    gray_pools = pool_values((beta_index+1):(alpha_index-1));
    plot(gray_probs,gray_pools,'Color',[200 200 200]/255,'LineWidth',.5);
    gray_plot = plot(-2,0,'Color',[200 200 200]/255,'LineWidth',10);
    gray_x = horzcat(gray_probs,flip(gray_probs));
    gray_y = horzcat(gray_pools,zeros(1,alpha_index-beta_index-1));
    patch(gray_x,gray_y,[200 200 200]/255,'LineWidth',.5)

    % Axes Labels
    xlabel('Subjective Probability')
    ylabel('Pool ($)')
    title('Money Line Pool Partition')
    legend([green_plot,gray_plot,red_plot],{'Bet on Underdog','No Bet','Bet on Favorite'},'TextColor',[0 0 0])
    xlim([min(prob_values)-.025,max(prob_values)+.025])

    % Other Plots
    % figure
    % plot(prime_constraint_errors)
    % 
    % figure
    % plot(derived_constraint_errors)


end