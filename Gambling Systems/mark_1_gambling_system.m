function [player_struct,profit] = mark_1_gambling_system(subjective_probs,bet_amounts,x,opt)
    
    arguments
        subjective_probs = modified_gaussian_inverse_cdf(rand(1,1e3),5/10,1/20);
        bet_amounts = round(100*rand(1,1e3),2); % Assuming Bet Amounts were Inedependent of Subjective Probability
        % Assuming Each Bet Amount is 1
        x = 2; 
        % x = 1 -> Player Par; x = 2 -> System Par
        opt.moneyline_tolerance = 1; % In Basis Points of Total Bet Amount
        opt.slice_amount = 5; % $5 Slices
    end

    %% Peer to Peer Implementation
    peer_to_peer_pool = bet_amounts - mod(bet_amounts,opt.slice_amount);

    num_slices = sum(peer_to_peer_pool)/opt.slice_amount;
    slice_owners = nan(1,num_slices);
    slice_probs = nan(1,num_slices);

    counter = 0;
    cumulative_slices = cumsum(peer_to_peer_pool)/opt.slice_amount;
    while counter < num_slices
        index = find(counter<cumulative_slices,1,'first');
        slice_owners(counter+1) = index;
        slice_probs(counter+1) = subjective_probs(index);
        counter = counter + 1;
    end

    slice_struct(num_slices) = struct(); % Initialize Struct
    for index = 1:num_slices
        slice_struct(index).player_number = slice_owners(index);
        slice_struct(index).player_probability = slice_probs(index);
    end

    [sorted_subjective_probs,slice_indeces] = sort(slice_probs);

    peer2peer_profit = 0;
    for index = 1:(num_slices/2)
        % Outside In Matching
        prob1 = sorted_subjective_probs(index);
        slice1_number = slice_indeces(index);
        slice1_player = slice_owners(slice1_number);
        assert(prob1 == slice_struct(slice1_number).player_probability)

        prob2 = sorted_subjective_probs(num_slices+1-index);
        slice2_number = slice_indeces(num_slices+1-index);
        slice2_player = slice_owners(slice2_number);
        assert(prob2 == slice_struct(slice2_number).player_probability)

        peer_bet = peer_to_peer(prob1,prob2,opt.slice_amount,x);

        slice_struct(slice1_number).peer2peer_win_condition = peer_bet.player(1).win_condition;
        % Minimum Increment of Stake is One Cent
        slice_struct(slice1_number).peer2peer_bet_amount = round(peer_bet.player(1).bet_amount,2);

        slice_struct(slice1_number).matched_player = slice2_player;

        slice_struct(slice2_number).peer2peer_win_condition = peer_bet.player(2).win_condition;
        % Minimum Increment of Stake is One Cent
        slice_struct(slice2_number).peer2peer_bet_amount = round(peer_bet.player(2).bet_amount,2);

        slice_struct(slice2_number).matched_player = slice1_player;

        % Adjusting the Pot for Rounding
        profit = round(peer_bet.profit,2);
        pot_amount = round(peer_bet.player(1).bet_amount,2) + round(peer_bet.player(2).bet_amount,2) - profit;
        slice_struct(slice1_number).peer2peer_pot = pot_amount;
        slice_struct(slice2_number).peer2peer_pot = pot_amount;


        % Assigning a Match Number
            % Match Number based on ranking of lowest Subjective Probability
        slice_struct(slice1_number).match_number = index;
        slice_struct(slice2_number).match_number = index;

        peer2peer_profit = peer2peer_profit + profit;
    end

%% Condense Slices Struct Into Player Struct

    num_players = length(bet_amounts);
    player_struct(num_players) = struct(); % Initialize Struct
    for index = 1:num_players
        player_struct(index).player_number = index;
        player_struct(index).player_probability = subjective_probs(index);

        include_slice = [slice_struct(:).player_number]==index;
        player_struct(index).peer2peer_win_conditions = [slice_struct(include_slice).peer2peer_win_condition];
        player_struct(index).peer2peer_bet_amounts = [slice_struct(include_slice).peer2peer_bet_amount];
        player_struct(index).peer2peer_pots = [slice_struct(include_slice).peer2peer_pot];
        player_struct(index).matched_players = [slice_struct(include_slice).matched_player];
        player_struct(index).match_numbers = [slice_struct(include_slice).match_number];
    end

%% Money Line Inception

    remaining_bet_money = nan(1,num_players);
    for index = 1:num_players
        remaining_bet_money(index) = bet_amounts(index)-sum(player_struct(index).peer2peer_bet_amounts);   
        assert(remaining_bet_money(index) >= 0)

        % Dealing with a Trifling Bug
        if abs(remaining_bet_money(index)-round(remaining_bet_money(index),2)) <= 1e-4
            remaining_bet_money(index) = round(remaining_bet_money(index),2);
        end
    end

    [moneyline_profit,win_condition_values,palpha_values,pbeta_values] = iterative_classical_profit_from_sample(subjective_probs,remaining_bet_money,opt.moneyline_tolerance,'profit_cutoff',1);
    for index = 1:num_players
        player_struct(index).moneyline_win_condition = win_condition_values(index);
        player_struct(index).moneyline_palpha = palpha_values(index);
        player_struct(index).moneyline_pbeta = pbeta_values(index);
        player_struct(index).moneyline_earnings = nan;

        if isnan(palpha_values(index)) && isnan(pbeta_values(index))
            player_struct(index).moneyline_bet_amount = 0;
            player_struct(index).remaining_money = remaining_bet_money(index);
            player_struct(index).moneyline_earnings = 0;
        else
            player_struct(index).moneyline_bet_amount = remaining_bet_money(index);
            player_struct(index).remaining_money = 0;

            if ~isnan(palpha_values(index))
                alpha = 100*palpha_values(index)/(1-palpha_values(index));
                % Minimum Increment of Winnings is One Cent
                player_struct(index).moneyline_earnings = round(100/alpha*remaining_bet_money(index),2);
            elseif ~isnan(pbeta_values(index))
                beta = 100*pbeta_values(index)/(1-pbeta_values(index));
                % Minimum Increment of Winnings is One Cent
                player_struct(index).moneyline_earnings = round(beta/100*remaining_bet_money(index),2);               
            end
        end
    end

    profit = peer2peer_profit + moneyline_profit;

end





    