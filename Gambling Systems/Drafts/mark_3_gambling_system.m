function [player_struct,profit] = mark_3_gambling_system(sample_values,x,opt)
    
    arguments
        sample_values = modified_gaussian_inverse_cdf(rand(1,1e3),6/10,1/20);
        % Assuming Each Bet Amount is 1
        x = 2; 
        % x = 1 -> Player Par; x = 2 -> System Par
        opt.moneyline_tolerance = 1; % In Basis Points of Total Bet Amount
    end

    num_values = length(sample_values);

    player_struct(num_values) = struct(); % Initialize Struct
    for index = 1:num_values
        player_struct(index).player_number = index;
        player_struct(index).player_probability = sample_values(index);
        player_struct(index).bet_amount = 1;
    end

    %% Money Line Inception

    [moneyline_profit,win_condition_values,palpha_values,pbeta_values] = iterative_classical_profit_from_sample(sample_values,ones(1,num_values),opt.moneyline_tolerance,'number_iterations',1);
    for index = 1:num_values
        player_struct(index).moneyline_win_condition = win_condition_values(index);
        player_struct(index).moneyline_palpha = palpha_values(index);
        player_struct(index).moneyline_pbeta = pbeta_values(index);

        if isnan(palpha_values(index)) && isnan(pbeta_values(index))
            player_struct(index).moneyline_bet_amount = 0;
            player_struct(index).remaining_bet_amount = 1;
        else
            player_struct(index).moneyline_bet_amount = 1;
            player_struct(index).remaining_bet_amount = 0;
        end

        player_struct(index).peer2peer_win_condition = nan;
        player_struct(index).peer2peer_bet_amount = nan;
        player_struct(index).pot = nan;
        player_struct(index).matched_player = nan;

    end

    %% Peer to Peer Implementation

    player_numbers = 1:num_values;
    remaining_player_numbers = player_numbers(isnan(palpha_values) & isnan(pbeta_values));
    remaining_sample_values = sample_values(remaining_player_numbers);

    [sorted_remaining_sample_values,sort_indeces] = sort(remaining_sample_values);
    sorted_remaining_player_numbers = remaining_player_numbers(sort_indeces);
    num_remaining = length(sorted_remaining_sample_values);

    % If there is an odd number of values, we eliminate the median
    if mod(num_remaining,2) == 1
        delete_me_array = zeros(1,num_remaining);
        delete_me_array(ceil(num_remaining/2)) = 1;
        sorted_remaining_sample_values = sorted_remaining_sample_values(~delete_me_array);
        sorted_remaining_player_numbers = sorted_remaining_player_numbers(~delete_me_array);
        num_remaining = length(sorted_remaining_sample_values);
    end


    % Choose the Most Profitable Strategy of Outside-In and Split-n-Pair
    peer2peer_profit = 0;

    for index = 1:(num_remaining/2)
        % Outside In Matching
        prob1 = sorted_remaining_sample_values(index);
        player1_number = sorted_remaining_player_numbers(index);
        assert(prob1 == player_struct(player1_number).player_probability)

        prob2 = sorted_remaining_sample_values(num_remaining+1-index);
        player2_number = sorted_remaining_player_numbers(num_remaining+1-index);
        assert(prob2 == player_struct(player2_number).player_probability)

        peer_bet = peer_to_peer(prob1,prob2,1,x); % Assuming Max Bet Amount of $1

        player_struct(player1_number).peer2peer_win_condition = peer_bet.player(1).win_condition;
        player_struct(player1_number).peer2peer_bet_amount = peer_bet.player(1).bet_amount;
        player_struct(player1_number).pot = peer_bet.pot;
        player_struct(player1_number).matched_player = player2_number;

        player_struct(player2_number).peer2peer_win_condition = peer_bet.player(2).win_condition;
        player_struct(player2_number).peer2peer_bet_amount = peer_bet.player(2).bet_amount;
        player_struct(player2_number).pot = peer_bet.pot;
        player_struct(player2_number).matched_player = player1_number;

        peer2peer_profit = peer2peer_profit + peer_bet.profit;
    end

    % Check with Pre-Existing System
    assert(peer2peer_profit == peer2peer_profit_from_sample(sorted_remaining_sample_values,x))

    profit = peer2peer_profit + moneyline_profit;

end





    