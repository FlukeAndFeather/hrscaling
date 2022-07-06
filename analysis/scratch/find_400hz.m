function PATH = find_400hz(deployid,cats_path)
%find_400hz Find path to 400 Hz acceleration data
%   Recursively searches the tag_data_raw folder to find the raw
%   acceleration data.

% Find all mat files in the deployment raw data directory
raw_dir = dir(fullfile(cats_path,'tag_data_raw','**',deployid,'*.mat'));
% The shortest filename should correspond to the 400 Hz .mat file
[~, shortest] = min(cellfun(@strlength, {raw_dir.name}));
PATH = [raw_dir(shortest).folder,'/',raw_dir(shortest).name];

end
