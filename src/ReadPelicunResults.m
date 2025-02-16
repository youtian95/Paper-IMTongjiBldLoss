function Capacity3D = ReadPelicunResults(Capacity3D, ResultDir)
% 读取地震损失分析结果
% 包括：
%   RC,RT,RC_Struct,RC_NonStruct,PID,PFA - (i_Sim,i_IM)
%   Collapse - (i_Sim,i_IM)
%   Irreparable -(i_Sim,i_IM)
%   RC_reparable,RT_reparable - {i_IM}(i_Sim) 可修情况下的RC,RT
%   RC_Struct_reparable,RC_NonStruct_reparable - {i_IM}(i_Sim) 可修情况下结构构件的RC
%   MeanRC_Struct, MeanRC_NonStruct - (i_IM) 可修情况下的结构、非结构构件平均损失
%   IMListForLoss - (i_IM)

for i_bld = 1:numel(Capacity3D)
    BldName = Capacity3D(i_bld).ModelName;
    [RT,RC,PID,PFA,RC_Struct,RC_NonStruct,C,Ir,IMList] = Read_RTRC_Sim_From_PelicunDir( ...
        fullfile(ResultDir,BldName));
    Capacity3D(i_bld).RT = RT';
    Capacity3D(i_bld).RC = RC';
    Capacity3D(i_bld).PID = PID';
    Capacity3D(i_bld).PFA = PFA';
    Capacity3D(i_bld).RC_Struct = RC_Struct';
    Capacity3D(i_bld).RC_NonStruct = RC_NonStruct';
    Capacity3D(i_bld).Collapse = C';
    Capacity3D(i_bld).Irreparable = Ir';
    Capacity3D(i_bld).IMListForLoss = IMList;
    % 可修情况下
    RC_reparable = {}; RT_reparable = {}; 
    RC_Struct_reparable = {}; RC_NonStruct_reparable = {};
    for i_IM = 1:size(Capacity3D(i_bld).RC,2)
         RCSim = Capacity3D(i_bld).RC(:,i_IM);
         RC_Struct_Sim = Capacity3D(i_bld).RC_Struct(:,i_IM);
         RC_NonStruct_Sim = Capacity3D(i_bld).RC_NonStruct(:,i_IM);
         RTSim = Capacity3D(i_bld).RT(:,i_IM);
         i_repair = ~(Capacity3D(i_bld).Collapse(:,i_IM) | ...
             Capacity3D(i_bld).Irreparable(:,i_IM));
         RC_reparable{i_IM} = RCSim(i_repair);
         RC_Struct_reparable{i_IM} = RC_Struct_Sim(i_repair);
         RC_NonStruct_reparable{i_IM} = RC_NonStruct_Sim(i_repair);
         RT_reparable{i_IM} = RTSim(i_repair);
    end
    Capacity3D(i_bld).RC_reparable = RC_reparable;
    Capacity3D(i_bld).RC_Struct_reparable = RC_Struct_reparable;
    Capacity3D(i_bld).RC_NonStruct_reparable = RC_NonStruct_reparable;
    Capacity3D(i_bld).RT_reparable = RT_reparable;
end

end