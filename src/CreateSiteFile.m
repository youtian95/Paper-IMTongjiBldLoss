function IDvec = CreateSiteFile(Capacity3D,SiteFile)
% 生成场地文件
% 
% 输出: 
% IDvec - 跟Capacity3D对应的ID编号
% SiteFile - 每一行为: ID,lon,lat,elevation_km,period1,Vs30_mpers,Z25_km

if exist(SiteFile)
    delete(SiteFile);
end

IDvec = [];
ID = 0;
obj = SearchVs30();
for i_bld = 1:numel(Capacity3D)
    Capacity3D_1 = Capacity3D(i_bld);
    ID = ID+1;
    lon = Capacity3D_1.centroid(1);
    lat = Capacity3D_1.centroid(2);
    elevation_km = 0;
    period1 = Capacity3D_1.T;
    Vs30_mpers = obj.GetVs30(lon,lat);
    Z25_km = 999; % unknown
    writematrix([ID,lon,lat,elevation_km,period1,Vs30_mpers,Z25_km], ...
        SiteFile,'WriteMode','append','Delimiter',' ');
    IDvec = [IDvec,ID];
end

end