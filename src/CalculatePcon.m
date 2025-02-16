function Pcon = CalculatePcon(Capacity3D_1)
% 计算各个IM下的离散倒塌比例
% 倒塌的判定为超过倒塌层间位移角或者有限元分析不收敛

d = Capacity3D_1.IDA_Max_Drift; % (i_EQ, i_IM)

N_eq = size(d,1);

collapse = (d>Capacity3D_1.Collapse_Drift) | ...
    (Capacity3D_1.AnalysisTime./Capacity3D_1.RecordDuration<0.7);

Pcon = sum(collapse,1)./N_eq;

end