function s = rmfieldifexist(s, fields)
%RMFIELDIFEXIST  Remove fields if they exist in a structure array.
%
%  Same as RMFIELD, but does not crash if a specified field does not
%  exist in the struct.
%
%  s = rmfieldifexist(s, fields)

if ~iscellstr(fields)
    fields = {fields};
end

existing = fields(ismember(fields, fieldnames(s)));
if ~isempty(existing)
    s = rmfield(s, existing);
end
