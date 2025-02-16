%% PEER地震波
dir_in = {'..\..\PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup0-40', ...
    '..\..\PEER NGA Data\PEERNGARecords_Unscaled_Northridge-01_Rrup40-200'};
dir_out = 'G:\震后损失评价相关性\Opensees FEM models\Northridge19940117';
OutputPeerGroundMotion(dir_in,dir_out);

%% 手动添加额外的地震波
% 输入
RSN = 829;
% x方向
ACC1 = NGA_no_829_RIO270;   %第一列为时间，第二列为g为单位的加速度
pSa1;                       %第一列周期，第二列为pSa
ACC1_name = "NGA_no_829_RIO270.txt";
pSa1_name = "pSa_NGA_no_829_RIO270.txt";
% y方向
ACC2 = NGA_no_829_RIO360; 
pSa2;
ACC2_name = "NGA_no_829_RIO360.txt";
pSa2_name = "pSa_NGA_no_829_RIO360.txt";

% 处理
PGA1 = max(abs(ACC1(:,2))); 
PGA2 = max(abs(ACC2(:,2)));
writematrix(ACC1,fullfile(dir_out,ACC1_name),'Delimiter',' '); 
writematrix(ACC2,fullfile(dir_out,ACC2_name),'Delimiter',' '); 
T = 0.02:0.02:20;
pSa1 = [T;interp1(pSa1(:,1),pSa1(:,2),T,'linear','extrap')];
pSa2 = [T;interp1(pSa2(:,1),pSa2(:,2),T,'linear','extrap')];
writematrix(pSa1,fullfile(dir_out,pSa1_name)); 
writematrix(pSa2,fullfile(dir_out,pSa2_name)); 
writematrix([RSN,ACC1_name,ACC2_name,PGA1,PGA2,pSa1_name,pSa2_name], ...
    fullfile(dir_out,'MetaData.txt'),'WriteMode','append'); 

