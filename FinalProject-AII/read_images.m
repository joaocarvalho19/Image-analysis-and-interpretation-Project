function [stack] = read_images(path,num_strel)
% Get list of all DCM files in this directory
    % DIR returns as a structure array.  You will need to use () and . to get
    % the file names.
    str = strcat('data/',path,'/*.dcm');
    imagefiles = dir(str);  

    % Sort by number (time)
    [~, reindex] = sort( str2double( regexp( {imagefiles.name}, '\d+', 'match', 'once' )));
    imagefiles = imagefiles(reindex) ;

    nfiles = length(imagefiles);    % Number of files found
    str2 = strcat('data/',path);
    % Get images size
    fullFileName = fullfile(str2, imagefiles(1).name);
    test_I = dicomread(fullFileName);
    Isize = size(test_I);

    stack = zeros(Isize(1), Isize(2), nfiles);  %use images size
    for ii=1:nfiles
       currentfilename = imagefiles(ii).name;
       str2 = strcat('data/',path);
       fullFileName = fullfile(str2, currentfilename);
       currentimage = dicomread(fullFileName);
       currentimage = im2gray(currentimage);
        % ++++++ CLEAN IMAGES ++++++
        se = strel('disk', num_strel);
        
        Ie = imerode(currentimage, se);
        Iobr = imreconstruct(Ie, currentimage);

        Iobrd = imdilate(Iobr, se);
        firstI2 = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
        currentimage = imcomplement(firstI2);

       stack(:,:,ii) = currentimage;
    end
end

