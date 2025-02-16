function [x,y] = LngLat2webMercator(lng,lat)
    %输入可以是行向量
    x = lng .*20037508.34./180;
    y = log(tan((90+lat).*pi./360))./(pi./180);
    y = y .*20037508.34./180;
end