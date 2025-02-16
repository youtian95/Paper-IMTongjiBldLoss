function OutputPeerGroundMotion(dir_in_cell,dir_out,RSN_Filter)
% 将PEER地震动数据输出为两列的数据
%
% 输入：
% dir_in_cell - 输入文件夹，可以有多个文件夹，但每个文件夹地震波数据不能重复，
%       每个文件夹有PEER每条地震波的时程数据 + '_SearchResults.csv' 文件
% dir_out - 输出文件夹, 单位为g
%
% 可选输入：
% RSN_Filter - 数值向量, 根据RSN编号过滤其他的数据
%
% 输出：
% 在输出文件夹中生成
% （1）MetaData.txt文件，每行为一组地震波的数据，依次为
% RSN编号, Horizontal-1 Acc. Filename, Horizontal-2 Acc. Filename, 
% Horizontal-1 PGA, Horizontal-2 PGA, Horizontal-1 pSa Filename, 
% Horizontal-2 pSa Filename；
% （2）每组地震波的时程曲线txt文件（两个水平方向），文件名与MetaData.txt中相同；
% （3）每组地震波的谱加速度txt文件（两个水平方向），文件名为MetaData.txt中相同，
% 每个pSa文件中有两行，第一行为周期T(s)共1000列，0.02:0.02:20；第二行为对应的
% 谱加速度，单位为g

