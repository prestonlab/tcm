function prep_data_cdcatfr2()

data_file = '~/work/cdcatfr2/stat_data_cdcatfr2.mat';
wiki_w2v_file = '~/work/cfr/models/mat_wiki_w2v.mat';

proj_dir = fileparts(mfilename('fullpath'));
data_dir = fullfile(proj_dir, 'data');

% data struct for cdcatfr2, with 10 participants
load(data_file);

save(fullfile(data_dir, 'cdcatfr2_data.mat'), 'data');
data_full = data;

% clean the recall matrices (remove repeats and intrusions)
[data.recalls, data.rec_itemnos, data.rec_items] = ...
    clean_recalls(data_full.recalls, data_full.rec_itemnos, ...
                  data_full.rec_items);
[data.recalls, data.rec_itemnos, data.rec_items] = ...
    trim_padding(data.recalls, data.rec_itemnos, data.rec_items);
save(fullfile(data_dir, 'cdcatfr2_data_clean.mat'), 'data')
