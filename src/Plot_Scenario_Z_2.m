function Plot_Scenario_Z_2(imagefile, Z, RSN, ...
    left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong)
% 绘制一次历史地震的参数线图
%
% 输入：
% imagefile - 图片文件名
% Z - 参数行向量
% RSN - 对应的台站向量
% left_long,right_long,left_lat,right_lat - 图片边框经纬度
% EQDataStruct - 台站数据
% EpiLat, EpiLong - 震中经纬度

for i_EQ=1:numel(RSN)
    long = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        RSN(i_EQ)).StationLongitude;
    lat = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        RSN(i_EQ)).StationLatitude;

    long_vec(i_EQ) = long;
    lat_vec(i_EQ) = lat;
end

Plot_Scenario_Z(imagefile, [long_vec;lat_vec;Z]', ...
    left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong);

ax = gca;
zlim auto;
ax.DataAspectRatioMode = 'auto';

end

