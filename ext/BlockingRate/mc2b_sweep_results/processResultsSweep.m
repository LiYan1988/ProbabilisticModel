clc;
close all;
clear;

% oldFolder = cd('Results\');
% lists = dir();
% mean #of established connections
% bpBenchmark = zeros(5550, 40);
% bpProposed1 = zeros(5550, 40); % RS based
% bpProposed2 = zeros(5550, 40); % RC based
% 90% confidence interval of #established connections
% bpBenchmark_ci = zeros(5550, 40);
% bpProposed1_ci = zeros(5550, 40);
% bpProposed2_ci = zeros(5550, 40);
% for i=1:length(lists)
%     if lists(i).isdir == 1
%         continue
%     end
%     fprintf('Loading %s\n', lists(i).name);
%     x = load(lists(i).name);
%     blockHistory = x.blockHistory;
%     a = strsplit(lists(i).name, '_');
%     b = str2double(a{3});
%     a = a{2};
%     if strcmp(a, 'benchmark2')
%         bpBenchmark(:, b) = mean(blockHistory, 2);
%         bpBenchmark_ci(:, b) = std(blockHistory, [], 2)*1.645/sqrt(40);
%     elseif strcmp(a, 'proposed1')
%         bpProposed1(:, b) = mean(blockHistory, 2);
%         bpProposed1_ci(:, b) = std(blockHistory, [], 2)*1.645/sqrt(40);
%     elseif strcmp(a, 'proposed2')
%         bpProposed2(:, b) = mean(blockHistory, 2);
%         bpProposed2_ci(:, b) = std(blockHistory, [], 2)*1.645/sqrt(40);
%     end
% end
%
% cd(oldFolder)
% save('results.mat')

%%
clc;
close all;
clear;
load('results.mat')

%%
% 4 blocking probabilities, 40 #RSs
% mean #established connections
ndbp_benchmark2 = zeros(4, 40);
ndbp_proposed1 = zeros(4, 40);
ndbp_proposed2 = zeros(4, 40);
% lower bound of #established connections, with 90% confidence interval
ndbp_benchmark2_1 = zeros(4, 40);
ndbp_proposed1_1 = zeros(4, 40);
ndbp_proposed2_1 = zeros(4, 40);
% upper bound of #established connections, with 90% confidence interval
ndbp_benchmark2_2 = zeros(4, 40);
ndbp_proposed1_2 = zeros(4, 40);
ndbp_proposed2_2 = zeros(4, 40);
bp = [0.005, 0.01, 0.02, 0.04];
for s=1:4
    for t=1:40
        ndbp_benchmark2(s, t) = find(bpBenchmark(:, t)<bp(s), 1, 'last');
        ndbp_proposed1(s, t) = find(bpProposed1(:, t)<bp(s), 1, 'last');
        ndbp_proposed2(s, t) = find(bpProposed2(:, t)<bp(s), 1, 'last');
        ndbp_benchmark2_1(s, t) = find(bpBenchmark(:, t)-bpBenchmark_ci(:, t)<bp(s), 1, 'last');
        ndbp_proposed1_1(s, t) = find(bpProposed1(:, t)-bpProposed1_ci(:, t)<bp(s), 1, 'last');
        ndbp_proposed2_1(s, t) = find(bpProposed2(:, t)-bpProposed2_ci(:, t)<bp(s), 1, 'last');
        ndbp_benchmark2_2(s, t) = find(bpBenchmark(:, t)+bpBenchmark_ci(:, t)<bp(s), 1, 'last');
        ndbp_proposed1_2(s, t) = find(bpProposed1(:, t)+bpProposed1_ci(:, t)<bp(s), 1, 'last');
        ndbp_proposed2_2(s, t) = find(bpProposed2(:, t)+bpProposed2_ci(:, t)<bp(s), 1, 'last');
    end
end

%%
% figure; hold on;
% DefaultColorMap = get(gca, 'colororder');
% for n=1:4
%     b = [ndbp_benchmark2(n, :)', ndbp_proposed1(n, :)', ndbp_proposed2(n, :)'];
%     p = plot(b./repmat(b(:, 1), 1, 3)-1, 'linewidth', 1.2);
%     set(p(1), 'linestyle', '-', 'color', DefaultColorMap(1, :));
%     set(p(2), 'linestyle', '-.', 'color', DefaultColorMap(2, :));
%     set(p(3), 'linestyle', '--', 'color', DefaultColorMap(3, :));
% end
% h = legend({'Benchmark', 'RS based', 'RC based'});
% h.Interpreter = 'latex';

%% Calculate gains of proposed methods, plot average over all BPs
% DefaultColorMap = get(gca, 'colororder');
% M = 4;
% % average gain
% c = zeros(40, 3, 4);
% % lower bound of gain, 90% confidence interval
% c1 = zeros(40, 3, 4);
% % upper bound of gain, 90% confidence interval
% c2 = zeros(40, 3, 4);
% for n=M:4
%     b = [ndbp_benchmark2(n, :)', ndbp_proposed1(n, :)', ndbp_proposed2(n, :)'];
%     c(:, :, n) = b./repmat(b(:, 1), 1, 3)-1;
%     b = [ndbp_benchmark2_1(n, :)', ndbp_proposed1_1(n, :)', ndbp_proposed2_1(n, :)'];
%     c1(:, :, n) = b./repmat(b(:, 1), 1, 3)-1;
%     b = [ndbp_benchmark2_2(n, :)', ndbp_proposed1_2(n, :)', ndbp_proposed2_2(n, :)'];
%     c2(:, :, n) = b./repmat(b(:, 1), 1, 3)-1;
% end
%
% % Plot the average gain
% c = sum(c, 3)/(4-M+1);
% c1 = sum(c1, 3)/(4-M+1);
% c2 = sum(c2, 3)/(4-M+1);
% for n=1:3
%     c(:, n) = smooth(c(:, n), 1);
%     c1(:, n) = smooth(c1(:, n), 1);
%     c2(:, n) = smooth(c2(:, n), 1);
% end
% figure;
% hold on;
% plot(c1, 'linewidth', 1.2);
% plot(c2, 'linewidth', 1.2);
% p = plot(c, 'linewidth', 1.2);
% set(p(1), 'linestyle', '-', 'color', DefaultColorMap(1, :));
% set(p(2), 'linestyle', '-.', 'color', DefaultColorMap(2, :));
% set(p(3), 'linestyle', '--', 'color', DefaultColorMap(3, :));
% h = legend({'Benchmark', 'RS based', 'RC based'});
% h.Interpreter = 'latex';

%% Calculate gains and plot separately
DefaultColorMap = get(gca, 'colororder');
close all
M = 1;
% average gain
c = zeros(40, 3, 4);
% lower bound of gain, 90% confidence interval
c1 = zeros(40, 3, 4);
% upper bound of gain, 90% confidence interval
c2 = zeros(40, 3, 4);
for n=M:4
    b = [ndbp_benchmark2(n, :)', ndbp_proposed1(n, :)', ndbp_proposed2(n, :)'];
    c(:, :, n) = b./repmat(b(:, 1), 1, 3)-1;
    b = [ndbp_benchmark2_1(n, :)', ndbp_proposed1_1(n, :)', ndbp_proposed2_1(n, :)'];
    c1(:, :, n) = b./repmat(b(:, 1), 1, 3)-1;
    b = [ndbp_benchmark2_2(n, :)', ndbp_proposed1_2(n, :)', ndbp_proposed2_2(n, :)'];
    c2(:, :, n) = b./repmat(b(:, 1), 1, 3)-1;
end

% 
figure;
hold on;
for n=M:4
    plot(c(:, 1, n), 'color', DefaultColorMap(1, :), 'linestyle', '-')
    plot(c1(:, 2, n), 'color', DefaultColorMap(n+1, :), 'linestyle', '--')
    plot(c2(:, 3, n), 'color', DefaultColorMap(n+1, :), 'linestyle', '-.')
end

%% % figure;
% m = 20;
% a = [bpBenchmark(:, m), bpProposed1(:, m), bpProposed2(:, m)];
% semilogy1 = semilogy(a);
% set(semilogy1(1),'DisplayName','Benchmark', 'linestyle', '-');
% set(semilogy1(2),'DisplayName','RS based', 'linestyle', '-.');
% set(semilogy1(3),'DisplayName','RC based', 'linestyle', '--');
% h = legend('show', 'location', 'east');
% h.Interpreter = 'latex';

