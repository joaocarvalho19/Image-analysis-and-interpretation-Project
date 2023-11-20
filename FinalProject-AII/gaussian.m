function [tumor_mean,second_mean, tumor_sigma, second_sigma] = gaussian(I,mask,num_components)
    GMModel = fitgmdist(I(mask),num_components);    
    % Sort the means and sigmas - the tumor mean and sigma is the lowest values
    means = GMModel.mu;
    sorted_means = sort(GMModel.mu);
    tumor_mean = sorted_means(1);
    tumor_index = find(means==tumor_mean);
    second_mean = sorted_means(2);
    second_index = find(means==second_mean);
    tumor_mean
    
    sigmas = GMModel.Sigma;
    tumor_sigma = sigmas(tumor_index);
    second_sigma = sigmas(second_index);
end

