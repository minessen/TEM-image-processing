clear all; clc; close all;

path0='E:\[J3] Phase\Image small';
path1=fullfile(path0,'image_small2');

I = imread(fullfile(path1,'Scanning Search2_0048.tif'));
imshow(I,[])
% imtool(I,[])

[row col] = size(I);

[x,y]=ginput(1);
x=round(x);
y=round(y);
value=[];
for i = 1:1:14
    win = i*30
    xl = x - win/2
    yl = y - win/2
    
    figure(1), imshow(I)
    title('cropped scan window')
    rectangle('Position', [xl yl win win], 'EdgeColor', 'r')
    
    % crop a small size of image
    figure()
    subplot(1,3,1)
    I2 = imcrop(I, [xl yl win win])
    %figure(2), 
    imshow(I2, [])
    title(['Image window is ' num2str(win)])
    
    % without hanning window
    Fr=fftshift(fft2(I2));   
    Frlog = log(1+abs(Fr));
    Frg = mat2gray(Frlog)
%     figure(3),imshow(Frg,[]);
    Ig = im2uint8(Frg)
    val = std2(Ig)

    subplot(1,3,2)
    imshow(Ig, [])
    title('Raw FFT pattern')
    subplot(1,3,3)
    imhist(Ig)
    title(['Histogram of image std is ' num2str(val)])
%     imtool(Ig)
 
    value = [value; val];
    close all;
end
