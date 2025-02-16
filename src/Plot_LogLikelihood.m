function Plot_LogLikelihood(listing,S0)
% 绘图：对比最大似然函数对数值

ColorPalette = [0.8500 0.3250 0.0980; ...
    0.4940 0.1840 0.5560; ...
    0.4660 0.6740 0.1880; ...
    0.9290 0.6940 0.1250; ...
    0.6350 0.0780 0.1840];

figure;

LogLikelihood = []; % 每一行 为一种台站选择
N_EQ_vec = [];
N_EQ_max = 128; % 注意手动输入

% N_case
S = load(fullfile(listing(1).folder,listing(1).name));
fields = fieldnames(S);
TF = contains(fields,'LogLikelihood');
N_case = sum(TF)-1;

for i=1:numel(listing)
    S = load(fullfile(listing(i).folder,listing(i).name));
    N_EQ = str2num(string(extractBetween(listing(i).name,"CovFunMat_Partial","_")));
    N_EQ_vec = [N_EQ_vec,N_EQ];
    ColLogLikelihood = [];
    for i_case = 1:N_case
        ColLogLikelihood = [ColLogLikelihood;getfield(S,['LogLikelihood',num2str(i_case)])];
    end
    LogLikelihood = [LogLikelihood, ColLogLikelihood];
end
N_EQ_vec = [N_EQ_vec,N_EQ_max];
LogLikelihood = [LogLikelihood,repmat(S0.LogLikelihood,N_case,1)];
b = bar(N_EQ_vec,LogLikelihood','FaceColor','flat');

for k = 1:size(LogLikelihood,1)
    b(k).CData = ColorPalette(k,:);
    b(k).XData = 1:numel(N_EQ_vec);
end

XTickLabel = string(N_EQ_vec);
XTickLabel(end) = strcat(XTickLabel(end),'(all)');
set(gca,'XTickLabel',XTickLabel);

set(gca,'units','centimeters','position',[5 5 8 6].*(1));
set(gca,'FontSize',12,'FontName','Calibri');
set(gcf,'units','normalized','position',[0.1 0.1 0.8 0.8]);


end