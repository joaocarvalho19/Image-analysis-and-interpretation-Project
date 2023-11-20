function [Tupper,Tlower] = calc_thresholds(tumor_mean,second_mean, tumor_sigma, second_sigma)
    %Tupper = min(tumor_mean + 1.0 * tumor_sigma,(tumor_mean + second_mean) / 2.0);
    %Tlower = min(tumor_mean + 2.5 * tumor_sigma,max(second_mean - second_sigma, second_mean - 0.25 * (second_mean-tumor_mean)));
    
    Tupper = min(tumor_mean + 1.0 * tumor_sigma,(tumor_mean + second_mean)/2.0);
    %Tlower = max(tumor_mean - 2.5 * tumor_sigma,min(second_mean + second_sigma, second_mean + 0.25 * (tumor_mean-second_mean)));
    diff =Tupper - tumor_mean;
    Tlower = tumor_mean - diff;
end

