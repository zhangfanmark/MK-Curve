function [zero_MK_b0_image, max_MK_b0_image, voxels_abnormal_mask] = abnormal_voxel_detection(mk_vs_syn_b0, dwi, mask, syn_b0_range, th, output_dir)

%% Decide MD = 0; This not useful.
if 0
    if isempty(md_vs_syn_b0)
        % approximate
        md_zero_b0 = round(max(dwi(:,:,:,2:end), [], 4));
        md_zero_b0 = round(mean(dwi(:,:,:,2:end), 4));

        md_zero_b0_vec = vectorize(md_zero_b0, mask);

        pos_zero_MD_app = zeros(size(md_zero_b0_vec));
        for v_idx = 1:size(md_zero_b0_vec, 2)
            v_md_zero_b0 = md_zero_b0_vec(v_idx);
            tmp = find((v_md_zero_b0 - syn_b0_range) > 0);
            pos_zero_MD_app(v_idx) = tmp(end);
        end
    else
        % real
        md_vs_syn_b0_ud = flipud(md_vs_syn_b0);
        md_vs_syn_b0_ud_bi = md_vs_syn_b0_ud < 0;

        [~, zero_MD_indices_ud] = max( md_vs_syn_b0_ud_bi' > 0, [], 2 );
        pos_zero_MD = length(syn_b0_range) - zero_MD_indices_ud' + 1;
    end

    for v_idx = 1:size(mk_vs_syn_b0, 2)
        mk_vs_syn_b0(1:pos_zero_MD(v_idx), v_idx) = 0;
    end
end

%% Locate max_MK_b0 and zero_MK_b0

% mk_vs_syn_b0(mk_vs_syn_b0 < 0) = 0;
mk_vs_syn_b0(mk_vs_syn_b0 > 5) = -1;

% search from the end to find the first 0 value for zero_MK_b0
mk_vs_syn_b0_ud = flipud(mk_vs_syn_b0);
mk_vs_syn_b0_ud_bi = mk_vs_syn_b0_ud < 0;
[~, zero_MK_indices_ud] = max( mk_vs_syn_b0_ud_bi' > 0, [], 2 );
zero_MK_indices_ud(zero_MK_indices_ud == 1) = size(mk_vs_syn_b0_ud_bi, 1);
pos_zero_MK = length(syn_b0_range) - zero_MK_indices_ud' + 2;

for v_idx = 1:size(mk_vs_syn_b0, 2)
    mk_vs_syn_b0(1:pos_zero_MK(v_idx)-1, v_idx) = 0;
end

% find the max valuer after zero_MK_b0 for max_MK_b0
[val_max_MK, pos_max_MK] = max(mk_vs_syn_b0, [], 1);

zero_MK_b0 = syn_b0_range(pos_zero_MK);
max_MK_b0 = syn_b0_range(pos_max_MK);
max_MK = val_max_MK;
%=========
% pos_max_MK very close to pos_zero_MK: mask boundary
% pos_max_MK close to pos_zero_MK, but relative far away: white matter
% pos_zero_MK or pos_max_MK very large (close to the upper b0 limit) : mask boundary

%% Compare orig_b0 to max_MK_b0 and zero_MK_b0

b0_orig = dwi(:, :, :, 1);
b0_orig_vec = vectorize(b0_orig, mask);

voxels_orig_b0_closer_to_zero_MK_b0 = find(b0_orig_vec <= (zero_MK_b0 * (1-th) + max_MK_b0 * th) );

if 1 % these voxels are from the mask boundary; They generated abnormally high MK, so we also fixed them
    voxels_max_MK_b0_equal_to_zero_MK_b0 = find(pos_max_MK - pos_zero_MK <= 2);
    b0_of_voxels_max_MK_b0_equal_to_zero_MK_b0 = b0_orig_vec(voxels_max_MK_b0_equal_to_zero_MK_b0);

    abnormal_situation_1 = [];
    for vv_idx = 1:length(voxels_max_MK_b0_equal_to_zero_MK_b0)
        b0_vv = b0_of_voxels_max_MK_b0_equal_to_zero_MK_b0(vv_idx);
        tmp = find((b0_vv - syn_b0_range) < 0);
        if isempty(tmp)  % actural b0 is very large
            continue;
        end
        b0_idx = tmp(1) - 1;
        max_idx = pos_max_MK(voxels_max_MK_b0_equal_to_zero_MK_b0(vv_idx));

        if b0_idx <= max_idx + 5
            abnormal_situation_1 = [abnormal_situation_1, voxels_max_MK_b0_equal_to_zero_MK_b0(vv_idx)];
        end
    end
    
    voxels_orig_b0_closer_to_zero_MK_b0 = [voxels_orig_b0_closer_to_zero_MK_b0 abnormal_situation_1];
end

% % % There are voxels that generated abnormal MK at the largest synthetic b0 
% % mk_at_largest_at_syn_b0 = mk_vs_syn_b0(end, :);
% % tmp_std = std(mk_at_largest_at_syn_b0);
% % tmp_mean = mean(mk_at_largest_at_syn_b0);
% % voxels_abormal_largest_at_syn_b0 = find(mk_at_largest_at_syn_b0 > tmp_mean+5*tmp_std | mk_at_largest_at_syn_b0 < tmp_mean-5*tmp_std );
% % 
% % % There are voxels that max_MK_b0 == zero_MK_b0; There are in general from ventricle
% % % DO NOT fix
% % voxels_max_MK_b0_equal_to_zero_MK_b0 = find(pos_max_MK - pos_zero_MK == 0);
% % 
% % % There are voxels that max_MK_b0 is close to zero_MK_b0 but not the same:
% % % DO NOT fix
% % voxels_max_MK_b0_close_to_zero_MK_b0 = find(pos_max_MK - pos_zero_MK >= 1 & pos_max_MK - pos_zero_MK < 2);

% abnormal voxel detection
voxels_abnormal = voxels_orig_b0_closer_to_zero_MK_b0;

% normal voxels
voxels_normal = setdiff(1:sum(mask(:)), voxels_abnormal);

% result
zero_MK_b0_image = vectorize(zero_MK_b0, mask);
max_MK_b0_image = vectorize(max_MK_b0, mask);

tmp_vec = zeros([1, sum(mask(:) > 0)]); 
tmp_vec(voxels_abnormal) = 1;
voxels_abnormal_mask = vectorize(tmp_vec, mask);
voxels_abnormal_mask = voxels_abnormal_mask > 0;

save(fullfile(output_dir, 'abnormal_detection_output.mat'), 'zero_MK_b0', 'max_MK_b0', 'voxels_abnormal_mask');

return;

%% debug

% plot mk
load(fullfile(output_dir, 'original_MK.mat'));
orig_mk_vec = vectorize(mk_orig, mask);

abnormal_high_b0_vec = sum(mk_vs_syn_b0>3);
voxels_abnormal_high = vectorize(abnormal_high_b0_vec, mask);

IJK = [63, 67, 70];
voi_ind = sub2ind(size(mask), IJK(1), IJK(2), IJK(3));
mask_indices = find(mask(:) > 0);

voi_sub = find(mask_indices == voi_ind)
figure;plot(mk_vs_syn_b0(:, voi_sub))

if 1
    slice = 40;    
    plot_indices = [voxels_abnormal];
    tmp_vec = zeros([1, sum(mask(:) > 0)]); 
    tmp_vec(plot_indices) = 1;
    tmp_img = vectorize(tmp_vec, mask);
    
    target_slice = tmp_img(:, :, slice);
    target_slice(isnan(target_slice)) = 0;
    
    target_mk = mk_orig(:, :, slice);
    
    voxels_abnormal_high_slice = voxels_abnormal_high(:, :, slice)
    
    figure;
    imshow(target_mk);
    hold on;
    spy(voxels_abnormal_high_slice >0, 'r', 15);
    title('Voxels with abnormally high MK values on the MK curve')
    set(gca, 'FontSize', 16)
   
end


if 1
    target_max_MK_b0 = max_MK_b0_image(:, :, 40);
    target_zero_MK_b0 = zero_MK_b0_image(:, :, 40);
    target_orig_MK_b0 = b0_orig(:, :, 40);
    
    
    
    figure;
    subplot(2,2,1)
    imshow(target_max_MK_b0, [0, 800]);
    subplot(2,2,2)
    imshow(target_zero_MK_b0, [0, 800]);
    subplot(2,2,3)
    imshow(target_orig_MK_b0, [0, 800]);
    
    voxels_orig_larger_than_Max_MK = (target_orig_MK_b0 - target_max_MK_b0 ) >= 0;
    voxels_orig_larger_close_Max_MK = (target_orig_MK_b0 > ((target_max_MK_b0 + target_zero_MK_b0) ./ 2)) & ~voxels_orig_larger_than_Max_MK;
    
    figure;
    subplot(1,3,1)
    imshow(target_mk);
    hold on;
    spy(voxels_orig_larger_than_Max_MK, 'r', 8);
    title('Actural b0 larger than max-MK b0')
    set(gca, 'FontSize', 16)
    
    subplot(1,3,2)
    imshow(target_mk);
    hold on;
    spy(voxels_orig_larger_close_Max_MK , 'r', 8);
    title('Actural b0 closer to max-MK b0 than zero-MK b0')
    set(gca, 'FontSize', 16)
    
    subplot(1,3,3)
    imshow(target_mk);
    hold on;
    spy(voxels_abnormal_mask(:, :, 40) , 'r', 8);
    title('Abnormal voxels')
    set(gca, 'FontSize', 16)
   
end




