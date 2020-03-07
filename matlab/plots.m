function plots(res)

h = figure();
histogram(abs(res), 'BinWidth', 2.5);
title('\textbf{Histogram of PointPlane residuals}', 'Interpreter', 'latex', 'FontSize', 14)
ylabel('N', 'Interpreter', 'latex', 'FontSize', 14)
xlabel('distance [mm]', 'Interpreter', 'latex', 'FontSize', 14)
hold on
plot([10, 10], ylim, '--r')
legend('calibration residuals', 'altimeter resolution', 'Interpreter', 'latex', 'FontSize', 14)
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14)
end