
% First modify the save directories in all preprocess_cmip* files and run run_script on Glade (all in preprocessing folder).

% Give Matlab access to the generated preprocessed data and run the
% following:

forced_SST_gradient_change_script

hook_plots(models([3 10 12 13]),1:12);
hook_plots(models([2 4 14]),1:12);
hook_plots(models([1 7 9 11]),1:12);
hook_plots(models([5 6 8]),1:12);
