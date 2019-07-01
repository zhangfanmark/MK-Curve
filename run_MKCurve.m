function run_MKCurve(nii_file, bval_file, bvec_file, mask_file, sub_output_folder, flag_plot)

addpath(genpath('lib'));

output_dir = fullfile(sub_output_folder, 'out');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Prepare DWI dataset
fprintf('Load dwi dataset, compute mean b0 (if there are multiple b0 images) and fix non-negative signals \n')
original_dwi_file = fullfile(output_dir, 'original_dwi.mat');
original_mask_file = fullfile(output_dir, 'brain_mask.mat');
if ~exist(original_mask_file, 'file')
    [dwi, grad, mask] = prepare_data(nii_file, bval_file, bvec_file, mask_file, output_dir);
    save(original_mask_file, 'mask');
    save(original_dwi_file, 'dwi', 'grad', 'mask', '-V7.3');
else
    load(original_dwi_file);
end

%% Original DKI maps
fprintf('\n');
fprintf('Compute original MK map using raw dwi')
original_MK_file = fullfile(output_dir, 'original_MK.mat');
original_parameter_file = fullfile(output_dir, 'original_parameters');
if ~exist(original_MK_file, 'file')
    [~, dt] = dki_fit(dwi, grad, mask, [0, 0, 0]);
    mk = dki_mk_only(dt, mask);
    save(original_MK_file, 'dt', 'mk');
    
    [fa, md, rd, ad, fe, mk, rk, ak, e1, e2, e3] = dki_parameters(dt, mask);
    save(fullfile(output_dir, 'original_parameters'), 'fa', 'md', 'rd', 'ad', 'fe', 'mk',  'rk', 'ak', 'e1', 'e2', 'e3');
else
    load(original_MK_file);
end

%% MK-curve computation
fprintf('\n');
fprintf('Compute MK curves versus synthetic b0 values')

if  ~isempty(strfind(sub_output_folder, 'Shanghai'))
    syn_b0_range = 2:2:1500;
    slice_id = 40;
elseif  ~isempty(strfind(sub_output_folder, 'HCP'))
    syn_b0_range = 50:100:10000;
    slice_id = 3;
else
    b0 = dwi(:, :, :, 1);
    mean_b0 = mean(b0(mask));
    up_lim = mean_b0 * 2;
    down_lim = 50;
    syn_b0_range = down_lim:200:up_lim;
    slice_id = 1;
end

mk_vs_syn_b0 = MK_versus_synthetic_b0(dwi, grad, mask, syn_b0_range, output_dir);

%% Implausible Voxel Detection and correction
th_range = [0, 0.1, 0.3, 0.5, 0.7, 0.9, 1];
for th = th_range
    output_th_dir = fullfile(output_dir, ['threshold_', num2str(th, '%0.2f')]);
    if exist(output_th_dir) == 0
        mkdir(output_th_dir)
    end
    
    fprintf('\n');
    fprintf('Threshold - %0.2f \n', th)
    if ~exist(fullfile(output_th_dir, 'fixed_parameters.mat'), 'file')
        
        % Implausible voxel detection
        fprintf(' - abnormal MK detection \n');
        [zero_MK_b0_image, max_MK_b0_image, voxels_abnormal_mask] = abnormal_voxel_detection(mk_vs_syn_b0, dwi, mask, syn_b0_range, th, output_th_dir);
        fprintf('   * total voxels (%d), abnormal voxels (%d)\n', sum(mask(:)>0), sum(voxels_abnormal_mask(:)>0));

        save(fullfile(output_th_dir, 'zero_max_MK_images'), 'zero_MK_b0_image', 'max_MK_b0_image');
        save(fullfile(output_th_dir, 'voxels_abnormal_mask'), 'voxels_abnormal_mask');

        % Implausible voxel correction
        fprintf(' - correction for the abnormal voxels \n');
        dwi_fixed = dwi;
        fixed_b0 = dwi(:, :, :, 1);
        fixed_b0(voxels_abnormal_mask) = zero_MK_b0_image(voxels_abnormal_mask) * (1 - th) + max_MK_b0_image(voxels_abnormal_mask) * th;
        dwi_fixed(:, :, :, 1) = fixed_b0;

        save(fullfile(output_th_dir, 'fixed_b0'), 'fixed_b0');
        save(fullfile(output_th_dir, 'fixed_dwi'), 'dwi_fixed', 'grad', '-V7.3');
        
        % Compute fixed parameters
        fprintf(' - fixed parameters computation \n');
        [~, dt] = dki_fit(dwi_fixed, grad, mask, [0, 0, 0]);
        [fa, md, rd, ad, fe, mk, rk, ak, e1, e2, e3] = dki_parameters(dt, mask);
        save(fullfile(output_th_dir, 'fixed_parameters'), 'fa', 'md', 'rd', 'ad', 'fe', 'mk',  'rk', 'ak', 'e1', 'e2', 'e3');
    else
        fprintf(' - Already done \n');
    end
end

%%
if flag_plot == 1
    orig_parameter = load(original_parameter_file);
    plot_idx = 1;
    figure('units','normalized','outerposition',[0 0 1 1])
    for th = th_range
        output_th_dir = fullfile(output_dir, ['threshold_', num2str(th, '%0.2f')]);
        fixed_parameters = load(fullfile(output_th_dir, 'fixed_parameters'));
        detected_mask = load(fullfile(output_th_dir, 'voxels_abnormal_mask'));

        mk_orig_slice = orig_parameter.mk(:, :, slice_id);
        mk_fixed_slice = fixed_parameters.mk(:, :, slice_id);
        abnormal_mk_slice = detected_mask.voxels_abnormal_mask(:, :, slice_id);

        img = [mk_orig_slice mk_orig_slice mk_fixed_slice];
        subtightplot(ceil(length(th_range)/2), 2, plot_idx, 0.04);
        plot_idx = plot_idx + 1;
        imshow(img, [0, 1.5]);
        hold on;
        spy([zeros(size(mk_orig_slice)), abnormal_mk_slice, zeros(size(mk_orig_slice))], 'r', 3);
        title(['Threshold = ', num2str(th), ', implausible #: ', num2str(nansum(abnormal_mk_slice(:)))])
        set(gca, 'FontSize', 25);
    end 
   
    export_fig(gcf, fullfile(output_dir, ['MK-Curve_results.png']), '-transparent') 
end

