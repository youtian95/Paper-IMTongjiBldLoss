function dist = Station_Dist(RSN1,RSN2,EQDataStruct)
% 两个台站之间的距离
% 
% 输入：
% EQDataStruct - 台站地震波信息
% RSN - RSN编号（可以是行向量）
%
% 输出：
% dist - km

RSNvec = [EQDataStruct.RecordSequenceNumber];

[row,~] = find((RSNvec==RSN1')');
lng1 = [EQDataStruct(row).StationLongitude];
lat1 = [EQDataStruct(row).StationLatitude];

[row,~] = find((RSNvec==RSN2')');
lng2 = [EQDataStruct(row).StationLongitude];
lat2 = [EQDataStruct(row).StationLatitude];

dist = LngLat_Small_Distance(lng1',lat1',lng2',lat2')./1000;

end

