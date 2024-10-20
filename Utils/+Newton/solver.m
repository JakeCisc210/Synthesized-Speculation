function [v1,v2] = solver(prime_constraint,derived_constraint,tolerance,range1,range2)
    arguments
        prime_constraint = @(mu,sigma) Reverse_Engineer.prime_constraint(@(p,mu,sigma) modified_beta(p,mu,sigma),@(p,mu,sigma) modified_beta_cdf(p,mu,sigma),.54,.59,mu,sigma);
        derived_constraint = @(mu,sigma) Reverse_Engineer.derived_constraint(@(p,mu,sigma) modified_beta(p,mu,sigma),@(p,mu,sigma) modified_beta_cdf(p,mu,sigma),.54,.59,mu,sigma);
        tolerance = 10; % In terms of Basis Points
        range1 = [.25 .75];
        range2 = [.01 .15];

    end
    % range is of the form [lowerBound upperBound]

    if isempty(range2)
        % Find our initial vL and vH
        v1 = mean(range1) + rand()*diff(range1)/4;
        v2 = mean(range1) + rand()*diff(range1)/4;
    else
        v1 = mean(range1) + rand()*diff(range1)/4;
        v2 = mean(range2) + rand()*diff(range2)/4;
    end
    
    % Iteration Time
    numIter = 0;
    
    h = power(10,-6); % TODO: Add option for h
    
    while abs(prime_constraint(v1,v2)) > tolerance/1e4 && abs(derived_constraint(v1,v2))> tolerance/1e4 && numIter < 1000       
        [dv1, dv2,singularJacobian] = Newton.step_2d(prime_constraint,derived_constraint,v1,v2,h);
        
        vL_out_of_range = (v1 + dv1 < range1(1)) || (v1 + dv1 > range1(2));
        vH_out_of_range = (v2 + dv2 < range2(1)) || (v2 + dv2 > range2(2));

        if ~singularJacobian &&  ~vL_out_of_range && ~vH_out_of_range
            v1 = v1 + dv1;
            v2 = v2 + dv2;
            
        else
            if isempty(range2)
                % Find our initial vL and vH
                v1 = mean(range1) + rand()*diff(range1)/4;
                v2 = mean(range1) + rand()*diff(range1)/4;
            else
                v1 = mean(range1) + rand()*diff(range1)/4;
                v2 = mean(range2) + rand()*diff(range2)/4;
            end
        end
        
        numIter = numIter + 1;
    end

    if numIter >= 1000
        error('Maximum Iterations Reached');
    end
end