function [EQ_group,Dist] = Group_By_Dist(EQDataStruct,EQ_pair,Dist_inc)
% 对地震波pair按照台站距离分组
% 
% 输入：
% EQDataStruct - 台站地震波信息
% EQ_pair - N x 2，每行为一组地震波
% Dist_inc - 例如[10,15,20]km, 分为3+2组，距离大小为[0,0],[0,10],[10,15],[15,20],[20,+∞]
% 
% 输出：
% EQ_group - {i}, 每个元胞为 N_i x 2 的矩阵
% Dist - 向量，为每对的直线距离


EQ_group = cell(1,numel(Dist_inc)+2);
for i_pair = 1:size(EQ_pair,1)
    lng1 = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        EQ_pair(i_pair,1)).StationLongitude;
    lng2 = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        EQ_pair(i_pair,2)).StationLongitude;
    lat1 = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        EQ_pair(i_pair,1)).StationLatitude;
    lat2 = EQDataStruct([EQDataStruct.RecordSequenceNumber]== ...
        EQ_pair(i_pair,2)).StationLatitude;
    dist = LngLat_Small_Distance(lng1,lat1,lng2,lat2)/1000;
    k = find((dist-[0,Dist_inc])>0.01, 1, 'last');
    if isempty(k) % 0
        EQ_group{1} = [EQ_group{1};EQ_pair(i_pair,:)];
    else
        EQ_group{k+1} = [EQ_group{k+1};EQ_pair(i_pair,:)];
    end
    Dist(i_pair) = dist;
end

end

