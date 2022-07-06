function PATH = export_raw_acc(deployid,path_400hz,rest,export_dir)
%export_raw_acc Export 400 Hz acceleration data to CSV
%   Load 400 Hz acceleration data, truncate to user-defined resting period,
%   concatenate timestamps, and export to CSV.

% Load data
acc400hz_mat = load(path_400hz);
atime400hz = acc400hz_mat.Atime;
adata400hz = acc400hz_mat.Adata;

% Filter to resting period
rest_dn = datenum(rest);
is_resting = atime400hz >= datenum(rest_dn(1)) & ...
    atime400hz <= datenum(rest_dn(2));
resting400hz = [atime400hz(is_resting) adata400hz(is_resting, :)];

% Export
PATH = [export_dir, '/', deployid, '_400hz.csv'];
writematrix(resting400hz, PATH)

end

