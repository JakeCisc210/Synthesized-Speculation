function [profit,win_condition_values,palpha_values,pbeta_values] = iterative_classical_profit_from_sample(subjective_probs,bet_amounts,tolerance,opt)

    arguments
        subjective_probs = double_stunted_gaussian_inverse_gamma(rand(1,1e3),1/2,1/20);
        bet_amounts = ones(1,length(subjective_probs));
        tolerance = 1; % in basis points of sum of all bet amounts
        opt.number_iterations = 3;
        opt.profit_cutoff = nan; % In Basis Points of the overall betting amount
        % If not nan, profit_cutoff option takes precedence
    end
    
    num_samples = length(subjective_probs);
    [subjective_probs,sort_indeces] = sort(subjective_probs);
    [~,reverse_indeces] = sort(sort_indeces);
    remaining_bet_money = bet_amounts(sort_indeces);

    profit = 0;
    win_condition_values = nan(1,num_samples);
    palpha_values = nan(1,num_samples);
    pbeta_values = nan(1,num_samples);

    if isnan(opt.profit_cutoff)
        counter = 1;
        while counter <= opt.number_iterations 
            [moneyline_profit,palpha,pbeta] = classical_profit_from_sample(subjective_probs,remaining_bet_money,tolerance,'include_waitbar',0);
            profit = profit + moneyline_profit;
            for index = 1:num_samples
                if remaining_bet_money(index) % Evaluates to True if Not Equal to Zero
                    if subjective_probs(index) >= palpha
                        win_condition_values(index) = 1;
                        palpha_values(index) = palpha;
                        remaining_bet_money(index) = 0;
                    elseif subjective_probs(index) <= pbeta
                        win_condition_values(index) = 0;
                        pbeta_values(index) = pbeta;
                        remaining_bet_money(index) = 0;
                    end
                end
            end
            counter = counter + 1;
        end
    else
        moneyline_profit = inf;
        while moneyline_profit >= (opt.profit_cutoff)*sum(bet_amounts)/10000
            [moneyline_profit,palpha,pbeta] = classical_profit_from_sample(subjective_probs,remaining_bet_money,tolerance,'include_waitbar',0);
            profit = profit + moneyline_profit;
            for index = 1:num_samples
                if remaining_bet_money(index) % Evaluates to True if Not Equal to Zero
                    if subjective_probs(index) >= palpha
                        win_condition_values(index) = 1;
                        palpha_values(index) = palpha;
                        remaining_bet_money(index) = 0;
                    elseif subjective_probs(index) <= pbeta
                        win_condition_values(index) = 0;
                        pbeta_values(index) = pbeta;
                        remaining_bet_money(index) = 0;
                    end
                end
            end
        end
    end

    % Reorder to Match Original Sample Values
    win_condition_values = win_condition_values(reverse_indeces);
    palpha_values = palpha_values(reverse_indeces);
    pbeta_values = pbeta_values(reverse_indeces);
   
end