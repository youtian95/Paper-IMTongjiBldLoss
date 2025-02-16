BldName = 'MRF9';

Dir = ['Opensees FEM models\',BldName,'\ExampleOutput'];
if strcmp(BldName(end),'3')
    BaseGravity = (65.53*2+70.90)/2*14.59*1000*9.8;
elseif strcmp(BldName(end),'9')
    BaseGravity = (67.86*7+69.04+73.10)/2*14.59*1000*9.8;
end
Plot_pushover(Dir,BaseGravity);