function [player_struct,profit] = mark_1_gambling_system(sample_values,x,opt)
    
    arguments
        sample_values = modified_gaussian_inverse_cdf(rand(1,1e3),6/10,1/20);
        % Assuming Each Bet Amount is 1
        x = 2; 
        % x = 1 -> Player Par; x = 2 -> System Par
        opt.moneyline_tolerance = 1; % In Basis Points of Total Bet Amount
    end

    num_samples = length(sample_values);

    player_struct(num_samples) = struct(); % Initialize Struct
    for index = 1:num_samples
        player_struct(index).player_number = index;
        player_struct(index).player_probability = sample_values(index);
        player_struct(index).bet_amount = 1;
    end

    %% Peer to Peer Implementation

    [sorted_sample_values,player_numbers] = sort(sample_values);


    peer2peer_profit = 0;
    for index = 1:(num_samples/2)
        % Outside In Matching
        prob1 = sorted_sample_values(index);
        player1_number = player_numbers(index);
        assert(prob1 == player_struct(player1_number).player_probability)

        prob2 = sorted_sample_values(num_samples+1-index);
        player2_number = player_numbers(num_samples+1-index);
        assert(prob2 == player_struct(player2_number).player_probability)

        peer_bet = peer_to_peer(prob1,prob2,1,x);

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

    % Check with Preexisting Function
    assert(peer2peer_profit == peer2peer_profit_from_sample(sample_values,x))

%% Money Line Inception

    remaining_bet_money = zeros(1,num_samples);
    for index = 1:num_samples
        remaining_bet_money(index) = 1 - player_struct(index).peer2peer_bet_amount;        
    end

    [moneyline_profit,win_condition_values,palpha_values,pbeta_values] = iterative_classical_profit_from_sample(sample_values,remaining_bet_money,opt.moneyline_tolerance,'profit_cutoff',1e-3);
    for index = 1:num_samples
        player_struct(index).moneyline_win_condition = win_condition_values(index);
        player_struct(index).moneyline_palpha = palpha_values(index);
        player_struct(index).moneyline_pbeta = pbeta_values(index);

        if isnan(palpha_values(index)) && isnan(pbeta_values(index))
            player_struct(index).moneyline_bet_amount = 0;
            player_struct(index).remaining_bet_amount = remaining_bet_money(index);
        else
            player_struct(index).moneyline_bet_amount = remaining_bet_money(index);
            player_struct(index).remaining_bet_amount = 0;
        end
    end

    profit = peer2peer_profit + moneyline_profit;

end





    