classdef HazardCurve < handle
    % 根据小震、中震、大震拟合地震危险性曲线&一致危险谱(规范反应谱的形状)
    %
    % （1）只有小震和大震时，拟合曲线为 ln(lamda) = a+b*Sa 或 lamda = a*Sa^(-b)
    %
    % （2）有小震、中震、大震时，拟合曲线为双曲函数, 根据小震、中震、大震的点
    %       进行最小二乘拟合, 拟合函数为 ln(lamda) = ln(k1)+k2/(ln(IM)-ln(k3)); 
    %    Bradley BA, Dhakal RP, Cubrinovski M, Mander JB, MacRae GA. 
    %       Improved seismic hazard model with application to probabilistic 
    %       seismic demand analysis. Earthquake Eng Struc. 2007;36:2211-25. 
    
    properties (SetAccess=protected)
        T
        alpha           %alpha向量，从大到小
        returnPeriod    %回归周期向量
        Tg
        xi
    end
    
    % （2）方法中的参数
    properties (Access=protected)
        k_para
        FirstTime = true   % 是否第一次运行
    end
    
    methods
        function obj = HazardCurve(T,alpha,returnPeriod,Tg,xi)
            %记录
            obj.T=T;
            obj.alpha=alpha;
            obj.returnPeriod=returnPeriod;
            obj.Tg=Tg;
            obj.xi=xi;
        end
        
        %查询地震危险性曲线的值的函数
        function lamda=getlamda(obj,Sa)
            if numel(obj.alpha)==2
                lamda=obj.getlamda2(Sa);
            elseif numel(obj.alpha)==3
                lamda=obj.getlamda3(Sa);
            end
        end
        %生成地震危险性曲线的数据
        function lamda=Createlamda(obj,Sa1,Sa2)
            lamda(1,:)=Sa1:0.01:Sa2;
            lamda(2,:)=obj.getlamda(lamda(1,:));
        end
        %绘制地震危险性曲线
        function plotHazardCurve(obj,SaMin,SaMax)
            Sa=SaMin:0.01:SaMax;
            lamda=obj.getlamda(Sa);
            loglog(Sa,lamda);
            hold on;
            Sa_ = [];
            for i=1:numel(obj.alpha)
                Sa_ = [Sa_;obj.CreateASpectra(obj.T,obj.alpha(i),obj.Tg,obj.xi)];
            end
            scatter(Sa_,1./obj.returnPeriod);
        end
        %生成一致危险谱数据
        function UHS=CreateUHS(obj,Sa1,Sa2,n)
            UHS(1,:)=0:0.01:6; %第一行周期
            %n个烈度
            for i=1:n
                %i烈度大小
                SaT=Sa1+(Sa2-Sa1)/n/2+(Sa2-Sa1)/n*(i-1); 
                %计算i烈度的危险谱
                j=1;
                for tempT=0:0.01:6
                    amp=SaT./obj.CreateASpectra(obj.T,obj.alpha(1),obj.Tg,obj.xi); %调整系数
                    S(j)=obj.CreateASpectra(tempT,obj.alpha(1).*amp,obj.Tg,obj.xi); %i烈度的危险谱值
                    j=j+1;
                end
                UHS(i+1,:)=S;
            end
        end
        %绘制一致危险谱
        function plotUHS(obj,Sa1,Sa2,n)
            UHS=obj.CreateUHS(Sa1,Sa2,n);
            hold on;
            for i=1:n
                plot(UHS(1,:),UHS(i+1,:));
            end
        end
    end
    
    methods (Access=protected)
        % 只有小震和大震时的lamda拟合曲线
        function lamda=getlamda2(obj,Sa)
            % 拟合曲线为 ln(lamda) = a+b*ln(Sa)
            lamda1=1/obj.returnPeriod(1);
            lamda2=1/obj.returnPeriod(2);
            Sa1=obj.CreateASpectra(obj.T,obj.alpha(1),obj.Tg,obj.xi);
            Sa2=obj.CreateASpectra(obj.T,obj.alpha(2),obj.Tg,obj.xi);
            k2=-log(lamda1/lamda2)/log(Sa1/Sa2);
            k1=Sa1^k2*lamda1;
            lamda=k1.*Sa.^(-k2);
        end
        function lamda=getlamda2_(obj,Sa_in)
            % 拟合曲线为 ln(lamda) = a+b*Sa
            %   left_vec = right_A*[a;b]
            left_vec = log(1./obj.returnPeriod)';
            Sa = [];
            for i=1:numel(obj.alpha)
                Sa = [Sa;obj.CreateASpectra(obj.T,obj.alpha(i),obj.Tg,obj.xi)];
            end
            right_A = [ones(2,1),Sa];
            Para = right_A\left_vec;
            lamda = exp([ones(numel(Sa_in),1),Sa_in']*Para)';
        end
        % 小震、中震、大震时的lamda拟合曲线
        function lamda=getlamda3(obj,Sa_in)
            % 拟合曲线为 ln(lamda) = ln(k1)+k2/(ln(IM)-ln(k3))
            F = @(k,IM) log(k(1))+k(2)./(log(IM)-log(k(3)));
            if obj.FirstTime
                lamda_vec=1./obj.returnPeriod;
                Sa1_vec = [];
                for i=1:numel(lamda_vec)
                    Sa1_vec=[Sa1_vec, ...
                        obj.CreateASpectra(obj.T,obj.alpha(i),obj.Tg,obj.xi)];
                end
                % 最小二乘法
                k0 = [100 50 20]; %初始参数
                options = optimoptions('lsqcurvefit','MaxFunctionEvaluations',500*numel(lamda_vec));
                [obj.k_para,resnorm,~,exitflag,output] = lsqcurvefit(F,k0,Sa1_vec,log(lamda_vec),[],[],options);
                obj.FirstTime=false;
            end
            % 输出
            lamda=exp(F(obj.k_para,Sa_in));
        end
    end
    
    methods (Static)
        function alpha=CreateASpectra(T,alphaMax,Tg,xi)
            % 生成加速度反应谱
            %参数
            gamma=0.9+(0.05-xi)/(0.5+5*xi);
            eta1=max((0.02+(0.05-xi)/8),0);
            eta2=max((1+(0.05-xi)/(0.06+1.7*xi)),0.55);
            %反应谱
            if T>=0 && T<0.1
                %上升段
                alpha=(0.45./eta2+10.*(1-0.45./eta2).*T).*eta2.*alphaMax;
            elseif T>=0.1 && T<=Tg
                %水平段
                alpha=eta2.*alphaMax;
            elseif T>Tg && T<=5*Tg
                %下降段
                alpha=(Tg./T).^(gamma).*eta2.*alphaMax;
            elseif T>5*Tg && T<=6.0
                %倾斜段
                alpha=(0.2^gamma-eta1/eta2.*(T-5*Tg)).*eta2.*alphaMax;
            else
                error('周期T范围不对');
            end
        end
    end
end

