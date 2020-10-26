function [dwi, grad, mask] = prepare_data(nii_file, bval_file, bvec_file, mask_file, output_dir)

data_nii = load_untouch_nii(nii_file);
bval = load(bval_file);
bvec = load(bvec_file);
mask_nii = load_untouch_nii(mask_file);

if size(bval, 1) == 1
    bval = bval';
end

if size(bvec, 1) == 3
    bvec = bvec';
end

b0_indices = find(bval < 10);

% we use mean b0 only
if length(b0_indices) > 1
    output_mean_b0_dir = fullfile(output_dir, 'data_mean_b0');
    [data_nii, bval, bvec] = mean_b0_image(data_nii, bval, bvec, output_mean_b0_dir);
end

dwi = data_nii.img;
grad = [bvec bval];
mask = mask_nii.img == 1;

dwi = check_non_positive_signal(dwi, mask);
dwi = double(dwi);
