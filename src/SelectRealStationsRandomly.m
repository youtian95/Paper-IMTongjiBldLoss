% 每个选中的网格中 [ix_samples,iy_samples] 随机抽选一个台站
function ind = SelectRealStationsRandomly(i_x,i_y,ix_samples,iy_samples)

ind = zeros(1,numel(ix_samples));
for i=1:numel(ix_samples)
    Nlist = 1:numel(i_x); % 所有台站索引
    Nlist = Nlist(i_x==ix_samples(i) & i_y==iy_samples(i)); % 网格中台站索引
    ii = randi(numel(Nlist));
    ind(i) = Nlist(ii);
end

end