function EQ_pair = NchooseKpair(RSN_vec,ifself)
% 从N个台站中选出一对台站的组合
%
% 输入：
% RSN_vec - RSN向量
% ifself - 是否是同一个结构
% 
% 输出：
% EQ_pair - EQ对 N x 2

if ifself
    EQ_pair = nchoosek(RSN_vec,2);
    EQ_pair = [EQ_pair;[RSN_vec;RSN_vec]'];
else
    EQ_pair = [];
    for i=1:numel(RSN_vec)
        for j=1:numel(RSN_vec)
            EQ_pair = [EQ_pair;RSN_vec(i),RSN_vec(j)];
        end
    end
end

end

