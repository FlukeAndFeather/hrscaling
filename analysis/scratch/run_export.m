%export_raw_acc(deployid,path_400hz,rest,export_dir)
deployid = 'bb190226-53';
disp('Searching for 400 Hz acceleration...')
path_400hz = find_400hz(deployid, '/Volumes/GoogleDrive/Shared drives/CATS');
disp(['400 Hz acceleration found at: ', path_400hz])
rest = ["2019-02-27 3:33:34", "2019-02-27 5:31:28"];
export_dir = '/Users/frank/Documents/GitHub/manuscripts/hrscaling/analysis/data/raw_data/400hz';
disp('Exporting...');
export_path = export_raw_acc(deployid, path_400hz, rest, export_dir);
disp(['Exported to: ', export_path])
