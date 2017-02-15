clc;
clear;
close all;

% copy files for cluster
id = 1;
for Nuser = 5:5:50
    for distance = 5:100
        fileName = sprintf('jobArray%d.m', id);
        id = id+1;
        %         copyfile('test_cluster.m', fileName);
        fid = fopen('test_cluster.m','r');
        i = 1;
        tline = fgetl(fid);
        A{i} = tline;
        while ischar(tline)
            i = i+1;
            tline = fgetl(fid);
            A{i} = tline;
        end
        fclose(fid);
        % Change cell A
        A{39} = sprintf('for Nuser = %d',Nuser);
        A{43} = sprintf('    distance = %d;', distance);
        % Write cell A into txt
        fid = fopen(fileName, 'w');
        for i = 1:numel(A)
            if A{i+1} == -1
                fprintf(fid,'%s', A{i});
                break
            else
                fprintf(fid,'%s\n', A{i});
            end
        end
        fclose(fid);
    end
end