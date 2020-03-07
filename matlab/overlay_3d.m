function [] = overlay_3d(handle, extr, scans)

N = length(scans);
OA = repmat(extr(1:3)', [N, 1]);
PA = OA + scans .* repmat(extr(4:6)', [N, 1]);

figure(handle)
for i=1:N
    hold on
    plot3([OA(i,1), PA(i,1)], [OA(i,3), PA(i,3)], [OA(i,2), PA(i,2)], 'r') 
end

hold on
h_PA = scatter3(PA(:,1), PA(:,3), PA(:,2), 'filled');

h_orig = scatter3(extr(1), extr(3), extr(2), 72, 'm', 'filled');

xlabel('x [mm]', 'interpreter', 'latex', 'FontSize', 14)
ylabel('z [mm]', 'interpreter', 'latex', 'FontSize', 14)
zlabel('y [mm]', 'interpreter', 'latex', 'FontSize', 14)

set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 14)

title('', 'interpreter', 'latex', 'FontSize', 14)
set(gcf, 'Position', [0 0 1178 277], 'renderer', 'painters');
view([90 0])
planes = findobj(gcf,'Type','patch');
for i=1:length(planes)
   planes(i).FaceAlpha = 0.3; 
end
box on
legend([h_orig, planes(i), h_PA], '$O_i$', '$\pi_i$', '$P_A$', 'interpreter', 'latex', 'Location', 'northeastoutside', 'NumColumns', 3)

end