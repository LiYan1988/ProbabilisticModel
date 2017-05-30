clc;
clear;
close all;

%% Rename files from gain_over_bathula_mindist_16_2
% files = dir();
% for id = 1:length(files)
%     % Get the file name (minus the extension)
%     [~, f, ext] = fileparts(files(id).name);
%       if ~files(id).isdir && strcmp(ext, '.mat')
%           tmp = strsplit(f, '_');
%           tmp{end} = num2str(str2double(tmp{end})+35);
%           movefile(files(id).name, strcat(strjoin(tmp, '_'), '.mat'));
%       end
% end

%% Extract benchmark data
NMonteCarlo = 50;
NDemands = 5550;
NArray = 70;
bp = [0.005, 0.01, 0.02, 0.04]; % values of interested BP 

files = dir();
BP_bm = zeros(NDemands, NMonteCarlo, NArray);
BP_bm_mean = zeros(NDemands, NArray);
BP_bm_std = zeros(NDemands, NArray);
ND_bm = zeros(length(bp), NMonteCarlo, NArray); % #established demands@bp
for id = 1:length(files)
    name = files(id).name;
    [~, nameCell, ext] = fileparts(name);
    nameCell = strsplit(nameCell, '_');
    if ~files(id).isdir && strcmp(ext, '.mat') && strcmp(nameCell{2}, 'benchmark')
        n = str2double(nameCell{end});
        tmp = load(name);
        fprintf('Processing benchmark %d\n', n)
        BP_bm(:, :, n) = tmp.blockHistory;
        clear tmp
        BP_bm_mean(:, n) = mean(BP_bm(:, :, n), 2);
        BP_bm_std(:, n) = std(BP_bm(:, :, n), [], 2);
        for b = 1:length(bp)
            tmp_bp = bp(b);
            for n = 1:NArray
                for m = 1:NMonteCarlo
                    ND_bm(b, m, n) = find(BP_bm(:, m, n)<tmp_bp, 1, ...
                        'last');
                end
            end
        end
    end
end
% Plot relative variance for all traffic matrices
rv = BP_bm_std./BP_bm_mean;
semilogy(rv)

% Calculate #established demands
ND_bm_reshape = reshape(ND_bm, length(bp), []);
ND_bm_mean = mean(ND_bm_reshape, 2);
ND_bm_std = std(ND_bm_reshape, [], 2);
% Confidence interval @90% confidence level
ND_bm_ci = ND_bm_std*1.645/sqrt(NMonteCarlo*NArray);
