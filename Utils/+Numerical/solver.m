function [vL,vH,profitMax] = solver(system_utility,prime_constraint,range,tolerance,myOptions)

% For Macroscopic Matching

    arguments
        system_utility = @(pa,pb) (pa-pb)*(pb-5)
        prime_constraint = @(pa,pb) 15 - pa - pb;
        range = [5 10];
        tolerance = 1e-4;
        myOptions.grainSize = diff(range)/1000;
    end
   
    valueMesh = range(1):myOptions.grainSize:range(2);
    
    profitMax = 0;
    idealParameters = [0 0];
    
    for lowIndex = 1:length(valueMesh)
        for highIndex = lowIndex:length(valueMesh)
            lowValue = valueMesh(lowIndex);
            highValue = valueMesh(highIndex);
            
            if abs(prime_constraint(lowValue,highValue)) <= tolerance
                if system_utility(lowValue,highValue) > profitMax
                    profitMax = system_utility(lowValue,highValue);
                    idealParameters = [lowValue highValue];
                end
            end
        end
    end
    vL = idealParameters(1); 
    vH = idealParameters(2);
    
end
                    
                