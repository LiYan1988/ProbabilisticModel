% Example using the parfor construct to calculate the maximum eignevalue
% of a random 300x300 matrix nloops times

N=10;
a=zeros(N, 1);

%% TIME CONSUMING LOOP
tic;
parfor i=1:N
    max_eig=max(abs(eig(rand(300))));    
end
time=toc

save('pcalc_out','time','a','-ascii')

