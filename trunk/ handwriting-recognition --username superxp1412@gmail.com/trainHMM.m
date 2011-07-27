function [ prior, transmat, obsmat ] = trainHMM( data, M, N)
%M & N represent observation numbers and number of states
% initial random guess of parameters
prior1 = normalise(rand(N,1));
transmat1=mk_stochastic(rand(N,N));
obsmat1 = mk_stochastic(rand(N,M));
  
% improve guess of parameters using EM
[LL, prior, transmat, obsmat] = dhmm_em(data, prior1, transmat1, obsmat1, 'max_iter', size(data,1));

end

