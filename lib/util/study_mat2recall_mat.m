function recall_matrix = study_mat2recall_mat(study_matrix, ...
                                              recall_serialpos, ...
                                              padding, missing)
%STUDY_MAT2RECALL_MAT   Convert study period data to recall matrix format.
%
%  recall_matrix = study_mat2recall_mat(study_matrix, recall_serialpos,
%                                       padding, missing)
%
%  INPUTS:
%      study_matrix:  [trials X list length] array containing data about
%                     the study period. Can potentially be any type of
%                     array (numeric, cell, struct), but the type
%                     of the padding and missing values used must
%                     match the type of this matrix.
%
%  recall_serialpos:  [trials X recalls] array giving the serial
%                     position of each recall. Positions with non-
%                     positive or NaN values will be set to the 
%                     missing value in the output.
%
%           padding:  Value to use for empty parts of the output matrix.
%                     Default is NaN.
%
%           missing:  Value to use for recalls with NaN or negative
%                     values. Default is NaN.
%
%  OUTPUTS:
%     recall_matrix:  [trials X recalls] array with the data in
%                     study_matrix arranged by recalls.
%
%  EXAMPLE:
%  >> study_matrix = [1 1 2 2 2 3
%                     3 3 3 1 2 1];
%  >> recall_serialpos = [6 4 5 1 0 0
%                         6 1 2 -1 5 0];
%  >> recall_matrix = study_mat2recall_mat(study_matrix,recall_serialpos,0,NaN)
%  >> recall_matrix
%      3   2   2   1   0   0
%      1   3   3 NaN   2   0
%
%  See also recall_mat2study_mat.

if nargin < 4
  missing = NaN;
  if nargin < 3
    padding = NaN;
  end
end

list_length = size(study_matrix, 2);
[n_trials, n_recalls] = size(recall_serialpos);
recall_matrix = repmat(padding, [n_trials, n_recalls]);
for i=1:n_trials
  % get the indices of recalls in the study matrix
  study_index = recall_serialpos(i,:);
  if any(study_index) > list_length
    error('serial positions cannot be larger than list length')
  end
  
  % remove NaN and non-positive values of the recalls matrix
  valid_rec = ~isnan(study_index) & study_index > 0;
  
  % get corresponding study indices
  valid_pres = study_index(valid_rec);
  
  recall_matrix(i, valid_rec) = study_matrix(i, valid_pres);

  % set parts of the recall matrix where there was a recall, but
  % the study field is not defined
  if ~isequal(padding, missing)
    invalid_rec = isnan(study_index) | study_index < 0;
    recall_matrix(i, invalid_rec) = repmat(missing, ...
                                           size(recall_matrix(i, invalid_rec)));
  end
end
