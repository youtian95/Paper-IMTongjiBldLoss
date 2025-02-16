function CreatePactEDPfile(filename,IMList, ...
    Drift,Acc,Vel,ResidualDrift,PGA,PGV, ...
    SHC, T, ...
    EDPoutputType)
% 生成PACT需要的EDP .csv文件
%
% 输入：
% filename - 输出的文件名
% IMList - 要分析的IM向量
% Drift,Acc,Vel,ResidualDrift,PGA,PGV - (单位 g, m/s)
%       Drift{i_IM}{i_EQ}(i_dir,i_floor)，Acc，Vel，
%       PGV{i_IM}{i_EQ}(i_dir,1)，ResidualDrift{i_IM}{i_EQ}(1,1)
% SHC - SHC(Sa,T), lamda(Sa)函数，在SHC.m文件中定义
% T -结构周期
% EDPoutputType - 输出到文件的EDP类型, [1,1,1]表示Drift,Acc,Vel三种全部输出
%
% 备注：
% 每个烈度下的地震波数量相同

fileID = fopen(filename,'w');

% 第一块，危险性曲线
fprintf(fileID, 'Non-Linear\n');
fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s\n', ...
    'Intensity #','Name','# Demand Vectors','Modeling Dispersion', ...
    'SA(T)','SA(T1)','MAFE');
for i=1:numel(IMList)
    fprintf(fileID,'%i,%s,%i,%g,%g,%g,%g\n', ...
        i,['Intensity ',num2str(i)],numel(Drift{i}),0, ...
        IMList(i),0.4,SHC(IMList(i),T));
end
fprintf(fileID,'\n');

% 第二块，EDP输入
fprintf(fileID,'%s,%s,%s,%s','Intensity #','Demand Type','Floor','Dir');
for i=1:numel(Drift{1})
    fprintf(fileID,',%s',['EQ',num2str(i)]);
end
fprintf(fileID,'\n');
for i=1:numel(IMList)
    % 层间位移角
    if EDPoutputType(1)
        for i_floor=1:size(Drift{1}{1},2)
            for i_dir=1:2
                fprintf(fileID,'%i,%s',i,'Story Drift Ratio');
                fprintf(fileID,',%i,%i',i_floor,i_dir);
                for i_EQ=1:numel(Drift{i})
                    fprintf(fileID,',%g',Drift{i}{i_EQ}(i_dir,i_floor));
                end
                fprintf(fileID,'\n');
            end
        end
    end
    if EDPoutputType(2)
        % PGA
        for i_dir=1:2
            fprintf(fileID,'%i,%s',i,'Acceleration');
            fprintf(fileID,',%i,%i',1,i_dir);
            for i_EQ=1:numel(PGA{i})
                fprintf(fileID,',%g',PGA{i}{i_EQ}(i_dir,1));
            end
            fprintf(fileID,'\n');
        end
        % 加速度
        for i_floor=1:size(Acc{1}{1},2)
            for i_dir=1:2
                fprintf(fileID,'%i,%s',i,'Acceleration');
                fprintf(fileID,',%i,%i',i_floor+1,i_dir);
                for i_EQ=1:numel(Acc{i})
                    fprintf(fileID,',%g',Acc{i}{i_EQ}(i_dir,i_floor));
                end
                fprintf(fileID,'\n');
            end
        end
    end
    if EDPoutputType(3)
        % PGV
        for i_dir=1:2
            fprintf(fileID,'%i,%s',i,'Peak Floor Velocity');
            fprintf(fileID,',%i,%i',1,i_dir);
            for i_EQ=1:numel(PGV{i})
                fprintf(fileID,',%g',PGV{i}{i_EQ}(i_dir,1));
            end
            fprintf(fileID,'\n');
        end
        % 速度
        for i_floor=1:size(Vel{1}{1},2)
            for i_dir=1:2
                fprintf(fileID,'%i,%s',i,'Peak Floor Velocity');
                fprintf(fileID,',%i,%i',i_floor+1,i_dir);
                for i_EQ=1:numel(Vel{i})
                    fprintf(fileID,',%g',Vel{i}{i_EQ}(i_dir,i_floor));
                end
                fprintf(fileID,'\n');
            end
        end
    end
    % 残余位移角
    fprintf(fileID,'%i,%s',i,'Residual Drift');
    fprintf(fileID,',,');
    for i_EQ=1:numel(ResidualDrift{i})
        fprintf(fileID,',%g',ResidualDrift{i}{i_EQ}(1,1));
    end
    fprintf(fileID,'\n');
end

fclose(fileID);

end

