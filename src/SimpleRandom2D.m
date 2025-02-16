function [ix_samples,iy_samples] = SimpleRandom2D(Num_x,Num_y,N,i_x,i_y)
% 简单随机抽样2D
% 
% 输入：
% Num_x,Num_y - 网格数量
% N - 抽样数量
% i_x,i_y - 可以抽样的索引向量，可能重复
% 
% 输出：
% ix_samples,iy_samples - 抽样得到的索引

ix_samples = zeros(1,N);
iy_samples = zeros(1,N);

i=0;
while i<N
    ix = randi(Num_x);
    iy = randi(Num_y);
    if any(ix==i_x & iy==i_y) && (~any(ix==ix_samples & iy==iy_samples)) % 不重复
        i = i+1;
        ix_samples(i) = ix;
        iy_samples(i) = iy;
    end
end

end