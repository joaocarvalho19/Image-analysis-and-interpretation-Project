function merged_image_seg = get_merged_seg(path_patient_seg)
    % ------ READ SEGMENTED IMAGE ------
    [V,spatial,dim] = dicomreadVolume(fullfile(path_patient_seg));

    merged_image_seg = V(:,:,1);
    for i=1:3
        merged_image_seg = merged_image_seg | V(:,:,i);
    end
end

