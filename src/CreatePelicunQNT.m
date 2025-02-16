function CreatePelicunQNT(Capacity3D_1,OutputFile,StructComponentsDir,StartOver)
% 创建pelicun所需要的构件数量文件

arguments   
    Capacity3D_1
    OutputFile
    StructComponentsDir
    StartOver logical = false % 不管OutputFile是否存在都重新生成
end

A = exist(OutputFile,"file");
if A && (~StartOver)
    return
end

BldName = Capacity3D_1.ModelName;

% 生成非结构构件数量
PyName = ".\src\3rd Party\NormQtyPact\NormQtyPact.py";
BatName = "RunThisPy.bat";
Story = sum(Capacity3D_1.PartStory);

% square meters to square feet
FloorAreaList = string(replace(num2str(cell2mat(Capacity3D_1.area).*10.764),regexpPattern('\s+'),','));
Occupancy1Type = strjoin(repmat("SCHOOLS",1,Story),',');
Occupancy2Type = strjoin(repmat("none",1,Story),',');
Occupancy3Type = strjoin(repmat("none",1,Story),',');
Occupancy1Area = strjoin(repmat("1",1,Story),',');
Occupancy2Area = strjoin(repmat("0",1,Story),',');
Occupancy3Area = strjoin(repmat("0",1,Story),',');
RunCondaPythonByBat(PyName,BatName,"--NumOfStories", Story,"--FloorAreaList", FloorAreaList, ...
    "--Occupancy1Type",Occupancy1Type,"--Occupancy2Type",Occupancy2Type,"--Occupancy3Type",Occupancy3Type, ...
    "--Occupancy1Area",Occupancy1Area,"--Occupancy2Area",Occupancy2Area,"--Occupancy3Area",Occupancy3Area);

% 读取非结构构件结果
T_2_cell = readcell(fullfile(dir(PyName).folder,"PelucunComponentDirectory.csv"));
T_2 = cell2table(T_2_cell(2:end,:),'VariableNames',T_2_cell(1,:));
T_2 = convertvars(T_2,{'Location','Direction'},'string');

% 读取结构构件数据
listing = dir(fullfile(StructComponentsDir,BldName+"*.xlsx"));
T_1_cell = readcell(fullfile(listing.folder,listing.name));
T_1 = cell2table(T_1_cell(2:end,:),'VariableNames',T_1_cell(1,:));
T_1 = convertvars(T_1,{'Location','Direction'},'string');
% 如果Theta_0列有不是单个数值，那么把Location和Theta_0配对拆分
T_1_new = table;
for i=1:height(T_1)
    if ~isfloat(T_1{i,'Theta_0'})
        Theta_0 = T_1{i,'Theta_0'};
        Theta_0 = double(strsplit(string(Theta_0{1}),','));
        Loc = T_1{i,'Location'};
        Loc = strsplit(Loc,',');
        T_temp = repmat(T_1(i,:),numel(Loc),1);
        T_temp{:,'Location'} = Loc';
        T_temp.Theta_0 = Theta_0';
        T_1_new = cat(1,T_1_new,T_temp);
    else
        T_1_new = cat(1,T_1_new,T_1(i,:));
    end
end
T_1 = T_1_new;

% 合并结构构件数量数据
T = cat(1,T_1,T_2);
T{:,'Blocks'} = missing; % 不要blocks列，不然pelicun出bug


% 相加其中重复的
ColValSum = {'Theta_0'};
ColNameUniq = {'ID','Location','Direction'};
[~,ia,~] = unique(T(:,ColNameUniq));
T_uniq = T(ia,:);
for i=1:height(T_uniq)
    Lia = ismember(T(:,ColNameUniq),T_uniq(i,ColNameUniq));
    if sum(Lia)~=1
        T_uniq{i,ColValSum} = sum(T{Lia,ColValSum},1);
    end
end
T = T_uniq;

% 输出
[filepath,~,~] = fileparts(OutputFile);
status = mkdir(filepath);
writetable(T,OutputFile);

end

