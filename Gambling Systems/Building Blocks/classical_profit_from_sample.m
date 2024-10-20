function [profit,palpha_final,pbeta_final] = classical_profit_from_sample(subjective_probs,bet_amounts,tolerance,opt)

    arguments
        subjective_probs = double_stunted_gaussian_inverse_gamma(rand(1,1e3),1/2,1/20);
        bet_amounts = ones(1,length(subjective_probs));
        tolerance = 10; % in basis points of sum of all bet amounts
        opt.include_waitbar = 0;
    end
    
    num_samples = length(subjective_probs);
    [subjective_probs,sample_indeces] = sort(subjective_probs);
    bet_amounts = bet_amounts(sample_indeces);
    
    profit = 0;
    palpha_final = nan;
    pbeta_final = nan;
    
    if opt.include_waitbar
        f = waitbar(0,'Starting Process','Name','Solving For Traditional Sportsbook');
    end
    for palpha_index = 1:num_samples

        if opt.include_waitbar
            progress_value = (palpha_index^2+palpha_index)/(num_samples^2+num_samples);
            waitbar(progress_value,f,sprintf('%.1f Percent Complete',100*progress_value));
        end

        for pbeta_index = 1:(palpha_index-1)
            palpha = subjective_probs(palpha_index);
            pbeta = subjective_probs(pbeta_index);
            alpha = 100*palpha/(1-palpha);
            beta = 100*pbeta/(1-pbeta);
    
            money_on_favorite = sum(bet_amounts(palpha_index:num_samples));
            money_on_underdog = sum(bet_amounts(1:pbeta_index));

            % Modified for Minimum Increments of 1 Cent
            winnings_for_favorite = sum(round(100/alpha*bet_amounts(palpha_index:num_samples),2));
            winnings_for_underdog = sum(round(beta/100*bet_amounts(1:pbeta_index),2));

            profit_favorite_win = money_on_underdog - winnings_for_favorite;
            profit_underdog_win = money_on_favorite - winnings_for_underdog;
            if abs(profit_favorite_win-profit_underdog_win) <= tolerance*sum(bet_amounts)/10000
                if min(profit_favorite_win,profit_underdog_win) > profit
                    profit = min(profit_favorite_win,profit_underdog_win);
                    palpha_final = palpha;
                    pbeta_final = pbeta;
                end
            end
    
        end
    end
    if opt.include_waitbar
        close(f)
    end
end