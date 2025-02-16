function [ind,exitflag,output] = FindStationSet_Uniform(DistMat,N_EQ)
% 找出"距离"分布最接近均匀分布的情况

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

    function f = UniformDist(x)
        % 与均匀分布cdf的纵坐标差值的平均值
        DistMat_part = DistMat(x,x);
        DistMat_part = DistMat_part(triu(~eye(numel(x))));
        [f,x] = ecdf(DistMat_part);
        x0 = 0:0.05:max(DistMat,[],'all');
        f0 = x0.*(1/max(DistMat,[],'all'));
        fq = interp1(x0,f0,x,'nearest','extrap');
        f = sum(abs(fq - f))/numel(x);
    end

% 找最小值
[x,~,exitflag,output] = ga(@UniformDist,nvars,A,b,Aeq,beq,lb,ub,nonlcon,intcon,options);


ind = x;


end