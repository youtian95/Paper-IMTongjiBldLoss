function IM_mat_Bld = InterpIMfromMesh(IM_mat_Mesh,lonVec,latVec,TVec_Mesh,Capacity3D)
% 根据网格IM模拟结果插值得到建筑所在场地和周期的IM
% 
% 输入：
%   IM_mat_Mesh - 网格模拟结果 (i_ID,i_Sim,i_T)
%   lonVec,latVec - (i_ID)
%   TVec_Mesh - (i_T)
%   Capacity3D - 建筑信息
% 输出：
%   IM_mat_Bld -(i_bld,i_Sim)

% 网格点
[xVec,yVec] = projfwd(projcrs(3857),latVec,lonVec); % Web Mercator projection
% 建筑所在点
centroid = [Capacity3D.centroid];
[xBldVec,yBldVec] = projfwd(projcrs(3857),centroid(2:2:end),centroid(1:2:end));
TBldVec = [Capacity3D.T];

N_bld = numel(Capacity3D); % 建筑数量
N_ID = size(IM_mat_Mesh,1); % 网格点数量
N_sim = size(IM_mat_Mesh,2);
N_T = size(IM_mat_Mesh,3);

% 根据周期TVec_Mesh数量拓展
IM_mat_Mesh = shiftdim(IM_mat_Mesh,2); % (i_T,i_ID,i_Sim)
IM_mat_Mesh = reshape(IM_mat_Mesh,N_T*N_ID,N_sim); % (i_T*i_ID,i_Sim)
xVec = reshape(repmat(xVec,N_T,1),1,[]); % (i_T*i_ID)
yVec = reshape(repmat(yVec,N_T,1),1,[]); % (i_T*i_ID)
TVec_Mesh = repmat(TVec_Mesh,1,N_ID); % (i_T*i_ID)

F = scatteredInterpolant(xVec',yVec',TVec_Mesh',IM_mat_Mesh);
IM_mat_Bld = F(xBldVec,yBldVec,TBldVec); % (i_ID,i_Sim)

end