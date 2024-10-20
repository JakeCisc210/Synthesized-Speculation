function brier_score(numTrials)

    arguments
        numTrials = 1000;
    end
    
    figure('Position',[100 100 540 400])
    plot([0 0],[100,100])
    xlim([0 100])
    ylim([0 100])
    xlabel('Predictor Probability')
    ylabel('Real Probability')
    hold on
    
    scoreMatrix = zeros(99,99);
    
    for p = .01:.01:.99
        for pr = .01:.01:.99
            score = 0;
            for index = 1:numTrials
                result = rand(); % result < pr Implies Focal Event Occurs
             
                if result < pr
                    score = score + 1/2*( power(1-p,2) + power(1-p,2) )/numTrials; % Divisor Accounts for Average
                end
                     
                if result > pr
                    score = score + 1/2*( power(p,2) + power(p,2) )/numTrials;
                end
                
            end
            
            scoreMatrix(int32(100*pr),int32(100*p)) = score;                 
        end
    end
    
    
    rgbMatrix = zeros(99,99,3);
    for r = 1:99
        for c = 1:99
            rgbMatrix(r,c,1) = min(3-3*scoreMatrix(r,c),1);
            rgbMatrix(r,c,2) = min(3/2*scoreMatrix(r,c),1);
            rgbMatrix(r,c,3) = 0;
        end
    end
    
    image(rgbMatrix)   
end