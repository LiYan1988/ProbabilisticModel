function [ x2, errChk ] = solver_large1( N )
% This function is a simple test of a LU linear solver
% Since b is sum of columns, x should always be a vector
% of ones.
tic;
spmd
    dist=codistributor();
    A = rand(N, N, dist);
    b = sum(A, 2);
    
    % solve Ax=b
    x = mldivide(A,b);
    x2 = gather(x);
    % Check error
    errChk = normest(A * x - b);
end

time=toc;
x2=x2{:};
%disp('error check')
errChk=errChk{:}
save('solver_large_out','x2','errChk','-ascii');
time




