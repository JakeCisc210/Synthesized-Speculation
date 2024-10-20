function [player_struct] = betting_exchange_gambling_system(subjective_probs,bet_amounts,tolerance,commission)
    
    arguments
        subjective_probs = modified_gaussian_inverse_cdf(rand(1,1e3),5/10,1/20);
        bet_amounts = round(100*rand(1,1e3),2); % Assuming Bet Amounts were Inedependent of Subjective Probability
        tolerance = 10;
        commission = 2; % In Percent of Winnings
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

    % Create a Balanced Moneyline w/o Profit
    [sorted_subjective_probs,sort_indeces] = sort(subjective_probs);
    sorted_bet_amounts = bet_amounts(sort_indeces);

    p_middle_final = nan;
    lowest_profit_distance = inf;
    for p_middle_index = 1:num_players

        p_middle = sorted_subjective_probs(p_middle_index);
        alpha = 100*p_middle/(1-p_middle);
        beta = alpha;

        money_on_favorite = sum(sorted_bet_amounts(p_middle_index:num_players));
        money_on_underdog = sum(sorted_bet_amounts(1:p_middle_index));

        % Modified for Minimum Increments of 1 Cent
        winnings_for_favorite = sum(round(100/alpha*sorted_bet_amounts(p_middle_index:num_players),2));
        winnings_for_underdog = sum(round(beta/100*sorted_bet_amounts(1:p_middle_index),2));

        zero_profit_if_favorite_wins = abs(winnings_for_favorite-money_on_underdog) <= tolerance*sum(bet_amounts)/10000;
        zero_profit_if_underdog_wins = abs(winnings_for_underdog-money_on_favorite) <= tolerance*sum(bet_amounts)/10000;

        profit_distance = sqrt(power(winnings_for_favorite-money_on_underdog,2) + power(winnings_for_underdog-money_on_favorite,2));

        if zero_profit_if_favorite_wins && zero_profit_if_underdog_wins
            if profit_distance <= lowest_profit_distance
                lowest_profit_distance = profit_distance;
                p_middle_final = p_middle;
            end
        end

    end
    
    % Update Player Struct
    for index = 1:num_players
        player_prob = subjective_probs(index);
        if player_prob <= p_middle_final
            player_struct(index).moneyline_win_condition = 0;
            player_struct(index).moneyline_pbeta = p_middle_final;
            player_struct(index).moneyline_palpha = nan;
            player_struct(index).moneyline_bet_amount = bet_amounts(index);
            player_struct(index).remaining_money = 0;
            beta = 100*p_middle_final/(1-p_middle_final);
            % Minimum Increment of Winnings is One Cent
            player_struct(index).moneyline_earnings = round(beta/100*bet_amounts(index),2);

            % Commission Taken by Betting Exchange
            player_struct(index).moneyline_earnings = round(player_struct(index).moneyline_earnings-commission/100*player_struct(index).moneyline_earnings,2);

            % Check if Expectation Value is Positive ... If Not, No Bet
            expectation_value = (1-player_prob)*player_struct(index).moneyline_earnings - player_prob*player_struct(index).moneyline_bet_amount;
            if round(expectation_value,2) < 0
                player_struct(index).moneyline_win_condition = nan;
                player_struct(index).moneyline_pbeta = nan;
                player_struct(index).moneyline_palpha = nan;
                player_struct(index).moneyline_bet_amount = 0;
                player_struct(index).remaining_money = bet_amounts(index);
                player_struct(index).moneyline_earnings = 0;
            end

        elseif player_prob > p_middle_final
            player_struct(index).moneyline_win_condition = 1;
            player_struct(index).moneyline_pbeta = nan;
            player_struct(index).moneyline_palpha = p_middle_final;
            player_struct(index).moneyline_bet_amount = bet_amounts(index);
            player_struct(index).remaining_money = 0;
            alpha = 100*p_middle_final/(1-p_middle_final);
            % Minimum Increment of Winnings is One Cent
            player_struct(index).moneyline_earnings = round(100/alpha*bet_amounts(index),2);

            % Commission Taken by Betting Exchange
            player_struct(index).moneyline_earnings = round(player_struct(index).moneyline_earnings-commission/100*player_struct(index).moneyline_earnings,2);

            % Check if Expectation Value is Positive ... If Not, No Bet
            expectation_value = (player_prob)*player_struct(index).moneyline_earnings - (1-player_prob)*player_struct(index).moneyline_bet_amount;
            if round(expectation_value,2) < 0
                player_struct(index).moneyline_win_condition = nan;
                player_struct(index).moneyline_pbeta = nan;
                player_struct(index).moneyline_palpha = nan;
                player_struct(index).moneyline_bet_amount = 0;
                player_struct(index).remaining_money = bet_amounts(index);
                player_struct(index).moneyline_earnings = 0;
            end

        else
            player_struct(index).moneyline_win_condition = nan;
            player_struct(index).moneyline_pbeta = nan;
            player_struct(index).moneyline_palpha = nan;
            player_struct(index).moneyline_bet_amount = 0;
            player_struct(index).remaining_money = bet_amounts(index);
            player_struct(index).moneyline_earnings = 0;
        end


    end


end





    