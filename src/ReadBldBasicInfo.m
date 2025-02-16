function Capacity3D_new = ReadBldBasicInfo(infodir,Capacity3D)

Capacity3D_new = [];
for i=1:numel(Capacity3D)
    Capacity3D_1 = Capacity3D(i);
    BldName = Capacity3D_1.ModelName;
    T = readtable(fullfile(infodir,strcat(BldName,'建筑基本信息.xlsx')), ...
        'VariableNamingRule','preserve', ...
        "Range", strcat("1:",num2str(numel(Capacity3D_1.PartName)+1)));
    % 读取面积
    area = {};
    for i_part = 1:numel(Capacity3D_1.PartName)
        N_story = T{i_part,'层数'};
        area1part = T{i_part, contains(T.Properties.VariableNames,'建筑各层的平面面积')};
        area1part = replace(area1part,'，',',');
        area1part = eval(area1part{1});
        if numel(area1part)==1
            area{i_part} = ones(1,N_story).*area1part;
        elseif numel(area1part)==N_story
            area{i_part} = area1part;
        else
            error('错误: 层数与面积数量不相符');
        end
    end
    Capacity3D_1.area = area;
    % 读取周期
    Capacity3D_1.T1 = T{1,"T1"};
    Capacity3D_1.T2 = T{1,"T2"};
    Capacity3D_1.T = sqrt(Capacity3D_1.T1*Capacity3D_1.T2);

    Capacity3D_new = [Capacity3D_new,Capacity3D_1];
end

end