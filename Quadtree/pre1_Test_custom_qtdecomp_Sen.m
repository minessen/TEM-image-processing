clc
clear variables
close all

path0='E:\[J3] Phase\Image small';
path1=fullfile(path0,'image_small2');
files = fullfile(path1,'Scanning Search2_0048.tif');
image_name = files;

% files = {'Scanning Search2_0036.tif'};
% image_name = files{1};
img = imread(image_name);
[row, col, ~] = size(img);
figure, imshow(img,[])
%img = imadjust(img,[],[],0.5);
img_node = square_image(img);
imshow(img_node.img)
resol = 32;
qtree = custom_qtdecomp(img_node,resol);
sparce_mtx = visualize_qtree(qtree);

% Combines the quadtree with the original image
test = plot_matrix(sparce_mtx);

row_log_round = round(log2(row));
col_log_round = round(log2(col));

pow = max([row_log_round col_log_round]);
new_img_size = 2^pow;
resized_img = imcrop(img, [0 0 new_img_size new_img_size]);

C = imfuse(test,resized_img,'blend');
figure(7)
imshow(C);
title('combined');
savefig(C)
clc
close all

% imshow(resized_img,[])
% hold on;
% plot_matrix(sparce_mtx);


function processed_image_node = square_image(img)
% crop the image into 2^x size. and initialize the quadtree
    [row, col, ~] = size(img);
    row_log_round = round(log2(row));
    col_log_round = round(log2(col));
    
    pow = max([row_log_round col_log_round]);
    new_img_size = 2^pow;
    
    % Quadtree initialization
    processed_image = imcrop(img, [0 0 new_img_size new_img_size]);
    processed_image_node.img = processed_image;
    
    % Negative infinity acts like "NULL", since MATLAB does not
    % have null value
    processed_image_node.qd1 = -Inf;
    processed_image_node.qd2 = -Inf;
    processed_image_node.qd3 = -Inf;
    processed_image_node.qd4 = -Inf;
    
end

function return_matrix = visualize_qtree(qtree)
% put the quadtree into a sparce matrix format. it still returns a normal
% matlab matrix
    [im_size, ~, ~] = size(qtree.img);
    
    try
        
    if isinf(qtree.qd1) && isinf(qtree.qd2) && isinf(qtree.qd3) && isinf(qtree.qd4)
        return_matrix = zeros(im_size);
        return_matrix(1, 1) = im_size;
    end
    
        catch
        return_matrix = zeros(im_size);
        return_matrix(1:im_size/2, 1:im_size/2) = visualize_qtree(qtree.qd1);
        return_matrix(1:im_size/2, im_size/2+1:end) = visualize_qtree(qtree.qd2);
        return_matrix(im_size/2+1:end, im_size/2+1:end) = visualize_qtree(qtree.qd3);
        return_matrix(im_size/2+1:end, 1:im_size/2) = visualize_qtree(qtree.qd4);
        
    end
    
        
end

function return_matrix = plot_matrix(matrix)
% converts the sparce matrix in the previous function into blocks. This can
% be directly plotted
    [dim, ~] = size(matrix);
    return_matrix = zeros(dim);
    for i = 1:dim
        for j = 1:dim
            square = matrix(i, j);
            if square ~= 0 && square ~= 1
                boarders = ones(square);
                boarders(2:square-1, 2:square-1) = zeros(square-2);
                return_matrix(i:i+square-1, j:j+square-1) = boarders;
            end
        end
    end
            
end