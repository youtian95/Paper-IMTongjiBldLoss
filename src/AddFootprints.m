function Capacity3D = AddFootprints(Capacity3D,OSMid,OSMdata)
% 添加数据
% Capacity3D(i_bld).footprint - [lon1,lat1;lon2,lat2; ...]
% Capacity3D(i_bld).centroid - [lon1,lat1]

assert(numel(Capacity3D)==numel(OSMid), "OSMid数量与Capacity3D不对应");

S = readstruct(OSMdata,"FileType","xml");

% footprint
for i_bld = 1:numel(Capacity3D)
    footprint = [];
    bld = S.way([S.way.idAttribute]==OSMid(i_bld));
    for i_node = 1:numel(bld.nd)
        id_node = bld.nd(i_node).refAttribute;
        node = S.node([S.node.idAttribute]==id_node);
        lon = node.lonAttribute;
        lat = node.latAttribute;
        footprint = [footprint;lon,lat];
    end
    pgon = polyshape(footprint);
    [x,y] = centroid(pgon);
    Capacity3D(i_bld).footprint = footprint;
    Capacity3D(i_bld).centroid = [x,y];
end

end