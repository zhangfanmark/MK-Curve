function map = truncate_parameters(map, map_name)

map(isnan(map)) = 0;

map_name = lower(map_name);

if strcmp(map_name, 'fa')
    
    parameter_range = [-0.01, 2];

elseif strcmp(map_name, 'md') || ...
       strcmp(map_name, 'ad') || ...
       strcmp(map_name, 'rd') || ...
       strcmp(map_name, 'e1') || ...
       strcmp(map_name, 'e2') || ...
       strcmp(map_name, 'e3')
    
   parameter_range = [-0.01, 0.01];

elseif strcmp(map_name, 'mk') || ...
       strcmp(map_name, 'maxmk') || ...
       strcmp(map_name, 'ak') || ...
       strcmp(map_name, 'rk')
   
   parameter_range = [-0.01, 6];
   
else
    
   parameter_range = [min(map(:)), max(map(:))];

end


map(map < parameter_range(1)) = parameter_range(1);
map(map > parameter_range(2)) = parameter_range(2);
