function [ O, Q ,prior, transmat, obsmat ] = trainHMM( data )
%O & Q represent observation numbers and number of states
O=10;
Q=6;
% initial random guess of parameters
prior1 = normalise(rand(Q,1));
transmat1=mk_stochastic(rand(Q,Q));
obsmat1 = mk_stochastic(rand(Q,O));
  
% improve guess of parameters using EM
[LL, prior, transmat, obsmat] = dhmm_em(data, prior1, transmat1, obsmat1, 'max_iter', size(data,1));

end

