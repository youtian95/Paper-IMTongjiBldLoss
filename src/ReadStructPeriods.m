function  T = ReadStructPeriods(BldName,N)
% DirModel - 模型名字
% N - 前几阶周期

Listing = dir(['Opensees FEM models\',BldName,'\modesPeriods*.txt']);
Tfile = readmatrix(fullfile(Listing.folder,Listing.name)); 
T = Tfile(1:N);

end