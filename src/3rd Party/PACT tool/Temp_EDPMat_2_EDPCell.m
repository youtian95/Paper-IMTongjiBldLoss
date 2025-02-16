function EDPCell = Temp_EDPMat_2_EDPCell(EDPMat,BoolFinish)
% 输入：
% EDPMat - Drift(i_EQ,i_IM,i_XorY,i_story)
% BoolFinish - Bool(i_EQ,i_IM) 分析是否收敛
% 
% 输出：
% EDPMat - Drift{i_IM}{i_EQ}(i_dir,i_floor)

arguments
    EDPMat (:,:,:,:) double
    BoolFinish (:,:) logical = true
end

EDPCell = cell(1,size(EDPMat,2));
if all(BoolFinish,"all")
    for i_IM = 1:numel(EDPCell)
        for i_EQ = 1:size(EDPMat,1)
            EDPCell{i_IM}{i_EQ} = reshape(EDPMat(i_EQ,i_IM,:,:), ...
                size(EDPMat,3),size(EDPMat,4));
        end
    end
else
    for i_IM = 1:numel(EDPCell)
        EDPCell_1IM = {};
        for i_EQ = 1:size(EDPMat,1)
            if BoolFinish(i_EQ,i_IM)
                EDPCell_1IM1EQ = reshape(EDPMat(i_EQ,i_IM,:,:), ...
                    size(EDPMat,3),size(EDPMat,4));
                EDPCell_1IM = [EDPCell_1IM,EDPCell_1IM1EQ];
            end
        end
        EDPCell{i_IM} = EDPCell_1IM;
    end
end

end

