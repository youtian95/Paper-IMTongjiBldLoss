classdef SearchVs30

    properties
        Vs30DataFile = ".\Data\China_Mainland_SCK_Vs30.xlsx"
        T
    end

    methods
        function obj = SearchVs30()
            obj.T = readtable(obj.Vs30DataFile,"VariableNamingRule","preserve");
        end

        function Vs30_mpers = GetVs30(obj,lon,lat)
            Dist = (obj.T.("Longitude (°)")-lon).^2+(obj.T.("Latitude (°)")-lat).^2;
            [~,row] = min(Dist);
            
            Vs30_mpers = obj.T{row,end};
        end
    end
end