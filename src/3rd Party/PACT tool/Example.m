%% P(x) RC RT
[P_RT,P_RC] = ECDF_of_RTRC_From_PactDir( ...
    'G:\震后损失评价相关性\损失分析\MRF3 results',100);
P_RTRC = {P_RT,P_RC};
for i_RTRC = 1:2
    P = P_RTRC{i_RTRC};
    figure;
    hold on;
    for i_IM = 1:size(P,3)
        plot(P(1,:,i_IM),P(2,:,i_IM));
    end
end
