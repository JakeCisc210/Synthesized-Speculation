function system_metrics = gambling_system_checker(player_struct,bet_amounts,moneyline_tolerance)

    arguments
        player_struct = struct();
        bet_amounts = [];
        moneyline_tolerance = 10;
    end
    % player_struct is assumed to have the following fields:

        % player_number (scalar)
        % player_probability (scalar)

        % peer2peer_win_conditions (array)
        % peer2peer_bet_amounts (array)
        % peer2peer_pots (array)
        % matched_players (array)
        % match_numbers (array)

        % moneyline_win_condition (scalar)
        % moneyline_palpha (scalar)
        % moneyline_pbeta (scalar)
        % moneyline_earnings (scalar)
        % moneyline_bet_amount (scalar)

        % remaining money (scalar)

     % system_metrics has the following fields
        
        % dollar_accountability (bool)
        % peer_bets_work (bool)
        % moneyline_works (bool)

        % peer2peer_profit (scalar)
        % moneyline_profit (scalar)
        % total_profit (scalar)
        % profit_margin (scalar)
        % subjective_expectation_created (scalar)
        % effective_x (scalar)
        % waste_proportion (scalar)

        % subjective_expectations (array)
        % subjective_standard_deviations (array)


    %% Dollar Accountability and Waste Proportion

    num_players = length(player_struct);
    dollar_accountability = 1;
    unused_money = 0;
    for index = 1:num_players
        peer2peer_betting = sum(player_struct(index).peer2peer_bet_amounts);
        moneyline_betting = player_struct(index).moneyline_bet_amount;
        remaining_money = player_struct(index).remaining_money;
        accounting_error = peer2peer_betting + moneyline_betting + remaining_money - bet_amounts(index);

        % Margin of Error is One Cent
        dollar_accountability = dollar_accountability && (abs(accounting_error) <= .01);
        unused_money = unused_money + remaining_money;
    end

%% Peer Bets

    peer_bets_work = 1;
    peer2peer_profit = 0;
    subjective_expectation_created = 0;
    for player1 = 1:num_players
        prob1 = player_struct(player1).player_probability;   
        matched_players1 = player_struct(player1).matched_players;
    
        if isempty(matched_players1)
            continue
        end
    
        for match_index1 = 1:length(matched_players1) % The Index of This Match for Player 1
            player2 = matched_players1(match_index1);
            prob2 = player_struct(player2).player_probability;
    
            match_number = player_struct(player1).match_numbers(match_index1);        
            match_index2 = find(player_struct(player2).match_numbers == match_number); % The Index of This Match for Player 2
            % In Case of a Self Match
            if ~isscalar(match_index2)
                match_index2 = match_index2(match_index2~=match_index1);
    
                % Self Matches Are Considered a Waste Of Money
                unused_money = unused_money + player_struct(player1).peer2peer_bet_amounts(match_index1) + player_struct(player2).peer2peer_bet_amounts(match_index2);
            end
    
            % Check: Both Players Tracking That They're In The Same Match Together
            one_match_per_match_number = (~isempty(match_index2)) &&  isscalar(match_index2);
            if ~one_match_per_match_number; warning('One Peer Match per Match Number Error'); end
            matching_commumativity = (player_struct(player2).matched_players(match_index2)==player1);
            if ~matching_commumativity; warning('Peer Match Commutativity Error'); end
            same_pot_amount = (player_struct(player1).peer2peer_pots(match_index1)==player_struct(player2).peer2peer_pots(match_index2));
            if ~same_pot_amount; warning('Equivalent Peer Bet Pot Error'); end
            peer_bets_work = peer_bets_work && one_match_per_match_number && matching_commumativity && same_pot_amount;
    
            % Check: Stake Increment Minimum is 1 Cent
            correct_minimum_increment = (mod(player_struct(player1).peer2peer_bet_amounts(match_index1),.01)==0) && (mod(player_struct(player2).peer2peer_bet_amounts(match_index2),.01)==0);
            if ~correct_minimum_increment; warning('Incorrect Minimum Stake Increment for Peer Bet'); end
            peer_bets_work = peer_bets_work && correct_minimum_increment;
    
            % Expected Values and Proper Win Conditions
            if prob1 > prob2
                proper_win_conditions = (player_struct(player1).peer2peer_win_conditions(match_index1)) && (~player_struct(player2).peer2peer_win_conditions(match_index2));
                expected_value1 = prob1*player_struct(player1).peer2peer_pots(match_index1) - player_struct(player1).peer2peer_bet_amounts(match_index1);
                expected_value2 = (1-prob2)*player_struct(player2).peer2peer_pots(match_index2) - player_struct(player2).peer2peer_bet_amounts(match_index2);            
            elseif prob2 > prob1
                proper_win_conditions = (~player_struct(player1).peer2peer_win_conditions(match_index1)) && (player_struct(player2).peer2peer_win_conditions(match_index2));
                expected_value1 = (1-prob1)*player_struct(player1).peer2peer_pots(match_index1) - player_struct(player1).peer2peer_bet_amounts(match_index1);
                expected_value2 = prob2*player_struct(player2).peer2peer_pots(match_index2) - player_struct(player2).peer2peer_bet_amounts(match_index2);     
            else
                % Different Winning Conditions
                proper_win_conditions = (player_struct(player1).peer2peer_win_conditions(match_index1) && ~player_struct(player2).peer2peer_win_conditions(match_index2))...
                    || (~player_struct(player1).peer2peer_win_conditions(match_index1) && player_struct(player2).peer2peer_win_conditions(match_index2));
                if player_struct(player1).peer2peer_win_conditions(match_index1)
                    expected_value1 = prob1*player_struct(player1).peer2peer_pots(match_index1) - player_struct(player1).peer2peer_bet_amounts(match_index1);
                    expected_value2 = (1-prob2)*player_struct(player2).peer2peer_pots(match_index2) - player_struct(player2).peer2peer_bet_amounts(match_index2);
                else
                    expected_value1 = (1-prob1)*player_struct(player1).peer2peer_pots(match_index1) - player_struct(player1).peer2peer_bet_amounts(match_index1);
                    expected_value2 = prob2*player_struct(player2).peer2peer_pots(match_index2) - player_struct(player2).peer2peer_bet_amounts(match_index2);
                end
            end
    
            if ~proper_win_conditions; warning('Improper Peer to Peer Win Conditions'); end
            peer_bets_work = peer_bets_work && proper_win_conditions;
            positive_expectation_values = round(expected_value1,2) >= 0 && round(expected_value2,2) >= 0;
            if ~positive_expectation_values; warning('Negative Peer to Peer Expectation Values'); end
            equivalent_expectation_values = abs(expected_value1-expected_value2) < .01;
            if ~equivalent_expectation_values; warning('Unequal Peer to Peer Expectation Values'); end
            peer_bets_work = peer_bets_work && positive_expectation_values && equivalent_expectation_values;
    
            % Subjective Expectation Value Created And Profit
            stake_sum = player_struct(player1).peer2peer_bet_amounts(match_index1) + player_struct(player2).peer2peer_bet_amounts(match_index2);
            extracted_profit = stake_sum - player_struct(player1).peer2peer_pots(match_index1);
            peer2peer_profit = peer2peer_profit + extracted_profit;
    
            subjective_expectation_created = subjective_expectation_created + expected_value1 + expected_value2;        
        end
    end

    % To Compensate for Double Counting
    peer2peer_profit = peer2peer_profit/2;
    subjective_expectation_created = subjective_expectation_created/2;

