function stats = load_decode_cfrl(experiment, fit, res_name)
%LOAD_DECODE_CFRL   Load decoding analysis from individual subjects.
%
%  stats = load_decode_cfrl(experiment, fit, res_name)

info = get_fit_info_cfrl('local_cat_wikiw2v', 'cfr');
[par, base, ext] = fileparts(info.res_file);

s = load(info.res_file);
n_subj = length(s.stats);

for i = 1:n_subj
    outfile = fullfile(par, sprintf('%s_%s_%d.mat', base, res_name, i));
    if i == 1
        stats = load(outfile);
        f = fieldnames(stats);
    else
        s = load(outfile);
        for j = 1:length(f)
            if ~isfield(s, f{j})
                fprintf('problem with subject index %d.\n', i);
                continue
            end
            sf = s.(f{j});
            stf = stats.(f{j});
            
            if iscell(sf) || isnumeric(sf)
                stats.(f{j}) = [stf sf];
            else
                stats.(f{j}).pres = [stf.pres sf.pres];
                stats.(f{j}).rec = [stf.rec sf.rec];
            end
        end
    end
end
