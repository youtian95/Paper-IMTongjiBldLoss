% 区域地震损失分析
addpath(".\src\")
addpath('.\src\3rd Party\Gaussian Process Regression');
addpath('.\src\3rd Party\WebMercator2LongLat');
addpath('.\src\3rd Party\Convert Symmetrical Matrix to Semi Positive');
load(fullfile('.\results\IDA\','Capacity3D'), "Capacity3D");

%% 建筑分布

% 给Capacity3D添加建筑经纬度d
OSMdata = ".\Data\OSM\map.osm";
OSMid = [183383474, 49263174, 183383466, 184542424, 181555253];
Capacity3D = AddFootprints(Capacity3D,OSMid,OSMdata);
save(['.\results\IDA\','Capacity3D'], "Capacity3D");

% 建筑绘图
TongjiPoly = GetOSMFootprint(".\Data\OSM\map.osm",24474429);
f = plot_3DBlds_map(Capacity3D,OSMdata,Mask=TongjiPoly,ViewDim=2);

%% IM模拟：生成震源文件
IMSim_dir = '.\src\3rd Party\IMSim';

% 生成震源文件
EQSourceFile = 'EQSource.txt'; % 震源信息文件
ifmedian = 0; % 0为随机
M = 6.0;
N_sim = 10000;
seed = 2;
lon_0 = Capacity3D(1).centroid(1); 
lat_0 = Capacity3D(1).centroid(2) + 10/6370.856*180/pi; % 正北10km
W = 10^(-0.76+0.27*M);
length = exp(log(W*1000/15)*3/2)/1000;
strike = 35; delta = 52;
RuptureNormal_x = cosd(90-delta)*cosd(strike); 
RuptureNormal_y = cosd(90-delta)*sind(strike); 
RuptureNormal_z = sind(90-delta);
lambda = 54; % rake angle
Fhw = 1;
Zhyp = 12;
region = 3;
nPCs = 10;
writecell({ifmedian;M;N_sim;seed;[lon_0,lat_0]; ...
    W;length;[RuptureNormal_x,RuptureNormal_y,RuptureNormal_z]; ...
    lambda;Fhw;Zhyp;region;nPCs},fullfile(IMSim_dir,EQSourceFile),'Delimiter',' ');

%% IM模拟：生成场地文件

IMSim_dir = '.\src\3rd Party\IMSim';
% 生成周围网格场地文件
SiteFile_Mesh = 'SiteFile_Mesh.txt'; 
T0 = 0; MeshDist = 200; 
OSMdata = ".\Data\OSM\map.osm";
S = readstruct(OSMdata,"FileType","xml");
lonMin = S.bounds.minlonAttribute; lonMax = S.bounds.maxlonAttribute;
latMin = S.bounds.minlatAttribute; latMax = S.bounds.maxlatAttribute;
[IDvec_Mesh,lonVec,latVec,~] = GreateMeshedSiteFile( ...
    fullfile(IMSim_dir,SiteFile_Mesh),T0,MeshDist, ...
    lonMin,lonMax,latMin,latMax);

%% IM模拟

% 使用网格IM模拟结果插值作为建筑IM
RunIMSim(IMSim_dir,EQSourceFile,SiteFile_Mesh); 
[IM_mat_Mesh,Tvec_Mesh] = ReadIMSim(IDvec_Mesh,IMSim_dir);
% 插值
IM_mat_Bld = InterpIMfromMesh(IM_mat_Mesh,lonVec,latVec,Tvec_Mesh,Capacity3D);
%% IM绘图
TongjiPoly = GetOSMFootprint(".\Data\OSM\map.osm",24474429);
% gif图输出
iSimListGif = 1:10; gifFilename = './Figures/IMsim_T0_5.gif'; delayTime = 0.5;
for iTplot = 12 % iTplot = [8,12,14]  (T=0.2, 0.5, 1)
    Plot_IM_Spatial(IM_mat_Mesh,lonVec,latVec,Tvec_Mesh,Capacity3D=Capacity3D, ...
        Mask=TongjiPoly,iTplot=iTplot,iSim=100);
    createIMGifFromSimulations(@(x)Plot_IM_Spatial(IM_mat_Mesh,lonVec,latVec, ...
        Tvec_Mesh,Capacity3D=Capacity3D, ...
        Mask=TongjiPoly,iTplot=iTplot,iSim=x), ...
        iSimListGif, gifFilename, delayTime);
end

%% 建筑损失模拟
i_bld = [4,4,4,4,4]; % 模拟的建筑
SP_type = 'RC_reparable'; % 模拟的损失
% 载入结果
CovResultsDir = ".\results\Spatial Correlation";
CovFileName = "CovFunMat_"+"max_drift"+"_all";
load(fullfile(CovResultsDir,CovFileName),"CovFunMat");
IM_mat = IM_mat_Bld(i_bld,:);
Capacity3D_part = Capacity3D(i_bld);
% 三种情况：独立、完全相关、部分相关
[LossSim0,LossMat0,~] = SimulateRegionalLoss(IM_mat,SP_type,Capacity3D_part,CovFunMat,0);
[f_0,x_0] = ecdf(LossSim0);
[LossSim1,LossMat1,~] = SimulateRegionalLoss(IM_mat,SP_type,Capacity3D_part,CovFunMat,1);
[f_1,x_1] = ecdf(LossSim1);
[LossSim2,LossMat2,~] = SimulateRegionalLoss(IM_mat,SP_type,Capacity3D_part,CovFunMat,2);
[f_2,x_2] = ecdf(LossSim2);
% 模拟其他结果 (仅用来统计数据)
[~,CMat2] = SimulateRegionalLoss(IM_mat,'Collapse',Capacity3D_part,CovFunMat,2);
[~,IrMat2] = SimulateRegionalLoss(IM_mat,'Irreparable',Capacity3D_part,CovFunMat,2);
[~,RC_Struct_reparable_Mat2] = SimulateRegionalLoss( ...
    IM_mat,'RC_Struct_reparable',Capacity3D_part,CovFunMat,2);
[~,RC_NonStruct_reparable_Mat2] = SimulateRegionalLoss( ...
    IM_mat,'RC_NonStruct_reparable',Capacity3D_part,CovFunMat,2);

%% 绘图: 建筑EDP相关性绘图
EDP_type = 'PID';
plot_EDP_Blds(EDP_type,IM_mat,Capacity3D_part,CovFunMat);

%% 绘图: 建筑群损失柱状图
f = plot_loss_Bar(Capacity3D_part,SP_type,LossMat2,CMat2,IrMat2,false);
ylim([0,10]);

%% 绘图: 建筑群总损失累积分布函数
x_unit=10^6;
[f,ax,ax1] = Plot_Loss_CDF({x_0,x_1,x_2},{f_0,f_1,f_2},x_unit);
ax.YLim = [0.8,1];
ax.XLim = [0,150];
ax1.YLim = [0.95,0.98];
ax1.Position = [.26 .65 .25 .25];


