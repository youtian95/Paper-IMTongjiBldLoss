function Plot_StationMap(EQDataStruct, EQName, RSN_Filter, SelectRSN)
% 台站位置绘图, 默认绘制PGA>=0.05g且地震动时程存在的台站
% 
% 输入：
% EQDataStruct - 地震动数据
% EQName - 历史地震名字，'Northridge'/'Chi-Chi'
% RSN_Filter - 逻辑向量，可选
% SelectRSN - 选中的RSN，行向量/矩阵，可选

ColorPallete = [0.8500 0.3250 0.0980; ...
    0.4940 0.1840 0.5560; ...
    0.4660 0.6740 0.1880; ...
    0.9290 0.6940 0.1250; ...
    0.6350 0.0780 0.1840];

if nargin<3
    % 排除无地震动数据的, 只使用部分满足要求的台站地震动
    RSN_Filter = [EQDataStruct.AccHistoryFileExist] ...
        & ([EQDataStruct.PGA_g_]>=0.05); % PGA大于0.05g
end

CircleSizelist = 20:30:140;

% 底图信息
if contains(EQName,'Northridge')
    % Northridge 
    EpiLat = 34.213; EpiLong = -118.537;     
    left_long = -121; right_long = -116; 
    down_lat = 33; up_lat = 36;
    imagefile = '.\Figures\Northridge.png'; % 底图
elseif contains(EQName,'Chi-Chi')
    % Chi-Chi 
    EpiLat = 23.85; EpiLong = 120.82;     
    left_long = 119; right_long = 123; 
    down_lat = 21; up_lat = 26;
    imagefile = '.\Figures\Chi-Chi.png'; % 底图
end
% 绘图
Plot_Scenario(imagefile,0.5,left_long,right_long,down_lat,up_lat, ...
    EQDataStruct,EpiLat,EpiLong,RSN_Filter);

% 选中的台站位置
if nargin>3
    s = [];
    for i_part=1:size(SelectRSN,1)
        RSNall = [EQDataStruct.RecordSequenceNumber];
        bool_ind = SelectRSN(i_part,:)' == RSNall;
        StatLat = [];
        StatLong = [];
        for i=1:size(SelectRSN,2)
            StatLat = [StatLat,EQDataStruct(bool_ind(i,:)).StationLatitude];
            StatLong = [StatLong,EQDataStruct(bool_ind(i,:)).StationLongitude];
        end
        s1 = scatter(StatLong,StatLat);
        s = [s,s1];
        s1.MarkerFaceColor = 'none';
        s1.Marker = 'o';
        s1.LineWidth = 1;
        hLegend = findobj(gcf, 'Type', 'Legend');
        hLegend.String{2+i_part} = ['Set ',num2str(i_part),' (',num2str(size(SelectRSN,2)),')'];
        s(i_part).SizeData = CircleSizelist(i_part);
        s(i_part).MarkerEdgeColor = ColorPallete(i_part,:);
    end
end


% 绘图范围
if strcmp(EQName,'Northridge')
    xlim([-120,-116.5]);
    ylim([33.5,35]);
elseif strcmp(EQName,'Chi-Chi')
end

set(gca,'units','centimeters','position',[5 5 8 6].*(16/8));

end