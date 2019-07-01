addpath(genpath('lib'));

% Input HCP sample data (sub ID: 100307)
nii_file = '~/Desktop/100307/T1w/Diffusion/data.nii.gz';
bval_file = '~/Desktop/100307/T1w/Diffusion/bvals';
bvec_file = '~/Desktop/100307/T1w/Diffusion/bvecs';
mask_file = '~/Desktop/100307/T1w/Diffusion/nodif_brain_mask.nii.gz';
output_dir = './test/sample_HCP100307_ds';

data_nii = load_nii(nii_file);
bval = load(bval_file);
bvec = load(bvec_file);
mask_nii = load_nii(mask_file);

% Downsample data
slices_to_keep = 69:71; % Keep 3 slices in the middle of the brain
win_to_crop = {[18:128], [24:156]};
data_nii.img = data_nii.img(win_to_crop{1}, win_to_crop{2}, slices_to_keep, :);
mask_nii.img = mask_nii.img(win_to_crop{1}, win_to_crop{2}, slices_to_keep);

data_nii.hdr.dime.dim(2:5) = size(data_nii.img);
mask_nii.hdr.dime.dim(2:4) = size(mask_nii.img);

output_data_nii = fullfile(output_dir, '100307_dwi_ds.nii.gz');
output_bvec = fullfile(output_dir, '100307_bvecs');
output_bval = fullfile(output_dir, '100307_bvals');
output_mask_nii = fullfile(output_dir, '100307_mask_ds.nii.gz');

save_nii(data_nii, output_data_nii);
copyfile(bval_file, output_bval);
copyfile(bvec_file, output_bvec);
save_nii(mask_nii, output_mask_nii);
