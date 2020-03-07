%% Plot REAL DATASET
close all

%% Number of planes vs convergence of extrinsic parameters
load('MCtests.mat');

%% Translations
x = zeros(1000, 8);
for i=1:8
   x(:,i) = MCtest{i}(:,1); 
end

y = zeros(1000, 8);
for i=1:8
   y(:,i) = MCtest{i}(:,2); 
end

z = zeros(1000, 8);
for i=1:8
   z(:,i) = MCtest{i}(:,3); 
end

%% Rotations
ph = zeros(1000, 8);
for i=1:8
   ph(:,i) = MCtest{i}(:,4); 
end

th = zeros(1000, 8);
for i=1:8
   th(:,i) = MCtest{i}(:,5); 
end

ps = zeros(1000, 8);
for i=1:8
   ps(:,i) = MCtest{i}(:,6); 
end

%% Plot
h = figure();

labels = {7, 10, 20, 30, 40, 50, 60, 66};

subplot(3,2,1)
boxplot(x, 'Labels',labels);
ylabel('$x_A [mm]$','interpreter','latex')
grid minor
xlabel('N planes', 'interpreter', 'latex')
set(gca, 'FontSize', 14);
set(gca,  'FontSize', 14, 'TickLabelInterpreter', 'latex');

subplot(3,2,2)
boxplot(y, 'Labels',labels);
ylabel('$y_A [mm]$','interpreter','latex')
grid minor
xlabel('N planes', 'interpreter', 'latex')
set(gca, 'FontSize', 14);

subplot(3,2,3)
boxplot(z, 'Labels',labels);
ylabel('$z_A [mm]$','interpreter','latex')
grid minor
xlabel('N° planes', 'interpreter', 'latex')
set(gca,'FontSize', 14);

subplot(3,2,4)
boxplot(ph, 'Labels',labels);
ylabel('$Dx_A [mm]$','interpreter','latex')
grid minor
xlabel('N° planes', 'interpreter', 'latex')
set(gca, 'FontSize', 14);

subplot(3,2,5)
boxplot(th, 'Labels',labels);
ylabel('$Dy_A [mm]$','interpreter','latex')
grid minor
xlabel('N° planes', 'interpreter', 'latex')
set(gca, 'FontSize', 14);

subplot(3,2,6)
boxplot(ps, 'Labels',labels);
ylabel('$Dz_A [mm]$','interpreter','latex')
grid minor
xlabel('N° planes', 'interpreter', 'latex' )
set(gca, 'FontSize', 14);

set(gcf, 'Position', [ 568   132   712   729])

suptitle('Convergence of extrinsic calibration (no zoom)')


%% Plot (zoomed)
h = figure();

labels = {7, 10, 20, 30, 40, 50, 60, 66};

% Half length
hl = 100;
subplot(3,2,1)
boxplot(x, 'Labels',labels, 'Color', [.5 .5 .5]);
hold on
grid on
x_term = mean(x(:, end));
plot(xlim, [x_term x_term], '--', 'LineWidth', 1.5, 'Color', [0 0 0])
ylabel('$x_A$ [mm]','interpreter','latex')
xlabel('n planes', 'interpreter', 'latex')
ylim([x_term-hl, x_term+hl])
set(gca,  'FontSize', 12, 'TickLabelInterpreter', 'latex');
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', [0 .7 0], 'LineWidth', 2);

subplot(3,2,3)
boxplot(y, 'Labels',labels, 'Color', [.5 .5 .5]);
hold on
grid on
y_term = mean(y(:, end));
plot(xlim, [y_term y_term], '--', 'LineWidth', 1.5, 'Color', [0 0 0])
ylabel('$y_A$ [mm]','interpreter','latex')
xlabel('n planes', 'interpreter', 'latex')
ylim([y_term-hl, y_term+hl])
set(gca,  'FontSize', 12, 'TickLabelInterpreter', 'latex');
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', [0 .7 0], 'LineWidth', 2);

subplot(3,2,5)
boxplot(z, 'Labels',labels, 'Color', [.5 .5 .5]);
hold on
grid on
z_term = mean(z(:, end));
plot(xlim, [z_term z_term], '--', 'LineWidth', 1.5, 'Color', [0 0 0])
ylabel('$z_A$ [mm]','interpreter','latex')
xlabel('n planes', 'interpreter', 'latex')
ylim([z_term-hl z_term+hl])
set(gca,  'FontSize', 12, 'TickLabelInterpreter', 'latex');
% Half length
hl = 0.1;
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', [0 .7 0], 'LineWidth', 2);


subplot(3,2,2)
boxplot(ph, 'Labels',labels, 'Color', [.5 .5 .5]);
hold on
grid on
ph_term = mean(ph(:, end));
plot(xlim, [ph_term ph_term], '--', 'LineWidth', 1.5, 'Color', [0 0 0])
ylabel('$Dx_A$','interpreter','latex')
xlabel('n planes', 'interpreter', 'latex')
ylim([ph_term-hl, ph_term+hl])
set(gca,  'FontSize', 12, 'TickLabelInterpreter', 'latex');
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', [0 .7 0], 'LineWidth', 2);


subplot(3,2,4)
boxplot(th, 'Labels',labels, 'Color', [.5 .5 .5]);
hold on
grid on
th_term = mean(th(:, end));
plot(xlim, [th_term th_term], '--', 'LineWidth', 1.5, 'Color', [0 0 0])
ylabel('$Dy_A$','interpreter','latex')
xlabel('n planes', 'interpreter', 'latex')
ylim([th_term-hl, th_term+hl])
set(gca,  'FontSize', 12, 'TickLabelInterpreter', 'latex');
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', [0 .7 0], 'LineWidth', 2);


subplot(3,2,6)
boxplot(ps, 'Labels',labels, 'Color', [.5 .5 .5]);
hold on
grid on
ps_term = mean(ps(:, end));
plot(xlim, [ps_term ps_term], '--', 'LineWidth', 1.5, 'Color', [0 0 0])
ylabel('$Dz_A$','interpreter','latex')
xlabel('n planes', 'interpreter', 'latex')
ylim([ps_term-hl, ps_term+hl])
set(gca,  'FontSize', 12, 'TickLabelInterpreter', 'latex');
set(gcf, 'Position', [ 568   132   712   729])
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', [0 .7 0], 'LineWidth', 2);

%% Best Results Monte Carlo histograms
plot_MCviz(MCtest{end})