%% This script is used for testing on one dataset to see if MK-Curve in general works on this kind of data.
% Update the scripts to point to you own data as needed.
%
% Fan Zhang (fzhang@bwh.harvard.edu)
%
%

%%

% output folder
sub_output_folder = '/Users/fan/Desktop/RepImpact/data';
if ~exist(sub_output_folder, 'dir')
    mkdir(sub_output_folder);
end

% input files
input_data_file = '/Users/fan/Desktop/RepImpact/data/Belgium_B1_02_dMRI_TOPUP_S15_MB2_FP.nii.gz';
input_bval_file = '/Users/fan/Desktop/RepImpact/data/Belgium_B1_02_dMRI_TOPUP_S15_MB2_FP.bval';
input_bvec_file = '/Users/fan/Desktop/RepImpact/data/Belgium_B1_02_dMRI_TOPUP_S15_MB2_FP.eddy_rotated_bvecs';
input_mask_file = '/Users/fan/Desktop/RepImpact/data/Belgium_B1_02_dMRI_TOPUP_S15_MB2_FP_brain_mask.nii.gz';

% extract over or equal 1000
highB_data_file = fullfile(sub_output_folder, 'data_highB.nii.gz');
highB_bval_file = fullfile(sub_output_folder, 'bval_highB.val');
highB_bvec_file = fullfile(sub_output_folder, 'bvec_highB.vec');

extract_DWI_shells(input_data_file, input_bval_file, input_bvec_file, highB_data_file, highB_bval_file, highB_bvec_file);

% downsample data
ds_data_file = fullfile(sub_output_folder, 'data_highB_ds.nii.gz');
ds_mask_file = fullfile(sub_output_folder, 'mask_ds.nii.gz');
downsample_data(highB_data_file, input_mask_file, {[],[],[40:41]}, ds_data_file, ds_mask_file);

flag_plot = 1;
run_MKCurve(ds_data_file, highB_bval_file, highB_bvec_file, ds_mask_file, sub_output_folder, flag_plot);
   
