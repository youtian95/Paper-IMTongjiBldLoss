function [ind,exitflag,output] = FindStationSet_SumDist(DistMat,N_EQ,SortMethod)
% 找出"距离和"最小/大的台站组合
% 
% 输入：
% SortMethod - 'smallest', 'greatest'

N = size(DistMat,1);
assert(N>=N_EQ);

nvars = N_EQ;
% 非线性约束 Ax<=b
% 依次增大 x(i-1)-x(i) <= -1
A = [];
b = [];
for i=2:nvars
    rowvec = zeros(1,nvars);
    rowvec(i-1) = 1;
    rowvec(i) = -1;
    A = [A; rowvec];
    b = [b; -1];
end
intcon = 1:nvars; %所有的变量都是整数
Aeq = [];
beq = [];
lb = ones(1,nvars);
ub = N.*ones(1,nvars);
nonlcon = [];
options = optimoptions('ga','PlotFcn', @gaplotbestf);
    function SumDist = DistanceSum(x)
        DistMat_part = DistMat(x,x);
        SumDist = sum(DistMat_part(~eye(numel(x))),"all")/2;
    end
switch SortMethod
    case 'smallest'
        [x,~,exitflag,output] = ga(@DistanceSum,nvars,A,b,Aeq,beq,lb,ub,nonlcon,intcon,options);
    case 'greatest'
        [x,~,exitflag,output] = ga(@(x) -DistanceSum(x),nvars,A,b,Aeq,beq,lb,ub,nonlcon,intcon,options);
end


ind = x;


% 直接遍历方法，当数量较大时，阶乘数太大算不出来
% C = nchoosek(1:N,N_EQ);
% SumDist = zeros(1,size(C,1));
% for i = 1:size(C,1)
%     DistMat_part = DistMat(C(i,:),C(i,:));
%     SumDist(i) = sum(DistMat_part(~eye(N_EQ)),"all")/2;
% end
% [~,I] = sort(SumDist);
% switch SortMethod
%     case 'smallest'
%         ind = C(I(1),:);
%     case 'greatest'
%         ind = C(I(end),:);
% end

end