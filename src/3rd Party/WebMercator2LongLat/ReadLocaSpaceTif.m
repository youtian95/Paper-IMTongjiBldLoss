classdef ReadLocaSpaceTif < handle
    %读取LocaSpace导出的图像
    
    properties (GetAccess = public)
        dirpath
        imagefilepath
        A
        B
        C
        D
        E
        F
        BoundBox %[minLng,maxlng;maxlat,minlat]
        MeterPerPixel = 0
    end
    
    methods
        function obj = ReadLocaSpaceTif(dirpath)
            obj.dirpath = dirpath;
            %图片文件
            listing = dir(fullfile(dirpath,'*.tif'));
            obj.imagefilepath = fullfile(dirpath,listing.name);
            %读取tfw文件
            listing = dir(fullfile(dirpath,'*.tfw'));
            A = readmatrix(fullfile(dirpath,listing.name),'FileType','text');
            obj.A = A(1,1);
            obj.D = A(2,1);
            obj.B = A(3,1);
            obj.E = A(4,1);
            obj.C = A(5,1);
            obj.F = A(6,1);
            %分辨率
            [lng,lat] = webMercator2LngLat(obj.C,obj.F);
            obj.MeterPerPixel = obj.A*cos(deg2rad(lat));
            %范围
            im = imread(obj.imagefilepath);
            [lng,lat] = obj.PixelLoc2LongLat([1,size(im,1)],[1,size(im,2)]);
            obj.BoundBox = [lng;lat];
        end
        function [x,y] = PixelLoc2WGS84WM(obj,pixel_row,pixel_col)
            %输入可以是行向量
            result = [obj.A,obj.B;obj.D,obj.E]*[pixel_col;pixel_row] + [obj.C;obj.F];
            x = result(1,:);
            y = result(2,:);
        end
        function [pixel_row,pixel_col] = WGS84WM2PixelLoc(obj,x,y)
            %输入可以是行向量
            T = [obj.A,obj.B;obj.D,obj.E];
            result = T\([x;y]-[obj.C;obj.F]);
            pixel_col = result(1,:);
            pixel_row = result(2,:);
        end
        function [lng,lat] = PixelLoc2LongLat(obj,pixel_row,pixel_col)
            %输入可以是行向量
            [x,y] = obj.PixelLoc2WGS84WM(pixel_row,pixel_col);
            [lng,lat] = webMercator2LngLat(x,y);
        end
        function [pixel_row,pixel_col] = LongLat2PixelLoc(obj,lng,lat)
            %输入可以是行向量
            [x,y] = LngLat2webMercator(lng,lat);
            [pixel_row,pixel_col] = obj.WGS84WM2PixelLoc(x,y);
        end
    end
end

