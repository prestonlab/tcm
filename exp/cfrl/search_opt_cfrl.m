function opt = search_opt_cfrl(search_type, varargin)
%SEARCH_OPT_CFRL   Set options for running a parameter search.
%
%  opt = search_opt_cfrl(search_type, ...)

def.generations = 100000;
def.tol = 0.0001;
%def.tol = 0.01;
def.popsize = 100;
def.stall_gen_limit = 50;
%def.stall_gen_limit = 10;
def.init_ranges = [];
[base, other] = propval(varargin, def);
other = propval(other, struct, 'strict', false);

switch search_type
  case 'de'
    def = base;
    def.strategy = 3;
    def.mutate_func = @mutate_edge;
    def.step_weight = 0.85;
    def.crossover = 0.9;
    def.plot_func = [];
    opt = propval(other, def, 'strict', false);
  case 'de_fast'
    def = base;
    def.strategy = 3;
    def.mutate_func = @mutate_edge;
    def.step_weight = 0.85;
    def.crossover = 0.9;
    def.plot_func = [];
    def.popsize = 50;
    def.tol = 0.01;
    def.stall_gen_limit = 10;
    opt = propval(other, def, 'strict', false);
  otherwise
    error('Unknown search type: %s', search_type)
end
