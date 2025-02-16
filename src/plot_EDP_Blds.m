function plot_EDP_Blds(EDP_type,IM_mat,Capacity3D_part,CovFunMat,HeadBld)
% 绘制EDP的各次模拟图

arguments
    EDP_type 
    IM_mat 
    Capacity3D_part 
    CovFunMat 
    HeadBld (1,1) double = 1
end

BldNames = {Capacity3D_part.ModelName};

% [N_bld,N_sim]
EDPMat = {}; % 三种情况，无关、相关、部分
for i=0:2
    [~,EDPMat_,~] = SimulateRegionalLoss(IM_mat,EDP_type,Capacity3D_part,CovFunMat,i);
    % 消除负数值
    EDPMat_(EDPMat_<=0) = 10^(-6);
    % 标准化 [N_bld,N_sim]
    EDPMat_ = (log(EDPMat_)-mean(log(EDPMat_),2))./std(log(EDPMat_));
    EDPMat{i+1} = EDPMat_;
end

CovCases = {'相互独立','线性相关','部分相关'};
for i=3:3
    for y_bld = 1:numel(Capacity3D_part)
        for x_bld = (y_bld+1):numel(Capacity3D_part)
            xTitle = Capacity3D_part(x_bld).ModelName;
            yTitle = Capacity3D_part(y_bld).ModelName;
            plot_2BldEDP(EDPMat{i}([x_bld,y_bld],:)',xTitle,yTitle);
            fig = gcf;
            fig.Name = CovCases{i};
        end
    end
end


end