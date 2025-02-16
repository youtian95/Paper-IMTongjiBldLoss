function [IDA_drift,IDA_accel,IDA_vel,PGA,PGV,RDrift,RecordDuration,AnalysisTime, ...
    N_story,N_EQ,EQName] = Read1SheetEDP(FilePath,SheetName)
%       RecordDuration (double[i_EQ,i_IM]): 地震波输入时间
%       AnalysisTime (double[i_EQ,i_IM]): 实际分析结束时间
%       IDA_drift(i_EQ,i_IM,i_XorY,i_story)
%       RDrift(i_EQ,i_IM,i_XorY,i_story)
%       IDA_accel(i_EQ,i_IM,i_XorY,i_story)
%       IDA_vel(i_EQ,i_IM,i_XorY,i_story)
%       IDA_Max_Drift(i_EQ,i_IM) : 两个方向、各层中最大的层间位移角
%       PGA(i_EQ,i_IM,i_XorY)
%       PGV(i_EQ,i_IM,i_XorY)
%       EQName(i_EQ)

arguments
    FilePath string
    SheetName = 1
end

i_IM = 1;

T = readtable(FilePath, 'VariableNamingRule', 'preserve', ...
    'EmptyRowRule','skip', 'Sheet', SheetName);

% EQ和层数
% EQ列
ColEQ = regexp(string(T.Properties.VariableNames),"^\D+(\d+)$",'match');
ColEQ = ~cellfun(@isempty,ColEQ);
N_EQ = sum(ColEQ);
EQName = regexp(string(T.Properties.VariableNames), ...
    '^\D+(\d+)$','tokens','forceCellOutput','once');
EQName = EQName(ColEQ);
EQName = double(string(EQName));
row_IDR_X = find(contains(T{:,'EDP'},'IDR_X'),1);
row_IDR_Y = find(contains(T{:,'EDP'},'IDR_Y'),1);
if any(matches(T.Properties.VariableNames,'楼层数'))
    N_story = max(T{row_IDR_X:(row_IDR_Y-1),'楼层数'});
elseif any(matches(T.Properties.VariableNames,'层号'))
    N_story = max(T{:,'层号'});
end

% 读取EDP
for i_story = 1:N_story
    for i_XorY = 1:2
        XorY = ["X","Y"];
        % IDA_drift
        k = find(contains(T{:,"EDP"},strcat("IDR_",XorY(i_XorY))),1);
        IDA_drift(:,i_IM,i_XorY,i_story) = T{k+i_story-1,ColEQ};
        IDA_drift = abs(IDA_drift);
        % IDA_accel
        k = find(contains(T{:,"EDP"},strcat("Accel_",XorY(i_XorY))),1);
        IDA_accel(:,i_IM,i_XorY,i_story) = T{k+i_story,ColEQ};
        IDA_accel = abs(IDA_accel);
        % IDA_vel
        k = find(contains(T{:,"EDP"},strcat("Vel_",XorY(i_XorY))),1);
        IDA_vel(:,i_IM,i_XorY,i_story) = T{k+i_story,ColEQ};
        IDA_vel = abs(IDA_vel);
        % PGA
        k = find(contains(T{:,"EDP"},strcat("Accel_",XorY(i_XorY))),1);
        PGA(:,i_IM,i_XorY) = T{k,ColEQ};
        PGA = abs(PGA);
        % PGV
        k = find(contains(T{:,"EDP"},strcat("Vel_",XorY(i_XorY))),1);
        PGV(:,i_IM,i_XorY) = T{k,ColEQ};
        PGV = abs(PGV);
        % RDrift (i_EQ,i_IM,i_XorY,i_story)
        k = find(contains(T{:,"EDP"},strcat("RIDR_",XorY(i_XorY))),1);
        RDrift(:,i_IM,i_XorY,i_story) = T{k+i_story-1,ColEQ};
        RDrift = abs(RDrift);
        % RecordDuration (i_EQ,i_IM)
        k = find(contains(T{:,"EDP"},"预设分析时间"));
        RecordDuration(:,i_IM) = T{k,ColEQ};
        % AnalysisTime (i_EQ,i_IM)
        k = find(contains(T{:,"EDP"},"实际分析时间"));
        AnalysisTime(:,i_IM) = T{k,ColEQ};
    end
end


% 处理有限元分析中的异常值
for edp_name = ["IDA_drift","IDA_accel","IDA_vel","RDrift"] % (i_EQ,i_IM,i_XorY,i_story)
    edp = eval(edp_name);
    iffinish = (AnalysisTime./RecordDuration>=0.7);
    % 当数值为inf，但是有限元完成了，那么inf数值赋值为其他正常值的平均值
    IND = isinf(edp) & iffinish;
    if any(IND,'all')
        for i_XorY = 1:2
            for i_story = 1:N_story
                edp(IND(:,i_IM,i_XorY,i_story),i_IM,i_XorY,i_story) = ...
                    mean(edp(~IND(:,i_IM,i_XorY,i_story),i_IM,i_XorY,i_story));
            end
        end
    end
    eval(edp_name+"=edp;");
end

end