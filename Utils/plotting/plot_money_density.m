function plot_money_density(subjective_probs,bet_amounts,money_density_function)
    arguments
        subjective_probs = modified_gaussian_inverse_cdf(rand(1,1e3),1/2,1/10);
        bet_amounts = round(100*rand(1,1e3),2);
        money_density_function = @(p) modified_gaussian(p,1/2,1/10);
    end

    % Money Density Bins Probabilities with dx Spacing
    figure
    hold on
    dx = .001;
    bin_centers = 0:dx:1;
    money_density_sum = 0;
    for index = 1:length(bin_centers)
        included_probs = abs(subjective_probs-bin_centers(index)) <= dx/2;
        money_density = sum(bet_amounts(included_probs));
        if index == 1
            patch1 = patch(bin_centers(index)+dx/2*[1 1 -1 -1],[0 money_density money_density 0],[.4 .4 .4],'LineStyle','none');
        else
            patch(bin_centers(index)+dx/2*[1 1 -1 -1],[0 money_density money_density 0],[.4 .4 .4],'LineStyle','none')
        end
        money_density_sum = money_density_sum + money_density;
    end
    plot1 = plot(bin_centers,sum(bet_amounts)*money_density_function(bin_centers)*1e-3,'Color',[0 0 0],'DisplayName','Predicted');
    legend([patch1 plot1],{'Actual' 'Predicted'})
    hold off
    xlabel('Subjective Probability')
    ylabel('Money Density')
    title('Money Density Distribution')
    sexy_plot
end