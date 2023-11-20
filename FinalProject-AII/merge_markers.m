function [BW] = merge_markers(internal_marker,external_marker)
    BW = internal_marker;
    BW(external_marker) = 0;
end

