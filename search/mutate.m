function newpop = mutate(parameters, fitness, ranges, strategy, ...
			 step_weight, crossover, range_bound)
%MUTATE   Create a new population of mutated parameters
%
%  Uses a differential evolution algorithm developed by Storn, et
%  al. to mutate a population of given parameters.
%
%  newpop = mutate(parameters, fitness, ranges, strategy, ...
%                  step_weight, crossover, range_bound)
%
%  INPUTS:
%   parameters:  A [individuals x params] matrix containing
%                parameter values from the latest generation.
%
%      fitness:  A vector of length [individuals] with the fitness
%                of each individual.
%
%       ranges:  [2 X params] matrix, where ranges(1,i) and
%                ranges(2,i) give the lower and upper bounds,
%                respectively, for parameter i.
%
%     strategy:  Mutation strategy option: (1)
%                1 --> DE/rand/1:
%                      the classical version of DE.
%                2 --> DE/local-to-best/1:
%                      a version which has been used by quite a number
%                      of scientists. Attempts a balance between robustness
%                      and fast convergence.
%                3 --> DE/best/1 with jitter:
%                      tailored for small population sizes and fast convergence.
%                      Dimensionality should not be too high.
%                4 --> DE/rand/1 with per-vector-dither:
%                      Classical DE with dither to become even more robust.
%                5 --> DE/rand/1 with per-generation-dither:
%                      Classical DE with dither to become even more robust.
%                      Choosing F_weight = 0.3 is a good start here.
%                6 --> DE/rand/1 either-or-algorithm:
%                      Alternates between differential mutation and three-point-
%                      recombination.
%
%  step_weight:  Stepsize weight to scale differentials used in
%                mutations, ranging from 0 to 2. (0.85)
%
%    crossover:  Crossover probability constant, specifying what
%                proportion of the mutated population should be
%                incorporated into the new population, ranging from
%                0 to 1.  (1)
%
%  range_bound:  Boolean indicating whether parameters in the new
%                population should be strictly bound by ranges. (true)
%
%  OUTPUTS:
%       newpop:  A [individuals x params] matrix of mutated
%                parameters to be evaluated.

% sanity checks
if ~exist('parameters', 'var')
    error('You must pass a set of parameters to mutate.')
end
if ~exist('fitness', 'var')
    error('You must pass a vector of fitness values.')
elseif size(parameters, 1) ~= size(fitness,1)
    error('parameters and fitness must have the same length.')
end
if ~exist('ranges', 'var')
    error('You must pass a matrix of ranges for parameters.')
elseif size(parameters, 2) ~= size(ranges, 2)
    error('paramters must have the same number of parameters as ranges.')
end
% defaults
if ~exist('strategy','var')
    strategy = 1;
elseif ~ismember(strategy, [1:6]) % number of strategies
    error('Invalid strategy option.')
end
if ~exist('step_weight', 'var')
    step_weight = 0.85;
elseif step_weight < 0 | step_weight > 2
    error('step_weight must be in the range of 0 to 2.')
end
if ~exist('crossover', 'var')
    crossover = 0;
elseif crossover < 0 | crossover > 1
    error('crossover must be in the range of 0 to 1.')
end
if ~exist('range_bound', 'var')
    range_bound = true;
end


% convert inputs to Storn, et al. variables
I_D = size(ranges,2); % num_params
I_NP = size(parameters,1); % pop_size
F_weight = step_weight; % stepsize F_weight
F_CR = crossover; % crossover probability constant
FVr_minbound = ranges(1,:);
FVr_maxbound = ranges(2,:);
I_bnd_constr = range_bound;
I_strategy = strategy;

% initialize previous population and fitness
FM_popold = parameters;
S_val = fitness;
[S_bestval, I_best_index] = min(fitness);
Fvr_bestmem = FM_popold(I_best_index,:);


%------DE-Minimization---------------------------------------------
%------FM_popold is the population which has to compete. It is--------
%------static through one iteration. newpop is the newly--------------
%------emerging population.----------------------------------------

FM_pm1   = zeros(I_NP,I_D);   % initialize population matrix 1
FM_pm2   = zeros(I_NP,I_D);   % initialize population matrix 2
FM_pm3   = zeros(I_NP,I_D);   % initialize population matrix 3
FM_pm4   = zeros(I_NP,I_D);   % initialize population matrix 4
FM_pm5   = zeros(I_NP,I_D);   % initialize population matrix 5
FM_bm    = zeros(I_NP,I_D);   % initialize FVr_bestmember  matrix
FM_ui    = zeros(I_NP,I_D);   % intermediate population of perturbed vectors
FM_mui   = zeros(I_NP,I_D);   % mask for intermediate population
FM_mpo   = zeros(I_NP,I_D);   % mask for old population
FVr_rot  = (0:1:I_NP-1);      % rotating index array (size I_NP)
FVr_rotd = (0:1:I_D-1);       % rotating index array (size I_D)
FVr_rt   = zeros(1,I_NP);     % another rotating index array
FVr_rtd  = zeros(1,I_D);      % rotating index array for exponential crossover
FVr_a1   = zeros(1,I_NP);     % index array
FVr_a2   = zeros(1,I_NP);     % index array
FVr_a3   = zeros(1,I_NP);     % index array
FVr_a4   = zeros(1,I_NP);     % index array
FVr_a5   = zeros(1,I_NP);     % index array
FVr_ind  = zeros(1,4);

