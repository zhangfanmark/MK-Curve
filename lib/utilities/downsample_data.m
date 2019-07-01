function downsample_data(input_data_file, input_mask_file, win_to_crop, ds_data_file, ds_mask_file)

data_nii = load_nii(input_data_file);
mask_nii = load_nii(input_mask_file);

sz = size(data_nii.img);

if isempty(win_to_crop{1})
    win_to_crop{1} = 1:sz(1);
end
if isempty(win_to_crop{2})
    win_to_crop{2} = 1:sz(2);
end
if isempty(win_to_crop{3})
    win_to_crop{3} = 1:sz(3);
end

data_nii.img = data_nii.img(win_to_crop{1}, win_to_crop{2}, win_to_crop{3}, :);
mask_nii.img = mask_nii.img(win_to_crop{1}, win_to_crop{2}, win_to_crop{3});

data_nii.hdr.dime.dim(2:5) = size(data_nii.img);
mask_nii.hdr.dime.dim(2:4) = size(mask_nii.img);

save_nii(data_nii, ds_data_file);
save_nii(mask_nii, ds_mask_file);
