function [internal_marker,external_marker] = calc_markers(I,mask,Tupper,Tlower)
    internal_marker = I;
    internal_marker = internal_marker < Tupper;
    internal_marker(~mask) = 0;
    

    external_marker = I;
    external_marker = external_marker < Tlower;
    external_marker(~mask) = 0;
end

