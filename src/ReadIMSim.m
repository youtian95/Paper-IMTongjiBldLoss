function [IM_mat,Tvec] = ReadIMSim(IDvec,IMSim_dir)
% 
% 输入：
% IDvec - 每个建筑的ID
% IMSim_dir - 结果文件夹
%
% 输出：
% IM_mat - [numel(IDvec),N_sim,i_T]

N_site = numel(IDvec);

listing = dir(fullfile(IMSim_dir,"IM sim with period*.txt"));
Tvec = double(string(extractBetween({listing.name},"IM sim with period",".txt")));
% 从小到大排序
[Tvec,I] = sort(Tvec);
listing = listing(I);

for i_T=1:numel(listing)
    A = readmatrix(fullfile(IMSim_dir,listing(i_T).name));
    N_sim = size(A,2)-1;
    IM_mat_1T = zeros([N_site,N_sim]);
    for i_bld = 1:N_site
        IM_mat_1T(i_bld,:) = A(i_bld,2:end);
    end
    IM_mat(:,:,i_T) = IM_mat_1T;
end



end

