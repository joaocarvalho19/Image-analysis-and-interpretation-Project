function [volume_final, contour_stack_final, images_seg_stack] = run_propagation(volume,new_ROI, stack, firstI_index, slice_num, contour_stack, images_seg_stack,Tupper,Tlower, num_strel_prop)
    
    volume_final = volume;
    contour_stack_final = contour_stack;
    % Forwards
    % New ROI
    forw_ROI = new_ROI;
    for i=firstI_index+1:slice_num   %sample_images_stack
        nextI = stack(:,:,i);

        % ------ MARKERS ------
        [internal_marker,external_marker] = calc_markers(nextI,forw_ROI,Tupper,Tlower);
        
        if sum(internal_marker) == 0
            break
        end
        % ------ MERGE ------
        BW = merge_markers(internal_marker,external_marker);
        finalI = nextI;
        finalI(BW) = 1500;
        % ------ Volume ------
        volume_final = volume_final + sum(BW(:));
        % Add to contours stack
        contour_stack_final(:,:,i) = BW;
        images_seg_stack(:,:,i) = finalI;
        SE = strel('disk',num_strel_prop);
        forw_ROI = imdilate(BW,SE);
        %figure
        %imshow(new_ROI, []);
    end
    
    
    % Backwards
    % New ROI
    back_ROI = new_ROI;
    for i=firstI_index-1:-1:1   %sample_images_stack
        
        nextI = stack(:,:,i);

        % ------ MARKERS ------
        [internal_marker,external_marker] = calc_markers(nextI,back_ROI,Tupper,Tlower);
        
        if sum(internal_marker) == 0
            break
        end

        % ------ MERGE ------
        BW = merge_markers(internal_marker,external_marker);
        finalI = nextI;
        finalI(BW) = 1500;
        % ------ Volume ------
        volume_final = volume_final + sum(BW(:));
        contour_stack_final(:,:,i) = BW;
        images_seg_stack(:,:,i) = finalI;

        SE = strel('disk',num_strel_prop);
        back_ROI = imdilate(BW,SE);
        %figure
        %imshow(new_ROI, []);
    end
end

