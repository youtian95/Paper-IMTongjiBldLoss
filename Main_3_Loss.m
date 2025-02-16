% 单体建筑损失分析

load(fullfile('.\results\IDA\','Capacity3D'), "Capacity3D");
addpath(".\src\");

%% 读取各层面积和周期
infodir = '.\Data\建筑基本信息';
Capacity3D = ReadBldBasicInfo(infodir,Capacity3D);
save(['.\results\IDA\','Capacity3D'], "Capacity3D");

%% 生成输入文件：地震损失分析

% 生成建筑构件数量文件
StructComponentsDir = ".\Data\结构构件数量人工统计";
for i_bld = 1:numel(Capacity3D)
    Capacity3D_1 = Capacity3D(i_bld);
    bldname = Capacity3D_1.ModelName;
    QNTFile = fullfile(".\results\构件数量",bldname,"QNT.csv");
    StartOver = true; % 是否重新生成
    CreatePelicunQNT(Capacity3D_1,QNTFile,StructComponentsDir,StartOver);
end

%% Pelicun损失分析

RunPelicunDir = ".\src\Pelicun loss assessment";
for i_bld = 1:numel(Capacity3D)
    Capacity3D_1 = Capacity3D(i_bld);
    bldname = Capacity3D_1.ModelName;
    fprintf("%s性能分析...\n",bldname);
    for i_IM = 1:numel(Capacity3D_1.IMList)
        % 结果位置
        OutputDir = fullfile(".\results\Pelicun performance assessment",bldname, ...
            sprintf("IM_%.2f",Capacity3D_1.IMList(i_IM)));
        % 构件数量位置
        QNTFile = fullfile(".\results\构件数量",bldname,"QNT.csv");
        % 运行pelicun
        [status,Cmdout] = RunPelicun1Bld1IM(Capacity3D_1,i_IM,OutputDir,RunPelicunDir,QNTFile);
        if status
            warning("Pelicun程序运行失败: %s, IM=%.2f",bldname,Capacity3D_1.IMList(i_IM));
        end
    end
end

%% 读取地震损失分析结果

ResultDir = '.\results\Pelicun performance assessment\';
Capacity3D = ReadPelicunResults(Capacity3D,ResultDir);
save(['.\results\IDA\','Capacity3D'], "Capacity3D");

%% 地震损失分析绘图
BldName = "综合楼"; % "北楼","图书馆","旭日楼","逸夫楼","综合楼"
IMPlotPer = [0.2,0.5,1]; % 绘图IM, 倒塌Sa中值的倍数
WorkersPerSQMeters = 0.01;

Capacity3D_1 = Capacity3D([Capacity3D.ModelName]==BldName);
MaxArea = max(cell2mat(Capacity3D_1.area));
Nworkers = MaxArea*WorkersPerSQMeters;
Plot_EmpiricalCDF(Capacity3D_1.RC, Capacity3D_1.IMListForLoss, ...
    Capacity3D_1.medianSa, IMPlotPer, 0.01, ...
    x_unit=10^6, Scale=6.5, UnitStr="RMB",XlabelStr="维修费用"); %100000
xlim([0,250]);
Plot_EmpiricalCDF(Capacity3D_1.RT, Capacity3D_1.IMListForLoss, ...
    Capacity3D_1.medianSa, IMPlotPer, 0.5, ...
    x_unit=1, Scale=1/Nworkers,UnitStr="天",XlabelStr="维修时间"); %100000
xlim([0,200]);