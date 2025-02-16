classdef GPR_Stationary_1output < handle
    % 单输出值的稳态高斯过程回归，固定均值，固定方差
    
    properties 
        HyperPara % 超参数
        % squaredexponential: [SigmaF, l]
        % exponential: [SigmaF, l]
        % exponential_plus_constant: [sigmaf,l,C]
        % RationalQuadratic: [sigmaf,l,alpha]
        % RationalQuadratic_plus_constant: [sigmaf,l,alpha,C]
        % squaredexponential_plus_constant: [SigmaF, l, C]
        HyperPara0 = [1,1;1,10] % 优化时初始值，每一行为初始值，可以多行
        IfParaFixed = [0,0] % 是否固定，默认所有超参数可以进行优化
        FixedPara = [0,0]; % 固定的超参数
        KernelType = 4 % Kernel - 核函数形式，k(xp,xq)
    end
    
    properties (Constant)
        KernelTypeList = {'squaredexponential','exponential', ...
            'exponential_plus_constant','RationalQuadratic', ...
            'RationalQuadratic_plus_constant', ...
            'squaredexponential_plus_constant'}
    end
    
    properties (SetAccess = private)
        X % X - D x n，D维输入列向量，n个观测值的坐标
        y % y - n x 1，观测值列向量
    end
    
    methods 
        function obj = GPR_Stationary_1output(X,y)
            % 输入：
            % X - D x n，D维输入列向量，n个观测值的坐标
            % y - n x 1，观测值列向量
            
            obj.X = X;
            if size(y,1)>=1 && size(y,2)==1
                obj.y = y;
            elseif size(y,1)==1 && size(y,2)>=1
                obj.y = y';
            else
                error('输入参数y有误!');
            end
            
        end
        
        function Optimize(obj,lb,ub)
            % 最大似然估计得到 obj.HyperPara
            % lb,ub - 参数的上下限
            fun = @(x) -LogLikelihood(obj,obj.y,obj.X,x,0);
            A = [];
            b = [];
            if all(~obj.IfParaFixed)
                Aeq = [];
                beq = [];
            else
                Aeq = diag(obj.IfParaFixed);
                beq = obj.FixedPara';
            end
            % Aeq去除全0行
            ZeroRows = ~any(Aeq,2);
            Aeq(ZeroRows,:) = [];
            beq(ZeroRows,:) = [];
            f = inf;
            options = optimoptions('fmincon','Algorithm','interior-point', ...
                'StepTolerance',1e-10);
            for i=1:size(obj.HyperPara0,1)
                x0 = obj.HyperPara0(i,:);
                HyperPara_ = fmincon(fun,x0, ...
                    A,b,Aeq,beq,lb,ub,[],options);
                tempf = fun(HyperPara_);
                if tempf<f
                    f = tempf;
                    obj.HyperPara = HyperPara_;
                end
            end
        end
        
        function cov = GetCovariance(obj,x)
            % 返回协方差
            KernelF = str2func(['GPR_Stationary_1output.', ...
                obj.KernelTypeList{obj.KernelType}]);
            temp = zeros(size(x)); temp(x==0)=1;
            cov = KernelF(x,obj.HyperPara) + temp.*0^2;
        end
        
        function f = LOO_CV(obj)
            % 交叉验证, leaving out one损失, - SUM{log[p(yi|X,y-i,theta)]}
            % 书《GPML》 P116 5.4.2节
            K = Ky_mat(obj,obj.X,obj.HyperPara,0);
            K_inv = inv(K);
            miu_vec = obj.y - (K_inv*obj.y)./diag(K_inv);
            sigma2_vec = 1./diag(K_inv);
            f = 0.5*sum(log(sigma2_vec)) + 0.5*sum((obj.y-miu_vec).^2./sigma2_vec) ...
                + 0.5*log(2*pi)*numel(obj.y);
        end
    end
    
    methods (Access = private)
        function f = Ky_mat(obj,X,HyperPara_,SigmaN)
            f = Kf_mat(obj,X,HyperPara_) + SigmaN^2.*eye(size(X,2));
        end
        
        function cov = Kf_mat(obj,X,HyperPara_)
            % 计算协方差矩阵 Kf
            cov = zeros(size(X,2),size(X,2));
            for i=1:size(X,2)
                for j=i:size(X,2)
                    cov(i,j) = obj.Kf(X(:,i),X(:,j),HyperPara_);
                    cov(j,i) = cov(i,j);
                end
            end
        end
        
        function cov = Kf(obj,x1,x2,HyperPara_)
            % 计算协方差 Kf
            KernelF = str2func(['GPR_Stationary_1output.', ...
                obj.KernelTypeList{obj.KernelType}]);
            cov = KernelF(sqrt((x1-x2)'*(x1-x2)),HyperPara_);
        end
        
        function f = LogLikelihood(obj,y,X,HyperPara_,SigmaN)
            % log p(y|X,theta)
            Ky = Ky_mat(obj,X,HyperPara_,SigmaN);
            f = - 0.5.*y'*inv(Ky)*y - 0.5*log(det(Ky)) - size(X,2)/2*log(2*pi);
        end
    end
    
    methods (Static)
        function y = exponential(x,Para)
            y = Para(1)^2 .* exp(-abs(x) ./Para(2));
        end
        
        function y = squaredexponential(x,Para)
            y = Para(1)^2 .* exp(-0.5.*x.^2 ./Para(2)^2);
        end
        
        function y = squaredexponential_plus_constant(x,Para)
            % Para [SigmaF, l, C]
            y = (Para(1)^2-Para(3)) .* exp(-0.5.*x.^2 ./Para(2)^2) ...
                + Para(3);
        end
        
        function y = exponential_plus_constant(x,Para)
            % para [sigmaf,l,C]
            y = (Para(1)^2 - Para(3)).* exp(-abs(x) ./Para(2)) + Para(3);
        end
        
        function y = RationalQuadratic_plus_constant(x,Para)
            % para [sigmaf,l,alpha,C]
            y = (Para(1)^2 - Para(4)) .*(1+x.^2./2./Para(3)./Para(2)^2).^(-Para(3)) ...
                + Para(4);
        end
        
        function y = RationalQuadratic(x,Para)
            % para [sigmaf,l,alpha]
            y = Para(1)^2.*(1+x.^2./2./Para(3)./Para(2)^2).^(-Para(3));
        end
    end
    
end

