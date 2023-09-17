function returned_image_node = custom_qtdecomp(img_node, resolution)
    % This is the main function responsible for dividing up the image.
    % Arguments:
    %   img_node: a custom struct structure. Has fileds of
    %           1. img -> the matrix for the original (before FFT) image
    %           2. qd# -> the child nodes (same datastructure as img_node)
    %                     for the current node. Divided into 4 quadrants,
    %                     which follows the traditional math quadrant
    %                     convention. The nodes will be set to "-Inf" if
    %                     the current node does not have any child nodes
    %   
    %   resolution: the smallest window size in the quadtree
    % Returns:
    %   returned_image_node: A custom MATLAB struct structure. Explained
    %   above.
    
    % Image must be a square and the size needs to be an integer
    % power of 2. Checks for square
    [row, col, ~] = size(img_node.img);
    if row ~= col
        exc = MException('Image not square');
        throw(exc);
    end
    
    % Compare similarity of 4 sub images of the current node
    % "compare_4_images" is a custom function in this file.
    sub_image_similarity =  compare_4_images(img_node);
    
    % Threshold for stopping dividing things up. If all the sub-sections
    % are similar or the samllest window size has been reached, stop
    % further dividing and return
    if (row <= resolution) || (sub_image_similarity == true)
        returned_image_node = img_node;
    else
    % If the requirements for stopping further dividing has not been met,
    % further dividing the current node into 4 smaller ones
    % NOTE: recursion is used here. "custom_qtdecomp" calls itself
       [img_node, ~] = divide_image_node(img_node);
       img_node.qd1 = custom_qtdecomp(img_node.qd1, resolution);
       img_node.qd2 = custom_qtdecomp(img_node.qd2, resolution);
       img_node.qd3 = custom_qtdecomp(img_node.qd3, resolution);
       img_node.qd4 = custom_qtdecomp(img_node.qd4, resolution);
       returned_image_node = img_node;
    end
    
end


function is_repeat = compare_4_images(img)
% This function compares 4 images (6 different combinations) and returns if
% the 4 images are alike. 
% Argument: img -> The image (not node) that you wish to analysis
% Returns: is_repeat: True if all 4 images are alike. False otherwise

    % divides the passed-in image into 4 smaller ones
    [~, sub_imgs] = divide_image_node(img);
    indices = uint8([1 2 3 4]);
    comb = nchoosek(indices,uint8(2));
    
    for i = 1:length(comb)
        
        image_indices = comb(i, :);
        im1_original = sub_imgs{image_indices(1)};
        im2_original = sub_imgs{image_indices(2)};
%        im1_original_gamma = imadjust(im1_original,[],[],0.5);
%        im2_original_gamma = imadjust(im2_original,[],[],0.5);
%        im1_h_gradient = conv2(im1_original_gamma, [1 -1], 'same');        %%???
%        im2_h_gradient = conv2(im2_original_gamma, [1 -1], 'same');

%        im1 = fft_image(im1_original_gamma);
%        im2 = fft_image(im2_original_gamma);
         im1 = fft_image(im1_original);
         im2 = fft_image(im2_original);
         
        % removes boarders since there are some noises
        im1 = remove_boarders(im1);
        im2 = remove_boarders(im2);
        figure(3)
        subplot(2,2,1)
        imshow(im1_original)
        subplot(2,2,2)
        imshow(im2_original)
        
        
%         figure(4)
%         subplot(2,2,1)
%         imshow(im1_original)
%         title("original im1")
%         subplot(2,2,2)
%         imshow(im2_original)
%         title("original im2")
%         subplot(2,2,3)
%         imshow(im1_original_gamma)
%         title("gamma corrected im1")
%         subplot(2, 2, 4)
%         imshow(im2_original_gamma)
%         title("gamma corrected im2")
        
%         im1_gamma = fft_image(im1_original_gamma);
%         im2_gamma = fft_image(im2_original_gamma);
%         im1_gamma = remove_boarders(im1_gamma);
%         im2_gamma = remove_boarders(im2_gamma);
%         figure(5)
%         subplot(2, 2, 1)
%         imshow(im1./max(im1(:)))
%         title('FFT of image 1')
%         subplot(2, 2, 2)
%         imshow(im2./max(im2(:)))
%         title('FFT of image 2')
%         subplot(2, 2, 3)
%         imshow(im1_gamma./max(im1_gamma(:)));
%         title('FFT of gamma corrected im1')
%         subplot(2, 2, 4)
%         imshow(im2_gamma./max(im1_gamma(:)));
%         title('FFT of gamma corrected im2')
        
        is_similar = image_similarity(im1, im2, 10);
        
        % returns true only if all 6 comparision result are positive.
        if is_similar == false
            is_repeat = false;
            return
        end
    end
    
    is_repeat = true;
    
end

function [new_img_node, divided_imgs] = divide_image_node(img_node)
% divides the current image node into 4 smaller ones
% Arguments: img_node -> The NODE (not image)
% Returns: 
%   new_img_node: The custom MATLAB struct explained in the first function
%   devided_imgs: The MATLAB cell array of 4 sum images, NOT node

    [row, col, ~] = size(img_node.img);
    sub_img_size = row/2;
    
    sub_imgs = cell(4,1);
    sub_imgs{1} = imcrop(img_node.img, [1 1 sub_img_size-1 sub_img_size-1]);
    sub_imgs{2} = imcrop(img_node.img, [sub_img_size 1 sub_img_size-1 sub_img_size-1]);
    sub_imgs{3} = imcrop(img_node.img, [sub_img_size sub_img_size sub_img_size-1 sub_img_size-1]);
    sub_imgs{4} = imcrop(img_node.img, [1 sub_img_size sub_img_size-1 sub_img_size-1]);

    img_node.qd1 = create_new_node(sub_imgs{1});
    img_node.qd2 = create_new_node(sub_imgs{2});
    img_node.qd3 = create_new_node(sub_imgs{3});
    img_node.qd4 = create_new_node(sub_imgs{4});
    new_img_node = img_node;
    divided_imgs = sub_imgs;
