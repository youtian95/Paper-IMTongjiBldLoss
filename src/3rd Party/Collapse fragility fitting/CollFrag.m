classdef CollFrag < handle
    %倒塌概率拟合,最大似然估计; 注意: 需要安装 Optimization Toolbox 
    %
    
    properties (SetAccess=protected)
        medianSa   %均值
        sigmalnSa  %对数标准差
    end
    properties (Access=protected)
        Sa   
        Pcon %条件概率观测值
    end
    
    methods
        function obj = CollFrag(Sa,Pcon)
            obj.Sa = Sa;
            obj.Pcon = Pcon;
            if norm(Pcon)==0
                obj.medianSa = inf; %无穷大
                obj.sigmalnSa = 0;
            else
                obj.CurveFit();
            end
        end
        function plotFit(obj)
            %拟合值
            pd = makedist('Lognormal','mu',log(obj.medianSa),'sigma',obj.sigmalnSa); %对数正态分布对象
            x= exp(log(obj.medianSa)-3*obj.sigmalnSa):0.01:exp(log(obj.medianSa)+3*obj.sigmalnSa);
%             x=0:0.01:3.5;
            y = cdf(pd,x);
            plot(x,y); 
            %离散值
            hold on;
            scatter(obj.Sa,obj.Pcon);
        end
    end
    
    methods (Access=protected)
        function CurveFit(obj)
            %有约束非线性优化
            fun=@(x) -obj.SumofSquares(x(1),x(2)); %使概率最大
            x0 = [0,1]; %初始值
            A = []; b = []; %线性不等式约束
            Aeq = []; beq = [];%线性等式约束
            lb = [-inf,0]; ub = [inf,1]; %x范围
            result = fmincon(fun,x0,A,b,Aeq,beq,lb,ub);
            obj.medianSa=exp(result(1));
            obj.sigmalnSa=result(2);
        end
        
        function sumofR=SumofSquares(obj,mu,sigma)
            %残差
            pd1 = makedist('Lognormal','mu',mu,'sigma',sigma); %对数正态分布对象
            y = cdf(pd1,obj.Sa);
            for i=1:size(obj.Sa,2)
                temp = makedist('Binomial','N',size(obj.Sa,2),'p',y(i));%二项分布
                pd2(i) = pdf(temp,int8(obj.Pcon(i)*size(obj.Sa,2)));   %发生obj.Pcon(i)次的概率
            end
            sumofR=sum(log(pd2));
        end
    end
end

