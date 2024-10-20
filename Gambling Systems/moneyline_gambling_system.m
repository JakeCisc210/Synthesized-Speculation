function [player_struct,profit] = moneyline_gambling_system(subjective_probs,bet_amounts,moneyline_tolerance)
    
    arguments
        subjective_probs = modified_gaussian_inverse_cdf(rand(1,1e3),5/10,1/20);
        bet_amounts = round(100*rand(1,1e3),2); % Assuming Bet Amounts were Inedependent of Subjective Probability
        moneyline_tolerance = 10; % In Basis Points of Total Bet Amount
    end

    %% Set Up

    num_players = length(subjective_probs);
    player_struct(num_players) = struct();
    for index = 1:num_players
        player_struct(index).player_number = index;
        player_struct(index).player_probability = subjective_probs(index);
        player_struct(index).peer2peer_win_conditions = [];
        player_struct(index).peer2peer_bet_amounts = [];
        player_struct(index).peer2peer_pots = [];
        player_struct(index).matched_players = [];
        player_struct(index).match_numbers = [];
    end

    %% Money Line

    [moneyline_profit,palpha_final,pbeta_final] = classical_profit_from_sample(subjective_probs,bet_amounts,moneyline_tolerance,'include_waitbar',0);
    for index = 1:num_players
        if subjective_probs(index) <= pbeta_final
            player_struct(index).moneyline_win_condition = 0;
            player_struct(index).moneyline_pbeta = pbeta_final;
            player_struct(index).moneyline_palpha = nan;
            player_struct(index).moneyline_bet_amount = bet_amounts(index);
            player_struct(index).remaining_money = 0;
            beta = 100*pbeta_final/(1-pbeta_final);
            % Minimum Increment of Winnings is One Cent
            player_struct(index).moneyline_earnings = round(beta/100*bet_amounts(index),2);
        elseif subjective_probs(index) >= palpha_final
            player_struct(index).moneyline_win_condition = 1;
            player_struct(index).moneyline_pbeta = nan;
            player_struct(index).moneyline_palpha = palpha_final;
            player_struct(index).moneyline_bet_amount = bet_amounts(index);
            player_struct(index).remaining_money = 0;
            alpha = 100*palpha_final/(1-palpha_final);
            % Minimum Increment of Winnings is One Cent
            player_struct(index).moneyline_earnings = round(100/alpha*bet_amounts(index),2);
        else
            player_struct(index).moneyline_win_condition = nan;
            player_struct(index).moneyline_pbeta = nan;
            player_struct(index).moneyline_palpha = nan;
            player_struct(index).moneyline_bet_amount = 0;
            player_struct(index).remaining_money = bet_amounts(index);
            player_struct(index).moneyline_earnings = 0;
        end
    end

    profit = moneyline_profit;

end





    