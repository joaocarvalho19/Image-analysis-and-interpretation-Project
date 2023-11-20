function animation(sample_images_stack,contour_stack_final, slice_num,cmap)
    %for ii=1:frames_num
        %ax = subplot(1, 1, 1);
        %imshow(Images(:,:,ii), [], 'Parent', ax);
        %colormap(cmap);    
        %pause(0.5);
    %end
    
    for ii=1:slice_num
        figure
        I = sample_images_stack(:,:,ii);
        imshow(I, []);
        %colormap(cmap);
        hold on
        visboundaries(contour_stack_final(:,:,ii),'Color','white', 'LineWidth', 0.5, 'EnhanceVisibility', true);
        impixelinfo
        pause(0.2);
    end

end
