function value = system_utility(~,gamma,pbeta,palpha)
% Takes density, gamma, vLow, vHigh
    value = (1-pbeta/palpha).*(gamma(1e6)-gamma(palpha));
end
