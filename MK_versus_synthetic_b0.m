function [ mk_vs_syn_b0 ] = MK_versus_synthetic_b0(dwi, grad, mask, syn_b0_range, output_dir)

orignal_b0_img = dwi(:, :, :, 1);
orignal_b0_vec = vectorize(orignal_b0_img, mask);

% mean_b0_values = mean(orignal_b0_vec);
% if mean_b0_values < 2*syn_b0_range(1) || mean_b0_values > syn_b0_range(end) / 2
%     disp('syn_b0_range is not valid')
%     return;
% end

syn_dir = fullfile(output_dir, 'MK_curves_syn_b0');

if exist(syn_dir, 'dir') == 0
    mkdir(syn_dir)
end

%% Compute MK curves versus b0
fprintf('\n')
fprintf('  * synthetic b0 : 000');
curve_file = fullfile(output_dir, 'mk_vs_syn_b0.mat');
if ~exist(curve_file, 'file')
    
    mk_vs_syn_b0 = zeros(length(syn_b0_range), length(orignal_b0_vec));
%     md_vs_syn_b0 = zeros(length(syn_b0_range), length(orignal_b0_vec));
    for s_idx = 1:length(syn_b0_range)
        syn_b0 = syn_b0_range(s_idx);        
        fprintf('\b\b\b');
        fprintf('%s%%', num2str(round(s_idx/length(syn_b0_range)*100), '%02d'))
        
        mat_file = fullfile(syn_dir, ['mk_' num2str(syn_b0) '.mat']);

        if ~exist(mat_file, 'file')
            dwi(:, :, :, 1) = syn_b0;
            [~, dt] = dki_fit(dwi, grad, mask, [0, 0, 0]);
            mk = dki_mk_only(dt, mask);
%             md = dki_md_only(dt, mask);
            save(mat_file, 'mk');
        else
            load(mat_file);
        end
        mk_vs_syn_b0(s_idx, :) = vectorize(mk, mask);
%         md_vs_syn_b0(s_idx, :) = vectorize(md, mask);
    end
    fprintf('\n')
    
    save(curve_file, 'mk_vs_syn_b0');
%     save(curve_file, 'mk_vs_syn_b0', 'md_vs_syn_b0');
else
    load(curve_file)
end
fprintf('\n')

return
%% Debug
[~, dt] = dki_fit(dwi, grad, mask, [0, 0, 0]);
orginal_MK_img = dki_mk_only(dt, mask);

abnormal_high_b0_vec = sum(mk_vs_syn_b0>3);
voxels_abnormal_high = vectorize(abnormal_high_b0_vec, mask);

mk_vs_syn_b0_tmp = mk_vs_syn_b0;

mk_vs_syn_b0_tmp(mk_vs_syn_b0_tmp < 0) = 0;

% search from the end find the first 0 value for zero_MK_b0
[~, c]=  max(flipud(mk_vs_syn_b0_tmp)==0, [], 1);
c(c == 1) = size(mk_vs_syn_b0_tmp, 1) + 1; 
pos_zero_MK = size(mk_vs_syn_b0_tmp, 1) - c + 2;

for v_idx = 1:size(mk_vs_syn_b0_tmp, 2)
    mk_vs_syn_b0_tmp(1:pos_zero_MK(v_idx)-1, v_idx) = nan;
end

% find the max value after zero_MK_b0 for max_MK_b0
[~, pos_max_MK] = max(mk_vs_syn_b0_tmp, [], 1);
[~, pos_min_MK] = min(mk_vs_syn_b0_tmp, [], 1);

zero_MK_b0_vec = syn_b0_range(pos_zero_MK);
min_MK_b0_vec = syn_b0_range(pos_min_MK); % this is not useful
max_MK_b0_vec = syn_b0_range(pos_max_MK);

zero_MK_b0_img = vectorize(zero_MK_b0_vec, mask);
max_MK_b0_img = vectorize(max_MK_b0_vec, mask);
min_MK_b0_img = vectorize(min_MK_b0_vec, mask);

mid_MK_b0_img = (max_MK_b0_img + min_MK_b0_img) / 2;

% voxels 
voxels_orginal_b0_higher_than_max_MK_b0 = (orignal_b0_img - max_MK_b0_img) >= 0;
voxels_orginal_b0_lower_than_zero_MK_b0 = (orignal_b0_img - zero_MK_b0_img) <= 0;

