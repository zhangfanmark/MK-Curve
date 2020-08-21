function out_of_range_mask = check_output_parameters(parameter_file)


parameters = load(parameter_file);
map_names = {'mk', 'rk', 'ak', 'fa', 'md', 'rd', 'ad', 'e1', 'e2', 'e3'};

out_of_range_mask = [];
for m_idx = 1:length(map_names)
    map_name = map_names{m_idx}; 
    map = parameters.(map_name);
    
    if strcmp(map_name, 'fa')

        parameter_range = [0, 1];

    elseif strcmp(map_name, 'md') || ...
           strcmp(map_name, 'ad') || ...
           strcmp(map_name, 'rd') || ...
           strcmp(map_name, 'e1') || ...
           strcmp(map_name, 'e2') || ...
           strcmp(map_name, 'e3')

       parameter_range = [0, 0.009];

    elseif strcmp(map_name, 'mk') || ...
           strcmp(map_name, 'ak') || ...
           strcmp(map_name, 'rk')

       parameter_range = [0, 3];

    end

    tmp_mask = zeros(size(map));
    tmp_mask(map < parameter_range(1)) = 1;
    tmp_mask(map > parameter_range(2)) = 1;
    
    disp(['Warnining: ', map_name, ' has ', num2str(sum(tmp_mask(:))), ' voxels outside the range: ', num2str(parameter_range(1)), ' - ',  num2str(parameter_range(2))]);
    
    out_of_range_mask.(map_name) = tmp_mask;
   
end
