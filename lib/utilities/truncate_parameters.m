function map = truncate_parameters(map, map_name)

map(isnan(map)) = 0;

map_name = lower(map_name);

if ~isempty(strfind(map_name, '_fa'))
    
    parameter_range = [-0.01, 2];

elseif ~isempty(strfind(map_name, '_md')) || ...
       ~isempty(strfind(map_name, '_ad')) || ...
       ~isempty(strfind(map_name, '_rd')) || ...
       ~isempty(strfind(map_name, '_e1')) || ...
       ~isempty(strfind(map_name, '_e2')) || ...
       ~isempty(strfind(map_name, '_e3'))
    
   parameter_range = [-0.01, 0.004];

elseif ~isempty(strfind(map_name, '_mk')) || ...
       ~isempty(strfind(map_name, '_ak')) || ...
       ~isempty(strfind(map_name, '_rk'))
   
   parameter_range = [-0.01, 10];
   
else
    
   parameter_range = [min(map(:)), max(map(:))];

end

map(map < parameter_range(1)) = parameter_range(1);
map(map > parameter_range(2)) = parameter_range(2);
