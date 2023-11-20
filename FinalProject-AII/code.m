clear
close all
cmap = load('cmap.mat');
cmap = cmap(1).cmap;

path_patient_2 = 'Breast_MRI_002/BREAST_BILATERAL_W_WO-51972/3.000000-ax t1-40797';
path_patient_2_seg = 'data/Breast_MRI_002/BREAST_BILATERAL_W_WO-51972/300.000000-Segmentation-70895/1-1.dcm';
path_patient_8 = 'Breast_MRI_008/BREAST_BILATERAL_WWO-56538/25.000000-ax t1 tse c-51981';
path_patient_8_seg = 'data/Breast_MRI_008/BREAST_BILATERAL_WWO-56538/300.000000-Segmentation-94158/1-1.dcm';
path_patient_18 = 'Breast_MRI_018/01-01-1990-NA-BREASTROUTINE DYNAMIC-32826/3.000000-ax t1-89053';
path_patient_18_seg = 'data/Breast_MRI_018/01-01-1990-NA-BREASTROUTINE DYNAMIC-32826/300.000000-Segmentation-28493/1-1.dcm';
path_patient_48 = 'Breast_MRI_048/01-01-1990-NA-BREASTROUTINE DYNAMICS-77405/01-01-1990-NA-BREASTROUTINE DYNAMICS-77405/3.000000-ax t1-88662';
path_patient_48_seg = 'data/Breast_MRI_048/01-01-1990-NA-BREASTROUTINE DYNAMICS-77405/300.000000-Segmentation-97961/1-1.dcm';
path_patient_57 = 'Breast_MRI_057/01-01-1990-NA-BREASTROUTINE DYNAMIC-90347/3.000000-ax t1-97642';
path_patient_57_seg = 'data/Breast_MRI_057/01-01-1990-NA-BREASTROUTINE DYNAMIC-90347/300.000000-Segmentation-37203/1-1.dcm';

% ------ READ IMAGES ------
num_strel = 1;  % numero para o elemento estrutural
images_stack = read_images(path_patient_48,num_strel); % Stack com todas as imagens

s_images = size(images_stack);
slice_num = s_images(3);
disp(slice_num);

firstI_index = round(slice_num/2);  % Começar no slice médio
firstI_index
%firstI_index = 27;  % Começar no slice médio

% montage
figure,
montage(images_stack(:,:,:), 'DisplayRange', []);
title("Stack montage")

% ------------
firstI = images_stack(:,:,firstI_index);
figure,
imshow(firstI, []);
colormap(cmap);
impixelinfo
roi1 = drawassisted('StripeColor','y');   % Select first the ROI
roi2 = drawassisted('StripeColor','y');   % Select second the ROI
mask1 = createMask(roi1, firstI);
mask2 = createMask(roi2, firstI);

mask = imbinarize(imadd(mask1, mask2)); % Final mask

%Histogram
figure,
histogram(firstI(mask), 200);
title("Histogram of the ROI")


% ------ GAUSSIAN MIXTURE MODEL ------
[tumor_mean,second_mean, tumor_sigma, second_sigma] = gaussian(firstI,mask,4);

% ------ THRESHOLD CALC ------
[Tupper,Tlower] = calc_thresholds(tumor_mean,second_mean, tumor_sigma, second_sigma);
Tupper
Tlower
hold on
y=0:1:200; %How much is long
line([Tupper Tupper],[y(1) y(end)],'LineWidth',4,'Color', 'red')
line([Tlower Tlower],[y(1) y(end)],'LineWidth',4,'Color', 'green')
% ------ MARKERS ------
[internal_marker,external_marker] = calc_markers(firstI,mask,Tupper,Tlower);

% ------ Merge markers ------
BW = merge_markers(internal_marker,external_marker);

finalI = firstI;
finalI(BW) = 1500;      % Imagem original com a segmentação

% ------ VOLUME VALUE ------
volume = sum(BW(:));

% ------ Stack with contour images ------
Isize = size(firstI);
segmentation_stack = zeros(Isize(1), Isize(2), slice_num);  %use images size
segmentation_stack(:,:,firstI_index) = BW;
images_seg_stack = images_stack;  %use images size
images_seg_stack(:,:,firstI_index) = finalI;

% ------ PROPAGATION ------
num_strel_prop = 1; 
SE = strel('disk',num_strel_prop);
new_ROI = imdilate(BW,SE);
[volume_final, segmentation_stack, images_seg_stack] = run_propagation(volume,new_ROI, images_stack, firstI_index, slice_num, segmentation_stack, images_seg_stack,Tupper,Tlower, num_strel_prop);
segmentation_stack = logical(segmentation_stack);

% ------ SHOW RESULTS ------ 
volume_final

% Algorithm animation
animation(images_stack, segmentation_stack,slice_num);

figure,
montage(images_seg_stack(:,:,34:38), 'DisplayRange', []);
title("Segmented Images with 36 as first image")

%Show 3d Volume
showVolume(segmentation_stack);

% ------ EVALUATION ------

% Imagem resultante de todas as segmentações fundidas
final_seg_image = merge_seg_images(segmentation_stack, slice_num);  
% Imagem resultante de todas as segmentações fundidas
merged_image_seg = get_merged_seg(path_patient_48_seg);

volume_eval = get_seg_volume(path_patient_48_seg);
volume_eval

size_our = size(final_seg_image);
size_eval = size(merged_image_seg);

size_factor = size_our(1)/size_eval(1);
merged_image_seg = imresize(merged_image_seg,size_factor);  % Resize a imagem "merged" segmentada de avaliação

our_merged_area = sum(final_seg_image(:));
eval_merged_area = sum(merged_image_seg(:));
our_merged_area
eval_merged_area

similarity = dice(final_seg_image,merged_image_seg);
similarity

%figure,
%imshow(final_seg_image, []);
%title("Merge Algorithm image")
%figure,
%imshow(merged_image_seg, []);
%title("Merged Evaluation image")

% FUNCTIONS
function final_seg_image =  merge_seg_images(segmentation_stack, slice_num)
    final_seg_image = segmentation_stack(:,:,1);
    for i=2:slice_num
        final_seg_image = final_seg_image | segmentation_stack(:,:,i);
    end
end


function animation(images_stack, contour_stack_final,slice_num)

    for ii=1:slice_num
        ax = subplot(1, 1, 1);
        I = images_stack(:,:,ii);
        BW = contour_stack_final(:,:,ii);

        I(BW) = 1500;
        imshow(I, [], 'Parent', ax);
        %colormap(cmap);    
        pause(0.1);
    end
end

function showVolume(image)
    V = squeeze(image);
    intensity = [0 20 40 120 220 1024];
    alpha = [0 0 0.15 0.3 0.38 0.5];
    color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255])/ 255;
    queryPoints = linspace(min(intensity),max(intensity),256);
    amap = interp1(intensity,alpha,queryPoints)';
    cmap = interp1(intensity,color,queryPoints);
    volshow(V,Colormap=cmap,Alphamap=amap);
end