for i_dir=1:numel(dir_in_cell)
    dir_in = dir_in_cell{i_dir}; 

    % 检查
    if exist(fullfile(dir_in,'_SearchResults.csv'),'file')~=2
        error('_SearchResults.csv文件不存在');
        return;
    end
    if exist(dir_out,'dir')~=7
        status = mkdir(dir_out);
    end

    % 反应谱数据行数
    row_pSa = [];
    temp = readcell(fullfile(dir_in,'_SearchResults.csv'));
    for i=1:size(temp,1)
        if strcmp(temp{i,1},'-- Unscaled Horizontal & Vertical Spectra')
            row_pSa = (i+2):(i+112);
            break;
        end
    end

    % 文件名数据行数
    row_meta = [];
    row_meta_1 = 0;
    row_meta_2 = 0;
    for i=1:size(temp,1)
        if strcmp(temp{i,1},'-- Summary of Metadata of Selected Records --')
            row_meta_1 = i+2;
            continue;
        end
        if strcmp(temp{i,1}, ...
                'These records were obtained from the NGA-West2 On-Line Ground-Motion Database Tool')
            row_meta_2 = i-1;
            continue;
        end
    end
    row_meta = row_meta_1:row_meta_2;

    % RSN
    RSN = [temp{row_meta,3}]';

    % Horizontal-1 Acc. Filename, Horizontal-2 Acc. Filename
    % Horizontal-1 pSa Filename, Horizontal-2 pSa Filename
    Horizontal1AccFilename = [];
    Horizontal2AccFilename = [];
    Horizontal1pSaFilename = [];
    Horizontal2pSaFilename = [];
    for i=row_meta
        Horizontal1AccFilename = [Horizontal1AccFilename;string(temp{i,20})];
        Horizontal2AccFilename = [Horizontal2AccFilename;string(temp{i,21})];
        Horizontal1pSaFilename = [Horizontal1pSaFilename;string(['pSa_',temp{i,20}])];
        Horizontal2pSaFilename = [Horizontal2pSaFilename;string(['pSa_',temp{i,21}])];
    end
    Horizontal1pSaFilename = replace(Horizontal1pSaFilename,".AT2",".txt");
    Horizontal2pSaFilename = replace(Horizontal2pSaFilename,".AT2",".txt");


    % 逐个读取时程曲线
    Horizontal1PGA=[];
    Horizontal2PGA=[];
    for i=1:size(row_meta,2)
        % 1
        AccHist1 = readmatrix(fullfile(dir_in,Horizontal1AccFilename(i,1)), ...
            'FileType','text','Range',5);
        AccHist1 = reshape(AccHist1',[],1);
        AccHist1 = rmmissing(AccHist1);
        dt1 = readmatrix(fullfile(dir_in,Horizontal1AccFilename(i,1)), ...
            'FileType','text','Range','4:4','TrimNonNumeric',true, ...
            'ExpectedNumVariables',2,'Delimiter',',');
        if size(AccHist1,1)~=dt1(1)
            error('提取时程数据错误');
            return;
        end
        dt1 = dt1(2);
        ts1 = 0:dt1:(dt1*(size(AccHist1,1)-1));
        % 2
        AccHist2 = readmatrix(fullfile(dir_in,Horizontal2AccFilename(i,1)), ...
            'FileType','text','Range',5);
        AccHist2 = reshape(AccHist2',[],1);
        AccHist2 = rmmissing(AccHist2);
        dt2 = readmatrix(fullfile(dir_in,Horizontal2AccFilename(i,1)), ...
            'FileType','text','Range','4:4','TrimNonNumeric',true, ...
            'ExpectedNumVariables',2,'Delimiter',',');
        if size(AccHist2,1)~=dt2(1)
            error('提取时程数据错误');
            return;
        end
        dt2 = dt2(2);
        ts2 = 0:dt2:(dt2*(size(AccHist2,1)-1));
        % （2）每组地震波的时程曲线txt文件（两个水平方向）
        writematrix([(ts1)',AccHist1],fullfile(dir_out, ...
            replace(Horizontal1AccFilename(i,1),".AT2",".txt")), ...
            'Delimiter',' ');
        writematrix([(ts2)',AccHist2],fullfile(dir_out, ...
            replace(Horizontal2AccFilename(i,1),".AT2",".txt")), ...
            'Delimiter',' ');
        % Horizontal-1 PGA, Horizontal-2 PGA
        Horizontal1PGA = [Horizontal1PGA;max(abs(AccHist1))];
        Horizontal2PGA = [Horizontal2PGA;max(abs(AccHist2))];
    end

    % （1）MetaData.txt文件
    writematrix([RSN, replace(Horizontal1AccFilename,".AT2",".txt"), ...
        replace(Horizontal2AccFilename,".AT2",".txt"), ...
        Horizontal1PGA, Horizontal2PGA, Horizontal1pSaFilename, Horizontal2pSaFilename], ...
        fullfile(dir_out,['MetaData',num2str(i_dir),'.txt']),'Delimiter',',');

    % （3）每组地震波的谱加速度txt文件（两个水平方向）
    T_in = [temp{row_pSa,1}];
    for i=1:size(row_meta,2)
        for j=1:2
            Sa = [temp{row_pSa,(i-1)*3+j+1}];
            T_out = 0.02:0.02:20;
            Sa_out = interp1(T_in,Sa,T_out);
            if j==1
                HorizontalpSaFilename = fullfile(dir_out,Horizontal1pSaFilename(i,1));
            elseif j==2
                HorizontalpSaFilename = fullfile(dir_out,Horizontal2pSaFilename(i,1));
            end
            writematrix([T_out;Sa_out],HorizontalpSaFilename,'Delimiter',',');
        end
    end

end

% 合并 dir_in_cell 中不同文件夹的 MetaData 数据                 
i_line = 0;
for i_dir=1:numel(dir_in_cell)
    fileID = fopen(fullfile(dir_out,['MetaData',num2str(i_dir),'.txt']),'r+');         
    while ~feof(fileID)
        tline = fgetl(fileID);                            
        i_line = i_line+1;
        newline{i_line} = tline;
    end
    fclose(fileID);   
    delete(fullfile(dir_out,['MetaData',num2str(i_dir),'.txt']));
end
fileID = fopen(fullfile(dir_out,'MetaData.txt'),'w+');                    
for k=1:i_line
    fprintf(fileID,'%s\r\n',newline{k});              
end
fclose(fileID); 

% 根据 RSN 编号过滤数据
if nargin>=3
    fileID = fopen(fullfile(dir_out,'MetaData.txt'),'r+');                          
    i = 0;
    while ~feof(fileID)
        tline = fgetl(fileID);  
        newStr = split(string(tline),',');
        if any(RSN_Filter == str2num(newStr(1)))
            i = i+1;
            newline{i} = tline;
        else
            % 删除其他文件
            for i_file=[2,3,6,7]
                delete(fullfile(dir_out,newStr(i_file)));
            end
        end
    end
    fclose(fileID);                                     
    % 输出文本
    fileID = fopen(fullfile(dir_out,'MetaData.txt'),'w+');                    
    for k=1:i
        fprintf(fileID,'%s\r\n',newline{k});              
    end
    fclose(fileID); 
end

% 检查重复RSN
RSN_col = readmatrix(fullfile(dir_out,'MetaData.txt'),'Range','A:A');
for i=1:(numel(RSN_col)-1)
    for j=(i+1):numel(RSN_col)
        if RSN_col(i,1)==RSN_col(j,1)
            warning(['MetaData.txt中有重复记录, RSN=',num2str(RSN_col(i,1))]);
        end
    end
end

end

