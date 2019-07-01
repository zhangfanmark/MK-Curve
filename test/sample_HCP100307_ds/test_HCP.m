nii_file = 'test/sample_HCP100307_ds/100307_dwi_ds.nii.gz';
bval_file = 'test/sample_HCP100307_ds/100307_bvals';
bvec_file = 'test/sample_HCP100307_ds/100307_bvecs';
mask_file = 'test/sample_HCP100307_ds/100307_mask_ds.nii.gz';
sub_output_folder = 'test/sample_HCP100307_ds/';

flag_plot = 1;

run_MKCurve(nii_file, bval_file, bvec_file, mask_file, sub_output_folder, flag_plot);