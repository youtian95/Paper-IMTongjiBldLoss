function ind = FindStationSet_SpatialSampling(EQDataStruct,RSNAll,N_EQ,method)
% 平面空间中随机抽样
% 
% 输入：
% EQDataStruct - 所有台站数据
% RSNAll - 仅适用这些编号的数据 - 行向量
% N_EQ - 抽样数量
% method - 抽样方法 - 'Simple', 'Halton'

RSNvec = [EQDataStruct.RecordSequenceNumber];

[row,~] = find((RSNvec==RSNAll')');
lng = [EQDataStruct(row).StationLongitude];
lat = [EQDataStruct(row).StationLatitude];

% 平面坐标系
[x,y] = LngLat2webMercator(lng,lat);
[X,Y] = webMercator2xy(x,y);
X = X./1000; %km
Y = Y./1000; %km

% 网格
Len1 = 15; % km
[i_x,i_y,Bound_Left,Bound_down,Num_x,Num_y] = CreateSquareGrid(X,Y,Len1);

% 网格抽样
if strcmp(method,'Simple')
    [ix_samples,iy_samples] = SimpleRandom2D(Num_x,Num_y,N_EQ,i_x,i_y);
elseif strcmp(method,'Halton')
    [ix_samples,iy_samples] = HaltonSample2D(Num_x,Num_y,N_EQ,i_x,i_y);
end

% 每个选中的网格中 [ix_samples,iy_samples] 随机抽选一个台站
ind = SelectRealStationsRandomly(i_x,i_y,ix_samples,iy_samples);

figure;
hold on
scatter(X,Y,'.'); 
scatter(X(ind),Y(ind),'o'); 
daspect([1 1 1]);
box on
grid on
set(gca,'Xtick',Bound_Left:Len1:(Bound_Left+Len1*Num_x));
set(gca,'Ytick',Bound_down:Len1:(Bound_down+Len1*Num_y));
ax = gca;
ax.XTick = round(ax.XTick,1);
ax.YTick = round(ax.YTick,1);
xlabel('X (km)');
ylabel('Y (km)');
% xlim([Bound_Left, Bound_Left+Len1*Num_x]);
% ylim([Bound_down, Bound_down+Len1*Num_y]);


end


