function dist = Station_Dist_Mat(RSN1,RSN2,EQDataStruct)
% 两个台站之间的距离
% 
% 输入：
% EQDataStruct - 台站地震波信息
% RSN - RSN编号行向量
%
% 输出：
% dist - 矩阵km, numel(RSN1)*numel(RSN2)

% 距离矩阵
RSN1_ = reshape(RSN1'*ones(1,numel(RSN2)),[],1);
RSN2_ = reshape(ones(numel(RSN1),1)*RSN2,[],1);
dist_vec = Station_Dist(RSN1_',RSN2_',EQDataStruct);
dist = reshape(dist_vec,[numel(RSN1),numel(RSN2)]);
dist = (dist + dist')./2; % 确保对称

end

