function  [a]=pcalc1(nloop)
% Example using the parfor construct to calculate the maximum eignevalue
% of a random 300x300 matrix nloops times

N=nloop;
a=zeros(N, 1);

%% TIME CONSUMING LOOP
tic;
parfor i=1:N
    a(i)=FunctionTakesLongTime();
    
end
time=toc

save('pcalc_out','time','a','-ascii')
end

function max_eig=FunctionTakesLongTime() 
% Computation intensive calculation deoendent on matrix size
max_eig=max(abs(eig(rand(300))));
end
