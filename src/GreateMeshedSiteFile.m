function [IDvec,lonVec,latVec,TVec] = GreateMeshedSiteFile(SiteFile,T0,MeshDist, ...
    lonMin,lonMax,latMin,latMax)
% 生成网格状场地文件
%
% 输入：
% SiteFile - 文件名'SiteFile.txt'
% T0 - 对应的周期, 不能为向量
% MeshDist - 网格距离, m
% lonMin,lonMax,latMin,latMax - 范围, °
%
% 输出：
% IDvec - 每个场地的ID
% lonVec, latVec - 对应的经纬度
% SiteFile - 每一行为: ID,lon,lat,elevation_km,period1,Vs30_mpers,Z25_km
% TVec - 对应的周期

arguments
    SiteFile
    T0 (1,1) double
    MeshDist (1,1) double
    lonMin (1,1) double
    lonMax (1,1) double
    latMin (1,1) double
    latMax (1,1) double
end

if exist(SiteFile)
    delete(SiteFile);
end

% 计算网格点
R = 6374000; 
lonStep = MeshDist/R/cosd(latMin)*180/pi;
latStep = MeshDist/R*180/pi;
Nlon = ceil((lonMax-lonMin)/lonStep);
Nlat = ceil((latMax-latMin)/latStep);

% 生成场地文件
IDvec = []; lonVec = []; latVec = []; TVec = [];
ID = 0;
obj = SearchVs30();
for row = 1:Nlon
    for col = 1:Nlat
        lon = lonMin + (row-1)*lonStep;
        lat = latMin + (col-1)*latStep;
        elevation_km = 0;
        Vs30_mpers = obj.GetVs30(lon,lat);
        Z25_km = 999; % unknown
        for i_T = 1:numel(T0)
            ID = ID+1;
            period1 = T0(i_T);
            writematrix([ID,lon,lat,elevation_km,period1,Vs30_mpers,Z25_km], ...
                SiteFile,'WriteMode','append','Delimiter',' ');
            IDvec = [IDvec,ID];
            lonVec = [lonVec, lon];
            latVec = [latVec, lat];
            TVec = [TVec,period1];
        end
    end
end

end

