function save_nii_parameters(nii_file, parameter_file, ouput_folder, output_prefix)

if ~exist(ouput_folder, 'dir')
    mkdir(ouput_folder);
end

if strcmp(output_prefix, 'corrected') || strcmp(output_prefix, 'original')
    map_names = {'mk', 'rk', 'ak', 'fa', 'md', 'rd', 'ad', 'e1', 'e2', 'e3'};
    out_names = {'MK', 'RK', 'AK', 'FA', 'MD', 'RD', 'AD', 'E1', 'E2', 'E3'};
elseif strcmp(output_prefix, 'zero_max_MK_images')
    map_names = {'zero_MK_b0_image', 'max_MK_b0_image', 'max_MK_image'};
    out_names = {'ZeroMK-b0', 'MaxMK-b0', 'MaxMK'};
    output_prefix = 'MKCurve';
elseif strcmp(output_prefix, 'abnormal_mask')
    map_names = {'voxels_abnormal_mask'};
    out_names = {'implausible_voxels'};
    output_prefix = 'mask';
elseif strcmp(output_prefix, 'problematic_mask')
    map_names = {'mk', 'rk', 'ak', 'fa', 'md', 'rd', 'ad', 'e1', 'e2', 'e3', 'voxels_unusual_curve_pattern_mask', 'fit_warning_mask'};
    out_names = {'MK', 'RK', 'AK', 'FA', 'MD', 'RD', 'AD', 'E1', 'E2', 'E3', 'voxels_unusual_MKC', 'fit_warning'};
    output_prefix = 'mask_problematic_mask';
end

parameters = load(parameter_file);
if isfield(parameters, 'problematic_mask')
    parameters = parameters.problematic_mask;
end

for m_idx = 1:length(map_names)
    map_name = map_names{m_idx}; 
    map = parameters.(map_name);
    
    % truncate the parameter values when there are extremely implausible values
    if isempty(strfind(output_prefix, 'mask'))
        map = truncate_parameters(map, out_names{m_idx});
    end
    
    output_file = fullfile(ouput_folder, [output_prefix, '_', out_names{m_idx}, '.nii.gz']);

    data_nii = load_nii(nii_file);
    data_nii.img = single(map);
    data_nii.hdr.dime.datatype = 16;
    data_nii.hdr.dime.bitpix = 32;
    data_nii.original.hdr.dime.datatype = 16;
    data_nii.original.hdr.dime.bitpix = 32;

    save_nii(data_nii, output_file);
end