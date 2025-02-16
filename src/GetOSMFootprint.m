function Polygon = GetOSMFootprint(OSMdata,id)

Polygon = [];

S = readstruct(OSMdata,"FileType","xml");
way = S.way([S.way.idAttribute]==id);
PolyID = [way.nd.refAttribute];
for i=1:numel(PolyID)
    node = S.node([S.node.idAttribute]==PolyID(i));
    lon = node.lonAttribute;
    lat = node.latAttribute;
    Polygon = [Polygon;[lon,lat]];
end

end