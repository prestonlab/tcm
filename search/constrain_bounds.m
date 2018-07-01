function fixed = constrain_bounds(origin, new, minbound, maxbound, min_frac)
%CONSTRAIN_BOUNDS   Stay within bounds while keeping the original heading.
%
%  fixed = constrain_bounds(origin, new, minbound, maxbound, min_frac)

n_dim = length(new);
low = new < minbound;
high = new > maxbound;

% vector from origin to new point
d = new - origin;

% distance to nearest boundary
dmin = minbound - origin;
dmax = maxbound - origin;
change = zeros(size(new));
change(low) = dmin(low);
change(high) = dmax(high);
%change = dmin .* low + dmax .* high;

% find the point where the vector to the new point crosses the
% boundary, and move some fraction of the vector to that point (don't
% want to go straight there, as that would lead to a reduction in the
% population diversity on the bounded dimension, but will go most of
% the way)
df = d;
df(~(low | high)) = NaN;
fixed = (min_frac + (rand * (1 - min_frac))) * ...
        (min(abs(change) ./ abs(df)) * d) + origin;

% might still be beyond bounds due to rounding error, so make sure
% are completely within bounds
low2 = fixed < minbound;
fixed(low2) = minbound(low2);
high2 = fixed > maxbound;
fixed(high2) = maxbound(high2);