%% Money Line Iterations

    moneyline_works = 1;
    for index = 1:num_players
        player_prob = player_struct(index).player_probability;
        palpha = player_struct(index).moneyline_palpha;
        pbeta = player_struct(index).moneyline_pbeta;

        if isnan(palpha) && isnan(pbeta)
            continue
        end
    
        % Check: Only One Moneyline Position Assigned
        only_one_moneyline_position = isnan(palpha) || isnan(pbeta);
        if ~only_one_moneyline_position; warning('Opposing Money Line Positions for Same Player'); end
        moneyline_works = moneyline_works && only_one_moneyline_position;
    
        % Money Line Win Condition and Expecation
        if ~isnan(palpha)
            correct_win_condition = player_struct(index).moneyline_win_condition == 1;
            moneyline_expectation = player_prob*player_struct(index).moneyline_earnings - (1-player_prob)*player_struct(index).moneyline_bet_amount;
        elseif ~isnan(pbeta)
            correct_win_condition = player_struct(index).moneyline_win_condition == 0;
            moneyline_expectation = (1-player_prob)*player_struct(index).moneyline_earnings - player_prob*player_struct(index).moneyline_bet_amount;
        end  
        if ~correct_win_condition; warning('Incorrect Money Win Condition Assigned'); end
        moneyline_works = moneyline_works && correct_win_condition;
        positive_expectation_value = round(moneyline_expectation,2) >= 0;
        if ~positive_expectation_value; warning('Negative Money Line Expectation Value'); end
        moneyline_works = moneyline_works && positive_expectation_value;

        % Include the Subjective Expectation Created by the Money Line
        subjective_expectation_created = subjective_expectation_created + moneyline_expectation;
    end

    moneyline_bet_amounts = [player_struct(:).moneyline_bet_amount];
    moneyline_earnings = [player_struct(:).moneyline_earnings];

    % Minimum Stake and Winnings Increment is One Cent
    correct_minimum_increment = all(mod(moneyline_bet_amounts(~isnan(moneyline_bet_amounts)),.01)==0) && all(mod(moneyline_earnings,.01)==0);
    if ~correct_minimum_increment; warning('Incorrect Minimum Stake/Winnings Increment for Money Line'); end

    % Money Line Profit and Balance
    palpha_values = [player_struct(:).moneyline_palpha];
    unique_palpha_values = sort(unique(palpha_values(~isnan(palpha_values))),'descend');
    pbeta_values = [player_struct(:).moneyline_pbeta];
    unique_beta_values = unique(pbeta_values(~isnan(pbeta_values)));

    moneyline_profit = 0;
    for index = 1:length(unique_palpha_values)
        palpha = unique_palpha_values(index);
        pbeta = unique_beta_values(index);
    
        money_on_favorite = sum(moneyline_bet_amounts(palpha_values == palpha));    
        money_on_underdog = sum(moneyline_bet_amounts(pbeta_values == pbeta));
    
        favorite_earnings = sum(moneyline_earnings(palpha_values == palpha));
        underdog_earnings = sum(moneyline_earnings(pbeta_values == pbeta));
    
        moneyline_balance_threshold = moneyline_tolerance*sum(bet_amounts)/10000;
    
        focal_profit = money_on_underdog - favorite_earnings;
        compliment_profit = money_on_favorite - underdog_earnings;
        
        positive_moneyline_profit = min(focal_profit,compliment_profit) >= 0;
        if ~positive_moneyline_profit; warning('Unprofitable Money Line at Iteration %i',index); end
        moneyline_works = moneyline_works && positive_moneyline_profit;

        balanced_moneyline = abs(focal_profit-compliment_profit) <= moneyline_balance_threshold;
        if ~balanced_moneyline
            warning('Unbalanced Money Line at Iteration %i',index); 
            fprintf('Moneyline Profit - Focal: %d, Compliment: %d \n',focal_profit,compliment_profit)
        end
        moneyline_works = moneyline_works && balanced_moneyline;

        moneyline_profit = moneyline_profit + min(focal_profit,compliment_profit);
    end

    %% User Subjective Expectation and Standard Deviation

    subjective_expectations = nan(1,num_players);
    subjective_standard_deviations = nan(1,num_players);
    for index = 1:num_players
        subjective_prob = player_struct(index).player_probability; 

        focal_winnings = 0;
        compliment_winnings = 0;
        focal_losses = 0;
        compliment_losses = 0;

        % Add in Peer to Peer Bets
        if ~isempty(player_struct(index).peer2peer_win_conditions)
            focal_winnings = focal_winnings + sum(player_struct(index).peer2peer_win_conditions.*player_struct(index).peer2peer_pots);
            compliment_winnings = compliment_winnings + sum(~player_struct(index).peer2peer_win_conditions.*player_struct(index).peer2peer_pots);
            focal_losses = focal_losses + sum(player_struct(index).peer2peer_bet_amounts);
            compliment_losses = compliment_losses + sum(player_struct(index).peer2peer_bet_amounts);
        end

        % Add in Money Line Bets
        if ~isnan(player_struct(index).moneyline_win_condition)
            focal_winnings = focal_winnings + player_struct(index).moneyline_win_condition*player_struct(index).moneyline_earnings;
            compliment_winnings = compliment_winnings + ~player_struct(index).moneyline_win_condition*player_struct(index).moneyline_earnings;
            focal_losses = focal_losses + ~player_struct(index).moneyline_win_condition*player_struct(index).moneyline_bet_amount;
            compliment_losses = compliment_losses + player_struct(index).moneyline_win_condition*player_struct(index).moneyline_bet_amount;
        end
        
        subjective_expectation = subjective_prob*(focal_winnings-focal_losses) + (1-subjective_prob)*(compliment_winnings-compliment_losses);
        subjective_variance = subjective_prob*power(focal_winnings-focal_losses-subjective_expectation,2) + (1-subjective_prob)*power(compliment_winnings-compliment_losses-subjective_expectation,2);

        subjective_expectations(index) = subjective_expectation;
        subjective_standard_deviations(index) = sqrt(subjective_variance);
    end


    % Five Basis Points of Subjective Expectation Estimate Divergence Allowed
    if abs(subjective_expectation_created-sum(subjective_expectations))/sum(bet_amounts) >= 5e-4
        warning('Significant Differences In Subjective Expectation Estimates')
        fprintf('Subjective Expection - Official: %d, Checking: %d \n',subjective_expectation_created,sum(subjective_expectations))
    end

    %% Assign System Metrics

    system_metrics.dollar_accountability = dollar_accountability;
    system_metrics.peer_bets_work = peer_bets_work;
    system_metrics.moneyline_works = moneyline_works;
  
    system_metrics.peer2peer_profit = peer2peer_profit;
    system_metrics.moneyline_profit = moneyline_profit;
    system_metrics.total_profit = moneyline_profit + peer2peer_profit;
    system_metrics.profit_margin = (moneyline_profit + peer2peer_profit)/sum(bet_amounts);
    system_metrics.subjective_expectation_created = subjective_expectation_created;
    system_metrics.effective_x = 2*peer2peer_profit/subjective_expectation_created;
    system_metrics.waste_proportion = unused_money/sum(bet_amounts);

    system_metrics.subjective_expectations = subjective_expectations;
    system_metrics.subjective_standard_deviations = subjective_standard_deviations;
end