voxels_orginal_b0_closer_to_zero_MK_b0 = (orignal_b0_img - mid_MK_b0_img) <= 0 & (orignal_b0_img - zero_MK_b0_img) > 0;
voxels_orginal_b0_closer_to_max_MK_b0 = (orignal_b0_img - mid_MK_b0_img) > 0 & (orignal_b0_img - max_MK_b0_img) < 0;

voxels_orginal_b0_closer_to_zero_MK_b0_than_to_max_MK_b0 = voxels_orginal_b0_closer_to_zero_MK_b0 | voxels_orginal_b0_lower_than_zero_MK_b0;

flag_plot = 1;

if flag_plot
    
    if syn_b0_range(end) == 1500  
        slice = 40;    
        c_range = [0, 800];
    else   
        slice = 70;    
        c_range = [0, 10000];
    end
    
    max_MK_b0_slice = max_MK_b0_img(:, :, slice);
    zero_MK_b0_slice = zero_MK_b0_img(:, :, slice);
    orignal_b0_slice = orignal_b0_img(:, :, slice);
   
    figure; 
    subplot(2,3,1)
    imshow(orignal_b0_slice, c_range);
    title('actual-b0 map')
    colorbar
    subplot(2,3,2)
    imshow(max_MK_b0_slice, c_range);
    title('max-MK-b0 map')
    colorbar
    subplot(2,3,3)
    imshow(zero_MK_b0_slice, c_range);
    title('zero-MK-b0 map')
    colorbar
    subplot(2,3,4)
    imshow(max_MK_b0_slice - zero_MK_b0_slice, []);
    title('max-MK-b0 minus min-MK-b0')
    colorbar
    subplot(2,3,5)
    imshow(orignal_b0_slice - max_MK_b0_slice, []);
    title('actual-b0 minus max-MK-b0')
    colorbar
    subplot(2,3,6)
    imshow(orignal_b0_slice - zero_MK_b0_slice, []);
    title('actual-b0 minus min-MK-b0')
    colorbar
    
    orginal_MK_slice = orginal_MK_img(:, :, slice);

    voxels_orginal_b0_higher_than_max_MK_b0_slice = voxels_orginal_b0_higher_than_max_MK_b0(:, :, slice);
    voxels_orginal_b0_lower_than_zero_MK_b0_slice = voxels_orginal_b0_lower_than_zero_MK_b0(:, :, slice); 
    voxels_orginal_b0_closer_to_zero_MK_b0_slice = voxels_orginal_b0_closer_to_zero_MK_b0(:, :, slice);
    voxels_orginal_b0_closer_to_max_MK_b0_slice = voxels_orginal_b0_closer_to_max_MK_b0(:, :, slice);
    
    figure;
    subplot(2,2,1)
    imshow(orginal_MK_slice, [0, 1]);
    colorbar
    hold on;
    spy(voxels_orginal_b0_higher_than_max_MK_b0_slice, 'g', 10);
    subplot(2,2,2)
    imshow(orginal_MK_slice, [0, 1]);
    colorbar
    hold on;
    spy(voxels_orginal_b0_closer_to_max_MK_b0_slice, 'g', 10);
    subplot(2,2,3)
    imshow(orginal_MK_slice, [0, 1]);
    colorbar
    hold on;
    spy(voxels_orginal_b0_lower_than_zero_MK_b0_slice, 'r', 10);
    subplot(2,2,4)
    imshow(orginal_MK_slice, [0, 1]);
    colorbar
    hold on;
    spy(voxels_orginal_b0_closer_to_zero_MK_b0_slice, 'r', 10);
    
    voxels_orginal_b0_closer_to_zero_MK_b0_than_to_max_MK_b0_slice = voxels_orginal_b0_closer_to_zero_MK_b0_than_to_max_MK_b0(:, :, slice);
    
    figure;
    imshow(orginal_MK_slice, [0, 1]);
    colorbar
    hold on;
    spy(voxels_orginal_b0_closer_to_zero_MK_b0_than_to_max_MK_b0_slice, 'r', 10);
    
    
    voxels_abnormal_high_slice = voxels_abnormal_high(:, :, slice)
    figure;
    imshow(orginal_MK_slice);
    colorbar
    hold on;
    spy(voxels_abnormal_high_slice == 1, 'g', 10);
    
end
