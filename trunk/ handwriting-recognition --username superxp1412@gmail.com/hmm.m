%O£¬Q represent observation numbers and number of states
O=2^9;
Q=9;
% initial guess of parameters
prior1 = normalise(rand(Q,1));
transmat1=mk_stochastic(rand(Q,Q));
obsmat1 = mk_stochastic(rand(Q,O));


%dataset for training
% data=[1,255,36,73,292,435,222,504,505;
%     73,511,36,91,493,310,255,511,447;
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%       1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        1,219,4,1,360,294,66,1,411; 
%        ]

  
% improve guess of parameters using EM
[LL, prior2, transmat2, obsmat2] = dhmm_em(data, prior1, transmat1, obsmat1, 'max_iter', size(data,1));
LL
prior2
transmat2
obsmat2

% use model to compute log likelihood
% data1=[1,219,4,1,360,294,66,1,411]
loglik = dhmm_logprob(data1, prior2, transmat2, obsmat2)
% log lik is slightly different than LL(end), since it is computed after the final M step
%loglik repesent the matching rate of data with hmm model(prior2,
%transmat2, obsmat2) the biger means match better£¬0 means the best

%path is the result of viterbi algorithm
% B = multinomial_prob(data1,obsmat2);
% path = viterbi_path(prior2, transmat2, obsmat2)