%%%%
FVr_ind = randperm(4);               % index pointer array

FVr_a1  = randperm(I_NP);                   % shuffle locations of vectors
FVr_rt  = rem(FVr_rot+FVr_ind(1),I_NP);     % rotate indices by ind(1) positions
FVr_a2  = FVr_a1(FVr_rt+1);                 % rotate vector locations
FVr_rt  = rem(FVr_rot+FVr_ind(2),I_NP);
FVr_a3  = FVr_a2(FVr_rt+1);                
FVr_rt  = rem(FVr_rot+FVr_ind(3),I_NP);
FVr_a4  = FVr_a3(FVr_rt+1);               
FVr_rt  = rem(FVr_rot+FVr_ind(4),I_NP);
FVr_a5  = FVr_a4(FVr_rt+1);                

FM_pm1 = FM_popold(FVr_a1,:);             % shuffled population 1
FM_pm2 = FM_popold(FVr_a2,:);             % shuffled population 2
FM_pm3 = FM_popold(FVr_a3,:);             % shuffled population 3
FM_pm4 = FM_popold(FVr_a4,:);             % shuffled population 4
FM_pm5 = FM_popold(FVr_a5,:);             % shuffled population 5

FM_bm = repmat(Fvr_bestmem, [I_NP 1]);    % population filled with the best member
                                          % of the last iteration

FM_mui = rand(I_NP,I_D) < F_CR;  % all random numbers < F_CR are 1, 0 otherwise

%----Insert this if you want exponential crossover.----------------
%FM_mui = sort(FM_mui');	  % transpose, collect 1's in each column
%for k  = 1:I_NP
%  n = floor(rand*I_D);
%  if (n > 0)
%     FVr_rtd     = rem(FVr_rotd+n,I_D);
%     FM_mui(:,k) = FM_mui(FVr_rtd+1,k); %rotate column k by n
%  end
%end
%FM_mui = FM_mui';			  % transpose back
%----End: exponential crossover------------------------------------

FM_mpo = FM_mui < 0.5;    % inverse mask to FM_mui

if (I_strategy == 1)                             % DE/rand/1
    FM_ui = FM_pm3 + F_weight*(FM_pm1 - FM_pm2);   % differential variation
    FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;     % crossover
    FM_origin = FM_pm3;
elseif (I_strategy == 2)                         % DE/local-to-best/1
    FM_ui = FM_popold + F_weight*(FM_bm-FM_popold) + F_weight*(FM_pm1 - FM_pm2);
    FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;
    FM_origin = FM_popold;
elseif (I_strategy == 3)                         % DE/best/1 with jitter
    FM_ui = FM_bm + (FM_pm1 - FM_pm2).*((1-0.9999)*rand(I_NP,I_D)+F_weight);               
    FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;
    FM_origin = FM_bm;
elseif (I_strategy == 4)                         % DE/rand/1 with per-vector-dither
    f1 = ((1-F_weight)*rand(I_NP,1)+F_weight);
    for k=1:I_D
        FM_pm5(:,k)=f1;
    end
    FM_ui = FM_pm3 + (FM_pm1 - FM_pm2).*FM_pm5;    % differential variation
    FM_origin = FM_pm3;
    FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;     % crossover
elseif (I_strategy == 5)                          % DE/rand/1 with per-vector-dither
    f1 = ((1-F_weight)*rand+F_weight);
    FM_ui = FM_pm3 + (FM_pm1 - FM_pm2)*f1;         % differential variation
    FM_origin = FM_pm3;
    FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;     % crossover
else                                              % either-or-algorithm
    if (rand < 0.5);                               % Pmu = 0.5
        FM_ui = FM_pm3 + F_weight*(FM_pm1 - FM_pm2);% differential variation
    else                                           % use F-K-Rule: K = 0.5(F+1)
        FM_ui = FM_pm3 + 0.5*(F_weight+1.0)*(FM_pm1 + FM_pm2 - 2*FM_pm3);
    end
    FM_origin = FM_pm3;
    FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;     % crossover     
end

%-----Optional parent+child selection-----------------------------------------

%=====Only use this if boundary constraints are needed==================
if (I_bnd_constr == 1)
    for k=1:I_NP
        for j=1:I_D %----boundary constraints via bounce back-------
            if (FM_ui(k,j) > FVr_maxbound(j))
                FM_ui(k,j) = FVr_maxbound(j) + rand*(FM_origin(k,j) - FVr_maxbound(j));
            end
            if (FM_ui(k,j) < FVr_minbound(j))
                FM_ui(k,j) = FVr_minbound(j) + rand*(FM_origin(k,j) - FVr_minbound(j));
            end   
        end
    end
    %=====End boundary constraints==========================================
end


% pass out new perturbed population
newpop = FM_ui;