end

function is_similar = image_similarity(im1, im2, threshold)
    % This function checks if two (FFT) images are similar
    % Arguments:
    %   im1: Image 1 (not img_node) after FFT
    %   im2: Image 2 (not img_node) after FFT
    %   threshold: the threshold dor determining if two images are the
    %   same(NOTE: This value is not currently used)
    % Returns:
    %   is_similar: True if im1 and im2 are alike by the threhold
    %               False if im1 and im2 are not alike.
    
    noise_cutout = 20;  % sort of the Signal to Noise ratio
    
    [im_dim, ~] = size(im1);
    % removes the center 9 pixels. All the FFT images have the britest spot
    % in the middle of the image. Remove the center for better comparision
    % and visualization
    im1 = remove_center(im1);
    im2 = remove_center(im2);
    
    
    % Do a element-wise self-multiplication. This step removes noises and
    % can achive better comparision result in later steps.
    im1_self_product = im1 .* im1;
    im2_self_product = im2 .* im2;
    im_product = im1 .* im2;
    % Do a element-eise product between images. This will show patterns
    % that overlapses in two images
    
    
    % Divides by the largest pixel value in the image to get a normalized
    % image. This is for visualization.
%     im_product_normalized = im_product ./ max(im_product(:));
%     im1_normalized = im1 ./ max(im1(:));
%     im2_normalized = im2 ./ max(im2(:));
%     im1_self_product_normalized = im1_self_product ./ max(im1_self_product(:));
%     im2_self_product_normalized = im2_self_product ./ max(im2_self_product(:));
%     
    % This mask is used to remove noises (weak responses in the image). Any
    % pixel value samller than the "noise_cutout" are deemed as noises. 
    % NOTE: This could be a potential problem for detecting images with
    % small area of different structure.
    im1_self_product_mask = im1_self_product >= (max(im1_self_product(:))/noise_cutout);
    im2_self_product_mask = im2_self_product >= (max(im2_self_product(:))/noise_cutout);
    
    % Gets the difference between the image self product and between image
    % product. If two images are alike, in theory, this value will be small
    diff_1 = abs(im1_self_product - im_product);
    diff_2 = abs(im2_self_product - im_product);
%     rel_diff_1 = sum(diff_1(:)) / sum(im_product(:));
%     rel_diff_2 = sum(diff_2(:)) / sum(im_product(:));
      rel_diff_1 = sum(diff_1(:)) / sum(im1_self_product(:));
      rel_diff_2 = sum(diff_2(:)) / sum(im2_self_product(:));
    max_diff = max([rel_diff_1 rel_diff_2]);                               %%???
    
    % Plotting Codes
    figure(3)
    subplot(2, 2, 3)
    imshow(diff_1 ./ max(diff_1(:)))
    subplot(2, 2, 4)
    imshow(diff_2 ./ max(diff_2(:)))
    
    figure(4)
    subplot(1, 2, 1)
    imshow(im1_self_product_mask)
    subplot(1, 2, 2)
    imshow(im2_self_product_mask)
   
    if max_diff <= 0.6 %    
        is_similar = true;
    else
        is_similar = false;
    end
end

function returned_image = fft_image(img)
% FFT the image using haning widow and background removal
    strel_ = 3;
    [row, col, ~] = size(img);
    w_1=hanning(row);
    w_2=hanning(col);
    w=w_1*w_2';
    F=fftshift(fft2(im2double(img).*w));
    Flog = log(1+abs(F));
    Fg = mat2gray(Flog);
    SE = strel('disk',strel_,0);
    FgSE = imclose(Fg,SE);
    background= imopen(FgSE, strel('disk',strel_));
    FgSE1 = FgSE-background;
    returned_image=FgSE1;
end


function return_node = create_new_node(image)
% initializes a new node with the image passed in. No child node created in
% the initizalization step
    return_node.img = image;
    return_node.qd1 = -Inf;
    return_node.qd2 = -Inf;
    return_node.qd3 = -Inf;
    return_node.qd4 = -Inf;
end

function return_image = remove_center(image)
%Removes the center
    [dim, ~, ~] = size(image);
    middle = dim/2 + 1;
    indices = [middle-2:middle+2];
    return_image = zeros(dim);
    return_image(1:end, 1:end) = image(1:end, 1:end);
    
    for i = indices
        for j = indices
            return_image(i, j) = 0;
        end
    end
    
end

function return_image = remove_boarders(image)
%removes the boarders
    [dim, ~, ~] = size(image);
    boarder_size = log2(dim);
    return_image = zeros(dim);
    
    return_image(boarder_size:end-boarder_size,boarder_size:end-boarder_size) = ...
        image(boarder_size:end-boarder_size,boarder_size:end-boarder_size);
    
end



function [centroids_3d, mean_intensity] = imvectors(img)
    SNR = 4;
    minimum_threshold = max(img(:)) / SNR;
    img_mask = img >= minimum_threshold;
%     img = img .* img_mask;
%     img = round((img./max(img(:)))*255);
%     img = uint8(img);
    s = regionprops(img_mask, img,'WeightedCentroid');
    centroids = cat(1,s.WeightedCentroid);
    centroids_3d = [centroids zeros([length(centroids) 1])];
    mean_intensity = regionprops(img_mask, img,'MeanIntensity');
    mean_intensity = cat(1, mean_intensity.MeanIntensity);
    
    
end


