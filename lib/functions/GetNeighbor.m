function [ind] = GetNeighbor(vox,sz,ws)
% Coded by Ofer Pasternak: ofer@bwh.harvard.edu
% Use on your own risk. 
% This code was not meant to be used as a clinical tool.

% neighbor size 
if ~exist('ws','var')
    ws = 1;
end

% finds the indices of neighboring voxels
%sz = size(atten); 
%[x,y,z] = ind2sub(sz(2:4),vox);
[x,y,z] = ind2sub(sz,vox);

[x_sub,y_sub,z_sub] = meshgrid([x-ws:x+ws],[y-ws:y+ws],[z-ws:z+ws]);

%ind = sub2ind_MDTV(sz(2:4), x_sub,y_sub,z_sub);
ind = sub2ind_MDTV(sz, x_sub,y_sub,z_sub);

% [ right left up down rightup rightdown leftup leftdown upright upleft 





