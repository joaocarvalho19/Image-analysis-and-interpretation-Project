function [BW] = run_contour(I,internal_marker,iter)
    BW = activecontour(I,internal_marker,iter);
    %figure, 
    %imshow(BW,[]);
    %figure
    %imshow(I, []);
    %colormap(cmap);
    %hold on
    %visboundaries(BW,'Color','white', 'LineWidth', 0.5, 'EnhanceVisibility', true);
end

%figure, 
%g = imshow(mask);

%for k=1:30
    %mask = activecontour(firstI, mask, k, "Chan-vese");
    %set(g, "CData", mask);
    %pause(0.2);
%end