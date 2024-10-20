function profit = peer_to_peer_theoretical_system_utility(inverse_cdf,system_micro_utility,x)
    arguments
        inverse_cdf = @(d) modified_gaussian_inverse_cdf(d,.5,.1);
        system_micro_utility =  @(vLow,vHigh,x) x*(vHigh-vLow) / ( max(vLow+vHigh,2-vLow-vHigh) + x*max(vHigh,1-vLow) );
        x = 2;
    end
        
    my_integrand = @(d) system_micro_utility(inverse_cdf(d),inverse_cdf(1-d),x);
    profit = integral(my_integrand,0,1/2,'ArrayValued',true);

end
   
