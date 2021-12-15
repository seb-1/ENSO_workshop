function [field] = concatenate_fields(files,var,regular)

ref_field = squeeze(get_avg_field_3d(files{1},var));

s = size(ref_field);
n = length(files);

if nargin < 3
    regular = 0;
end

if regular
    if length(s) == 5
        field = zeros([s(1) s(2) s(3) s(4) n*s(5)]);
        for i = 1:n
            field(:,:,:,:,(i-1)*s(5)+1:i*s(5)) = squeeze(get_avg_field_3d(files{i},var));
        end
    elseif length(s) == 4
        field = zeros([s(1) s(2) s(3) n*s(4)]);
        for i = 1:n
            field(:,:,:,(i-1)*s(4)+1:i*s(4)) = squeeze(get_avg_field_3d(files{i},var));
        end
    elseif length(s) == 2
        field = zeros([s(1) n*s(2)]);
        for i = 1:n
            field(:,(i-1)*s(2)+1:i*s(2)) = squeeze(get_avg_field_3d(files{i},var));
        end
    else
        field = zeros([s(1) s(2) n*s(3)]);
        for i = 1:n
            field(:,:,(i-1)*s(3)+1:i*s(3)) = squeeze(get_avg_field_3d(files{i},var));
        end
    end
else
    field = ref_field;
    if length(s) == 5
        k = s(5);
        for i = 2:n
            tmp = squeeze(get_avg_field_3d(files{i},var));
            T = size(tmp,5);
            field(:,:,:,:,k+1:k+T) = tmp;
            k = k+T;
        end
    elseif length(s) == 4
        k = s(4);
        for i = 2:n
            tmp = squeeze(get_avg_field_3d(files{i},var));
            T = size(tmp,4);
            field(:,:,:,k+1:k+T) = tmp;
            k = k+T;
        end
    elseif length(s) == 2
        k = s(2);
        for i = 2:n
            tmp = squeeze(get_avg_field_3d(files{i},var));
            T = size(tmp,2);
            field(:,k+1:k+T) = tmp;
            k = k+T;
        end
    else
        k = s(3);
        for i = 2:n
            tmp = squeeze(get_avg_field_3d(files{i},var));
            T = size(tmp,3);
            field(:,:,k+1:k+T) = tmp;
            k = k+T;
        end
    end
end