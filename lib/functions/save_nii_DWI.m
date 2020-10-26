function save_nii_DWI(mat_dwi_file, nii_dwi_file, output_nii_dwi, outout_txt_bval, outout_txt_bvec)

mat_dwi = load(mat_dwi_file);

nii_data = load_untouch_nii(nii_dwi_file);
nii_data.img = mat_dwi.dwi_fixed;
nii_data.hdr.dime.dim(5) = size(nii_data.img, 4);

bval = mat_dwi.grad(:, end);
bvec = mat_dwi.grad(:, 1:3);

save_untouch_nii(nii_data, output_nii_dwi);

save(outout_txt_bval, 'bval', '-ascii');
save(outout_txt_bvec, 'bvec', '-ascii');
