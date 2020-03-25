function convert_MAT_to_NII(mat, nii_file, output_file)

data_nii = load_nii(nii_file);

data_nii.img = single(mat);

save_nii(data_nii, output_file);

