function c = padcat(dim, x, varargin)
%PADCAT   Concatenate arrays, adding padding as necessary.
%
%  Similar to concat, but more general, has NaN as the
%  default padding, and has a more descriptive name.
%
%  c = padcat(dim, x, a1, a2, a3, ... aN)
%
%  INPUTS:
%      dim:  dimension along which to concatenate.
%
%        x:  value to use for padding. If empty, defaults to NaN.
%
%        a:  arrays to concatenate. Must be numeric.
%
%  OUTPUTS:
%        c:  array resulting from padded concatenation of all a's.
%
%  EXAMPLE:
%   padcat(1, NaN, [1 2], [1 2 3 4], 1)
%
%     1     2   NaN   NaN
%     1     2     3     4
%     1   NaN   NaN   NaN

% grab inputs
a1 = varargin{1};
a2 = varargin{2};

if isempty(a1) && isempty(a2)
  c = [];
  return
elseif isempty(a1)
  c = a2;
  return
elseif isempty(a2)
  c = a1;
  return
end

if isempty(x)
  if isnumeric(a1)
    x = NaN;
  elseif iscellstr(a1)
    x = {''};
  elseif iscell(a1)
    x = {[]};
  else
    error('Unable to set padding type based on input type')
  end
end

% get the difference along dimensions other than the cat dim
max_dim = max([ndims(a1) ndims(a2)]);
s1 = ones(1, max_dim);
s2 = ones(1, max_dim);
s1(1:ndims(a1)) = size(a1);
s2(1:ndims(a2)) = size(a2);
size_diff = s2 - s1;
size_diff(dim) = 0;

% add padding to all necessary dimensions
for i = 1:length(size_diff)
  if size_diff(i) > 0
    % a1 is smaller on this dimension
    repdim = size(a1);
    repdim(i) = size_diff(i);
    a1 = cat(i, a1, repmat(x, repdim));
    
  elseif size_diff(i) < 0
    % a2 is smaller
    repdim = size(a2);
    repdim(i) = abs(size_diff(i));
    a2 = cat(i, a2, repmat(x, repdim));
  end
end

% should be same size on all other dimensions; concatenate
c = cat(dim, a1, a2);

if length(varargin) > 2
  c = padcat(dim, x, c, varargin{3:end});
end
