function predictor_scoring(numTrials,opt)

    arguments
        numTrials = 1000;
        opt.BetProperty = 1;
        % 0 for Equivalent Expected Value
        % 1 for Equivalent Bet Amount
    end
    
    scoreMatrix = zeros(99);
    probabilitySpace = .01:.01:99;
    for r = 1:99
        for c = 1:99
            pReal = probabilitySpace(r);
            pUser = probabilitySpace(c);
            scoreUser = 0;
            for ii = 1:numTrials
                pRandom = rand();
                chance = rand();
                
                if pUser > pRandom && chance < pReal
                    if opt.BetProperty == 0
                        betRandom = (2-pUser-pRandom)/(pUser+pRandom);
                    end
                    if opt.BetProperty == 1 
                        betRandom = 1;
                    end
                    scoreUser = scoreUser + betRandom;
                end
                
                if pUser < pRandom && chance > pReal
                    if opt.BetProperty == 0
                        betRandom = (pUser+pRandom)/(2-pUser-pRandom);
                    end
                    if opt.BetProperty == 1
                        betRandom = 1;
                    end       
                    scoreUser = scoreUser + betRandom;
                end         
                
                if (pUser > pRandom && chance > pReal) || (pUser < pRandom && chance < pReal)
                    scoreUser = scoreUser - 1;
                end
            end
            
            scoreMatrix(r,c) = scoreUser/numTrials;
        end
    end
    
    colorMatrix = zeros(99,99,3);
    maxScore = max(scoreMatrix,[],"all");
    minScore = min(scoreMatrix,[],"all");
    for r = 1:99
        for c = 1:99
            percent = (scoreMatrix(r,c)-minScore)/(maxScore-minScore);
            colorMatrix(r,c,:) = [min(3-3*percent,1) min(3/2*percent,1) 0];
        end
    end
    
    figure 
    tiledlayout(1,2,"TileSpacing","compact")
    
    nexttile
    myAxes = gca;
    image(colorMatrix)
    xlabel("User Probability")
    ylabel("Real Probability")
    title("Comparison Score Given Real Probabilities")
    myAxes.FontSize = 16;
    myAxes.FontWeight = 'bold';
    myAxes.LineWidth = 2.0;
    grid on
    
    nexttile
    myAxes = gca;
    scoreDiff = (maxScore-minScore)/100;
    for ii = 1:100
        percent = ii/100;
        localColor = [min(3-3*percent,1) min(3/2*percent,1) 0];
        score = minScore * percent*(maxScore-minScore);
        patch([0 0 1 1],[score score-scoreDiff score-scoreDiff score],localColor,'EdgeColor','none')
    end
    ylabel("Score")
    xticks([])
    title("Comparison Score Chart")
    myAxes.YAxisLocation = 'right';
    myAxes.FontSize = 16;
    myAxes.FontWeight = 'bold';
    myAxes.LineWidth = 2.0;
    
    fprintf("Mean Value is %d with Standard Deviation %d\n",mean(scoreMatrix,"all"),std(scoreMatrix,1,"all"))
    fprintf("Theoretical Value is %d\n",2*log(2)-1)
    