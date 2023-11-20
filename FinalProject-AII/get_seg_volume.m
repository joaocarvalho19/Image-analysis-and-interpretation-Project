function [volume_eval] = get_seg_volume(path_patient_seg)
    % ------ READ SEGMENTED IMAGE ------
    [V,spatial,dim] = dicomreadVolume(fullfile(path_patient_seg));
    Vtumor = V(:,:,1:3);
    volume_eval = 0;
    for i=1:3
        slice = Vtumor(:,:,i);
        volume_eval = volume_eval + sum(slice(:));
    end
end

