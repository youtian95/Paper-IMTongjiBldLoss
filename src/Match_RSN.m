function [RSN,ind1,ind2] = Match_RSN(RSN1,RSN2)
% RSN1,RSN2中找出相同的RSN
% 
% 输入：
% RSN - 行向量
% 
% 输出：
% ind - 索引向量, RSN1(ind1) = RSN;

mat = RSN1'==RSN2;
RSN = RSN1(any(mat,2)');
ind1 = find(any(mat,2)');
[row,~] = find(mat');
ind2 = row';

end