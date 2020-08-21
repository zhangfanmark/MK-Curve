function [zero_MK_b0_image, max_MK_b0_image, max_MK_image, voxels_abnormal_mask, voxels_unusual_curve_pattern_mask] = abnormal_voxel_detection(mk_vs_syn_b0, dwi, mask, syn_b0_range, th, output_dir)

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

if 1 % these voxels are from the mask boundary; They generated abnormally high MK; we also fix them
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

% abnormal voxel detection
voxels_abnormal = voxels_orig_b0_closer_to_zero_MK_b0;

% result
zero_MK_b0_image = vectorize(zero_MK_b0, mask);
max_MK_b0_image = vectorize(max_MK_b0, mask);
max_MK_image = vectorize(max_MK, mask);

tmp_vec = zeros([1, sum(mask(:) > 0)]); 
tmp_vec(voxels_abnormal) = 1;
voxels_abnormal_mask = vectorize(tmp_vec, mask);
voxels_abnormal_mask = voxels_abnormal_mask > 0;

tmp_vec = zeros([1, sum(mask(:) > 0)]); 
tmp_vec(abnormal_situation_1) = 1;
voxels_unusual_curve_pattern_mask = vectorize(tmp_vec, mask);
voxels_unusual_curve_pattern_mask = voxels_unusual_curve_pattern_mask > 0;

% save(fullfile(output_dir, 'abnormal_detection_output.mat'), 'zero_MK_b0', 'max_MK_b0', 'max_MK', 'voxels_abnormal_mask', 'voxels_unusual_curve_pattern_mask');
