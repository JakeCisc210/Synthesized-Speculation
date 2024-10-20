% SEXY PLOT

% For Testing
% plot([0 1],[0 1])
% hold on
% plot([0 1],[.25 .75])
% xlabel('X')
% ylabel('Y')
% title('title')

myAxes = gca();

% X Axes
myAxes.XAxis.LineWidth = 2;
myAxes.XAxis.FontSize = 14;

% Y Axes
myAxes.YAxis.LineWidth = 2;
myAxes.YAxis.FontSize = 14;

% Title
myAxes.Title.FontSize = 16;

% Grid
grid on

% Lines
axes_lines = findobj('Type','line');
for index = 1:length(axes_lines)
    axes_lines(index).LineWidth = 2;
end


