function downsample_mask(in_mask_file, out_mask_file)

nii_data = load_untouch_nii(in_mask_file);

mask = zeros(size(nii_data.img));
mask(:, :, round(size(mask, 3)/2)) = 1;

nii_data.img(mask==0) = 0;

save_untouch_nii(nii_data, out_mask_file);
