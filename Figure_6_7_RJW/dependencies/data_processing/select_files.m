function [files] = select_files(files,included_string)

is = [];

for i = 1:length(files)
    if contains(files{i},included_string)
        is = [is, i];
    end
end

files = files(is);