function CreatePelicunEDPfile_1IM(Capacity3D_1,i_IM,filepath)
% Capacity3D_1中加速度单位为g, 速度单位为m/s; 输出文件单位为 m, s, N

IM = Capacity3D_1.IMList(i_IM);

IfFinish = (Capacity3D_1.AnalysisTime./Capacity3D_1.RecordDuration >0.9); % (i_EQ,i_IM)
FinishEQind = IfFinish(:,i_IM);

IDA_drift = Capacity3D_1.IDA_drift;  
IDA_drift = IDA_drift(FinishEQind,:,:,:);
IDA_accel = Capacity3D_1.IDA_accel;
IDA_accel = IDA_accel(FinishEQind,:,:,:);
IDA_accel = IDA_accel.*9.81;
PGA = Capacity3D_1.PGA; % (i_EQ,i_IM,i_XorY)
PGA = PGA(FinishEQind,:,:,:);
PGA = PGA.*9.81;
RDrift = Capacity3D_1.RDrift; % (i_EQ,i_IM)
RDrift = RDrift(FinishEQind,:);

N_story = size(IDA_drift,4);
N_Dim = size(IDA_drift,3);
N_EQ = sum(FinishEQind);

% 数据
T = [];
VariableNames = {};
% PGA
for i_XorY = 1:N_Dim
    VariableNames = [VariableNames,sprintf("1-PFA-%i-%i",0,i_XorY)];
    T = [T,PGA(:,i_IM,i_XorY)];
end
% PFA
for i_story = 1:1:N_story
    for i_XorY = 1:N_Dim
        VariableNames = [VariableNames,sprintf("1-PFA-%i-%i",i_story,i_XorY)];
        T = [T,IDA_accel(:,i_IM,i_XorY,i_story)];
    end
end
% PID
for i_story = 1:1:N_story
    for i_XorY = 1:N_Dim
        VariableNames = [VariableNames,sprintf("1-PID-%i-%i",i_story,i_XorY)];
        T = [T,IDA_drift(:,i_IM,i_XorY,i_story)];
    end
end
% RID
VariableNames = [VariableNames,sprintf("1-RID-%i-%i",1,1)];
T = [T,RDrift(:,i_IM)];
% SA, 是用来估计倒塌概率的
VariableNames = [VariableNames,sprintf("1-SA_%.2f-0-1",Capacity3D_1.T)];
T = [T, IM*9.81.*ones(height(T),1)];

% 输出文件
T_table = array2table(T,"VariableNames",VariableNames,"RowNames",string(0:1:(N_EQ-1)));
writetable(T_table,filepath,"WriteRowNames",true);

end