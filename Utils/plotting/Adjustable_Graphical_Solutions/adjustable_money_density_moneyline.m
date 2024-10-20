function adjustable_money_density_moneyline(funct,FUNCT,centerRange,spreadRange)
    % Plots money density function with manipulatable center and spreads
    % Solves for the optimal moneyline and plots the regions enclosed
    % by both moneyline values
    
    % funct - money density
    % FUNCT - integral of money density
    % centerRange - maximum and minimum center values
    % spreadRange - maximum and minimum spread values
     
    arguments
        funct = @(p,center,spread) double_stunted_gaussian(p,center,spread); 
        FUNCT = @(p,center,spread) double_stunted_gaussian_gamma(p,center,spread);
        centerRange = [.3 .7];
        spreadRange = [.01 .15];
    end
    
    myFigure = uifigure('Name','Moneyline for Adjusted Money Density','Position',[200 75 1200 670]);
    myAxes = uiaxes(myFigure,'Position',[50 100 1100 500]);
    myAxes.FontSize = 20; myAxes.FontWeight = 'bold'; myAxes.LineWidth = 2; 
    myAxes.XAxis.Label.String = 'Probability'; myAxes.YAxis.Label.String = 'Money Density';
    myAxes.XLim = [0 1]; myAxes.YLim = [0 funct(1/2,1/2,spreadRange(1))];
       
    center = centerRange(1);
    spread = spreadRange(1);
    money_density = @(p) funct(p,center,spread);
    gamma = @(p) FUNCT(p,center,spread);
    
    % Checking that probability function obeys probability laws
    if ~isempty(find(money_density(0:.01:1)<0,1)); error('Negative Values for Money Density Function in [0, 1]'); end 
    if abs(integral(money_density,0,1)-1) > 1e-4; error('Money Density not normalized'); end
    
    % Checking that FUNCT = integral(funct,0,p)
    for ii = 1:10
        pTest = rand();
        integralDiff = abs(integral(money_density,0,pTest)-gamma(pTest));     
        if integralDiff > .1; error('FUNCT ~= integral(funct), error of %d',integralDiff); end
    end
    
    % Adding the Sliders
    uilabel(myFigure,'Text','Center','Position',[775 65 100 50],'FontSize',16,'FontWeight','bold');
    centerSlider = uislider(myFigure,'Position',[700 70 200 50],...
        'Limits',centerRange,'Value',mean(centerRange),'MajorTicks',...
        centerRange(1):.05:centerRange(2));

    uilabel(myFigure,'Text','Spread','Position',[375 65 100 50],'FontSize',16,'FontWeight','bold');
    spreadSlider = uislider(myFigure,'Position',[300 70 200 50],...
        'Limits',spreadRange,'Value',mean(spreadRange),'MajorTicks',...
        spreadRange(1):.05:spreadRange(2));
    
    palphaLabel = uilabel(myFigure,'Text','Slide to Fill','Position',[800 450 300 50],'FontSize',16,'FontWeight','bold');
    pbetaLabel = uilabel(myFigure,'Text','Slide to Fill','Position',[1000 450 300 50],'FontSize',16,'FontWeight','bold');
    profitLabel = uilabel(myFigure,'Text','Slide to Fill','Position',[900 400 300 50],'FontSize',16,'FontWeight','bold');
        
    centerSlider.ValueChangedFcn = @(inputSlider,event) money_density_center_callback(inputSlider,spreadSlider,funct,FUNCT,myAxes,palphaLabel,pbetaLabel,profitLabel);
    spreadSlider.ValueChangedFcn = @(inputSlider,event)  money_density_spread_callback(inputSlider,centerSlider,funct,FUNCT,myAxes,palphaLabel,pbetaLabel,profitLabel);
    
end
    
    
    
    
