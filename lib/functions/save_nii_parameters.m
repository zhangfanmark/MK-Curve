function save_nii_parameters(nii_file, parameter_file, ouput_folder, output_prefix)

if ~exist(ouput_folder, 'dir')
    mkdir(ouput_folder);
end

parameters = load(parameter_file);
if strcmp(output_prefix, 'corrected') || strcmp(output_prefix, 'original')
    map_names = {'mk', 'rk', 'ak', 'fa', 'md', 'rd', 'ad', 'e1', 'e2', 'e3'};
    out_names = {'MK', 'RK', 'AK', 'FA', 'MD', 'RD', 'AD', 'E1', 'E2', 'E3'};
elseif strcmp(output_prefix, 'zero_max_MK_images')
    map_names = {'zero_MK_b0_image', 'max_MK_b0_image', 'max_MK_image'};
    out_names = {'ZeroMK-b0', 'MaxMK-b0', 'MaxMK'};
    output_prefix = 'MKCurve';
end

for m_idx = 1:length(map_names)
    map_name = map_names{m_idx}; 
    map = parameters.(map_name);
    
    % truncate the parameter values when there are extremely implausible values
    map = truncate_parameters(map, out_names{m_idx});
    
    output_file = fullfile(ouput_folder, [output_prefix, '_', out_names{m_idx}, '.nii.gz']);

    data_nii = load_nii(nii_file);
    data_nii.img = single(map);
    data_nii.hdr.dime.datatype = 16;
    data_nii.hdr.dime.bitpix = 32;
    data_nii.original.hdr.dime.datatype = 16;
    data_nii.original.hdr.dime.bitpix = 32;

    save_nii(data_nii, output_file);
end