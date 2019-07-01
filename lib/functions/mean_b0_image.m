function [data_nii, bval, bvec] = mean_b0_image(data_nii, bval, bvec, output_dir)

b0_indices = find(bval < 10);

dwi = data_nii.img;

b0_images = dwi(:, :, :, b0_indices);
mean_b0 = mean(b0_images, 4);

dwi(:, :, :, b0_indices) = [];
dwi = cat(4, mean_b0, dwi);

bval(b0_indices) = [];
bvec(b0_indices, :) = [];

bval = [0; bval];
bvec = [0, 0, 0; bvec];

data_nii.img = dwi;
data_nii.hdr.dime.dim(5) = size(dwi, 4);

if exist('output_dir', 'var')
    
   disp('File size too large. NO need to store')
   return
    
   if exist(output_dir) == 0
        mkdir(output_dir);
   end
   save_nii(data_nii, fullfile(output_dir, 'data_mean_b0.nii.gz'));
   save(fullfile(output_dir, 'data_mean_b0.bval'), 'bval', '-ascii');
   save(fullfile(output_dir, 'data_mean_b0.bvec'), 'bvec', '-ascii');
end