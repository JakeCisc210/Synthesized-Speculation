function  peer_bet = peer_to_peer(p1,p2,M,x)
%%% INPUTS
% P1 - the probability that player 1 submitted for the focal event
%
% P2 - the probability that player 2 submitted for the focal event
%
% M - the maximum bet amount for both players
%
% x - extraction coefficient (the ratio of profit to a single player's
%       expectation value) 

%%% OUTPUTS
% peer_bet is a struct with the following fields:
%
%       pot - the sum of money both players submitted, minus the sportsbook
%               profit
%
%       profit - the amount of money the sportsbook made from arranging this bet
%
%       profitability - profit / (pot + profit) AKA profit / sum of player
%       bets
%
%       extraction coefficient - the ratio of profit to a single player's
%               expectation value
% 
%       player is a struct with the following fields
%               win_condition - 0/1 depending on whether the players wins if the
%                       focal event doesn't happen/happens
%               bet_amount - amount the player must put in 
%     
    peer_bet.profit = x*M*(max(p1,p2)-min(p1,p2)) / (max(p1+p2,2-p1-p2)+ x*max(max(p1,p2),1-min(p1,p2)) );
    peer_bet.pot = (2*M-peer_bet.profit)/max(p1+p2,2-p1-p2);
    peer_bet.profitability = peer_bet.profit/(peer_bet.profit+peer_bet.pot);
    
    if p1 > p2
        peer_bet.player(1).win_condition = 1;
        peer_bet.player(2).win_condition = 0;
               
        if p1 + p2 >= 1
            peer_bet.player(1).bet_amount = M;
            peer_bet.player(2).bet_amount = peer_bet.pot+peer_bet.profit-M;
        else
            peer_bet.player(1).bet_amount = peer_bet.pot+peer_bet.profit-M;
            peer_bet.player(2).bet_amount = M;            
        end   
    elseif p2 > p1
        peer_bet.player(1).win_condition = 0;
        peer_bet.player(2).win_condition = 1;
               
        if p1 + p2 >= 1
            peer_bet.player(1).bet_amount = peer_bet.pot+peer_bet.profit-M;
            peer_bet.player(2).bet_amount = M;
        else
            peer_bet.player(1).bet_amount = M;
            peer_bet.player(2).bet_amount = peer_bet.pot+peer_bet.profit-M;            
        end        
    else
        coin_flip = rand()>1/2;
        peer_bet.player(1).win_condition = coin_flip;
        peer_bet.player(2).win_condition = ~coin_flip;

        if peer_bet.player(1).win_condition
            if p1 + p2 >= 1
                peer_bet.player(1).bet_amount = M;
                peer_bet.player(2).bet_amount = peer_bet.pot+peer_bet.profit-M;
            else
                peer_bet.player(1).bet_amount = peer_bet.pot+peer_bet.profit-M;
                peer_bet.player(2).bet_amount = M;
            end

        elseif peer_bet.player(2).win_condition
            if p1 + p2 >= 1
                peer_bet.player(1).bet_amount = peer_bet.pot+peer_bet.profit-M;
                peer_bet.player(2).bet_amount = M;
            else
                peer_bet.player(1).bet_amount = M;
                peer_bet.player(2).bet_amount = peer_bet.pot+peer_bet.profit-M;
            end
        else
            error('Coin Flip Failed')
        end
    end
end
