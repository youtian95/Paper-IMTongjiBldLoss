function createIMGifFromSimulations(Plot_IM_Spatial, iSimList, gifFilename, delayTime)
    % Plot_IM_Spatial: 绘图函数句柄
    % iSimList: 要生成的模拟结果
    % gifFilename: 保存的GIF文件名
    % delayTime: 每帧之间的延迟时间（秒）
   
    
    % 通过不同的iSim值生成多张图
    i=1;
    for iSim = iSimList
        % 调用输入的绘图函数
        f = Plot_IM_Spatial(iSim);  % 根据iSim绘制不同的图形

        f.Color = "white";
        set(gcf,'Position',[5 5 20 16]);
        fontsize(f, scale=2);
        
        % 捕获当前图像的帧
        frame = getframe(gcf);  % 获取当前图形窗口的帧
        im = frame2im(frame);

        % 获取RGB图像数据
        [A,map] = rgb2ind(im,256);
        
        % 将该帧写入到GIF文件
        if i == 1
            imwrite(A,map,gifFilename,"gif",LoopCount=Inf, ...
                    DelayTime=delayTime)
        else
            imwrite(A,map,gifFilename,"gif",WriteMode="append", ...
                    DelayTime=delayTime)
        end
        close;
        i=i+1;
    end
end
