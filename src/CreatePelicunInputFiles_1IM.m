function OutputFile = CreatePelicunInputFiles_1IM(OutputDir,InputJsonTemplate,Capacity3D_1,suffix)
% 生成Pelicun input.json文件
% 其中, EDP文件名为sprintf("demands_%s.csv",suffix), 构件数量文件名为sprintf('QNT_%s.csv',suffix)
% 
% Returns:
% OutputFile - 输出文件

arguments
    OutputDir string
    InputJsonTemplate
    Capacity3D_1
    suffix string = ""
end

jsonStr = fileread(InputJsonTemplate);
jsonData = jsondecode(jsonStr);

% 修改数据
jsonData.DL.Asset.ComponentAssignmentFile = sprintf('QNT%s.csv',suffix);
jsonData.DL.Asset.NumberOfStories = num2str(sum(Capacity3D_1.PartStory));
jsonData.DL.Asset.OccupancyType = "EDU2";
area = 0;
for i_part = 1:numel(Capacity3D_1.area)
    area = area+Capacity3D_1.area{i_part}(1);
end
jsonData.DL.Asset.PlanArea = num2str(area);
jsonData.DL.Damage.CollapseFragility.CapacityMedian = ...
    num2str(Capacity3D_1.medianSa*9.8,'%.2f');
jsonData.DL.Damage.CollapseFragility.DemandType = strcat("SA_",num2str(Capacity3D_1.T,'%.2f')); % SA_周期
jsonData.DL.Damage.CollapseFragility.Theta_1 = num2str(Capacity3D_1.sigmalnSa,'%.2f');
jsonData.DL.Demands.DemandFilePath = sprintf("demands%s.csv",suffix);
jsonData.DL.Demands.SampleSize = "10000"; % 模拟次数
% 重建费用都设置得非常大，即不考虑倒塌的情况
jsonData.DL.Losses.BldgRepair.ReplacementCost.Median = num2str(100000000,'%.1f');
jsonData.DL.Losses.BldgRepair.ReplacementTime.Median = num2str(10000,'%.1f');

% 写入
OutputFile = fullfile(OutputDir,sprintf("input%s.json",suffix));
fid = fopen(OutputFile,'w');
fwrite(fid,jsonencode(jsonData,"PrettyPrint",true),'char');
fclose(fid);

end