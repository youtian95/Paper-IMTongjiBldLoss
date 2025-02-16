% 直接运行本脚本来输出图片
[file,path] = uiputfile('*.*');
exportgraphics(gcf, fullfile(path,file), 'ContentType','vector','Resolution',1200);