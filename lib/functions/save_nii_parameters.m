function save_nii_parameters(nii_file, parameter_file, ouput_folder, output_prefix)

if ~exist(ouput_folder, 'dir')
    mkdir(ouput_folder);
end

parameters = load(parameter_file);
map_names = {'mk', 'rk', 'ak', 'fa', 'md', 'rd', 'ad', 'e1', 'e2', 'e3'};

for m_idx = 1:length(map_names)
    map_name = map_names{m_idx}; 
    map = parameters.(map_name);

    map(isnan(map)) = 0;
    
    output_file = fullfile(ouput_folder, [output_prefix, '_', upper(map_name), '.nii.gz']);

    data_nii = load_nii(nii_file);
    data_nii.img = single(map);
    data_nii.hdr.dime.datatype = 16;
    data_nii.hdr.dime.bitpix = 32;
    data_nii.original.hdr.dime.datatype = 16;
    data_nii.original.hdr.dime.bitpix = 32;

    save_nii(data_nii, output_file);
end