function save_nii_DWI(input_dwi, input_bval, input_bvec, nii_file, output_dwi_nii, outout_bval_txt, outout_bvec_txt)

nii_data = load_nii(nii_file);
nii_data.img = input_dwi;
nii_data.hdr.dime.dim(5) = size(nii_data.img, 4);

save_nii(nii_data, output_dwi_nii);

save(outout_bval_txt, 'input_bval', '-ascii');
save(outout_bvec_txt, 'input_bvec', '-ascii');
