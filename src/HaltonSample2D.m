function [ix_samples,iy_samples] = HaltonSample2D(Num_x,Num_y,N,i_x,i_y)
% 根据Halton序列随机抽样2D 
% 
% [1] B L Robertson, J A Brown, T McDonald, P Jaksons. BAS: Balanced
% Acceptance Sampling of Natural Resources. Biometrics, 2013, 69(3):
% 776-784.
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

p = haltonset(2);
head_halton = 2;
X0 = net(p,N*2);

i=0;
while i<N
    if head_halton>size(X0,1)
        X0 = net(p,head_halton*2);
    end
    x = X0(head_halton,1);
    y = X0(head_halton,2);
    ix = floor(Num_x*x);
    iy = floor(Num_y*y);
    if any(ix==i_x & iy==i_y) && (~any(ix==ix_samples & iy==iy_samples)) % 不重复
        i = i+1;
        ix_samples(i) = ix;
        iy_samples(i) = iy;
    end
    head_halton = head_halton+1;
end

end