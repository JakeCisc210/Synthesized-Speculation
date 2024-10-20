function moneyline_struct = moneyline_solver(my_pdf,my_cdf,tolerance)

arguments
    my_pdf = @(p) modified_beta(p,.5,.032);
    my_cdf = @(p) modified_beta_cdf(p,.5,.032);
    tolerance = 5; % In terms of Basis Points
end

    test_mesh = 0:.0001:1;
    test_values = my_pdf(test_mesh);
    range_min = test_mesh(find(test_values>0,1,'first'));
    range_max = test_mesh(find(test_values>0,1,'last'));
    
    s_u = @(pbeta,palpha) Gambling.system_utility(my_pdf,my_cdf,pbeta,palpha);
    p_c = @(pbeta,palpha) Gambling.prime_constraint(my_pdf,my_cdf,pbeta,palpha);
    d_c = @(pbeta,palpha) Gambling.derived_constraint(my_pdf,my_cdf,pbeta,palpha);
    
    % Numerical Solution
    [moneyline_struct.pbeta_numerical,moneyline_struct.palpha_numerical,moneyline_struct.profit_numerical] = Numerical.solver(s_u,p_c,[range_min range_max],tolerance/10000);
    
    % Newton Iteration Solution
    try
        [moneyline_struct.pbeta_newton,moneyline_struct.palpha_newton] = Newton.solver(p_c,d_c,tolerance/10000,[range_min range_max]);   
         moneyline_struct.profit_newton = Gambling.system_utility(my_pdf,my_cdf,moneyline_struct.pbeta_newton,moneyline_struct.palpha_newton);
    catch
        moneyline_struct.pbeta_newton = nan;
        moneyline_struct.palpha_newton = nan;
        moneyline_struct.profit_newton = nan;
    end

    % P Alpha and P Beta are allowed to differ by 20 basis points in this
    % program
    moneyline_struct.matched_answers = abs(moneyline_struct.pbeta_numerical-moneyline_struct.pbeta_newton) <= 20/10000 && ...
        abs(moneyline_struct.palpha_numerical-moneyline_struct.palpha_newton) <= 20/10000 && ...
        abs(moneyline_struct.profit_numerical-moneyline_struct.profit_newton) <= tolerance/10000;

    effective_profitability = moneyline_struct.profit_numerical/(my_cdf(moneyline_struct.pbeta_numerical)+1-my_cdf(moneyline_struct.palpha_numerical))

end