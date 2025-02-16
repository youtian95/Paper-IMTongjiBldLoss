function [B,d,V] = ConvertSymmetricalMatrixtoSemiPositive( ...
    A,delta)
% 将对称矩阵转换为半正定
%
% 输入：
% A - 对称矩阵
% delta - 最小特征值
% 
% 输出：
% d - 特征值向量
% V - 特征向量矩阵 B*V = V*diag(d);

assert(issymmetric(A));

% 特征值分解
[V,D] = eig(A);
d = diag(D);

% 测试是否为正定
% (1) 方法
if all(d>delta)
    B = A;
else
    warning('Matrix is not symmetric positive definite');
    d = max(d,delta);
    B = V*diag(d)*V';
    B = (B + B')./2;
end
% (2) 方法
% try L = chol(A);
%     B = A;
% catch ME
%     disp('Warning: Matrix is not symmetric positive definite');
%     d = max(d,delta);
%     B = V*diag(d)*V';
%     B = (B + B')/2;
% end



end

