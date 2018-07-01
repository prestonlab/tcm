function param_vec = param_vec_tcm(param)
%PARAM_VEC_TCM   Write parameters for use with compiled TCM.
%
%  param_vec_tcm(param, param_file)
%
%  INPUTS:
%       param:  structure specifying parameter values. Must include:
%                B_enc, B_rec, C, G, X1, X2, P1, P2, T, S, D, and
%                stop_rule ('op' or 'ratio').
%               Each field (except stop_rule) may be a scalar or a
%               vector, if that parameter varies by group or subject.
%               Each vector must have the same length.
%
%  param_file:  path to file to write parameters in.

% must match the order the c++ code is expecting
names = {'B_enc' 'B_rec' ...
         'Afc' 'Dfc' 'Sfc' 'Lfc' ...
         'Acf' 'Dcf' 'Scf' 'Lcf' ...
         'P1' 'P2' 'T' 'X1' 'X2' ...
         'stop_rule' 'B_s' 'B_ri' 'I' 'init_item'};

switch param.stop_rule
  case 'op'
    param.stop_rule = 1;
  case 'ratio'
    param.stop_rule = 2;
  otherwise
    error('Stop rule not supported: %s.', param.stop_rule);
end

param_vec = NaN(1, length(names));
for i = 1:length(names)
    param_vec(i) = param.(names{i});
end
