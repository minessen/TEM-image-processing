clear all;
close all;
clc;

% path0='Z:\[J3] Phase\Sen';
% path1=fullfile(path0,'image_1');
path0='E:\[J3] Phase\Sen new HRTEM';
path1=fullfile(path0,'Amorphous');

Ifull = imread(fullfile(path1,'CCD Search_0077.tif'));

% crop full image, dimensions of the image
[row, col]=size(Ifull);
wh = min([row col])
xcrop = 1800;
ycrop = 550;

% TEM image-Sen\1020-720 24\53.tif  xcrop = 780; ycrop = 2048; sq=2048; 1
% 53.tif  xcrop = 780; ycrop = 2096; sq = 2000; 2
% 53.tif  xcrop = 780; ycrop = 2116; sq = 1980; 3


sq = 1750;
% Isave = imcrop(Ifull, [xcrop ycrop sq (row-ycrop)])
% figure(),imshow(Isave,[])
% %imtool(Isave)
I = imcrop(Ifull,[xcrop ycrop 1749 1749]);
figure(),imshow(I,[])
imtool(I)

%box Size 250 150 
Size = 150;
%Hanning window size
M=Size;
N=Size;
%step size 80 50
step = 50;
%strel size 3 5
strel_ = 3;

% %crop size
% Isize=4000;
% [x_crop,y_crop]=ginput(1);
% x_cp=floor(x_crop);
% y_cp=floor(y_crop);
% 
% I = imcrop(Iori,[x_cp y_cp Isize Isize])
% figure(1), imshow(I,[])

%spatial info
INF=[];
ind = 4;

a=0;
X=[];
n_step=floor((sq-Size)/step)
n_size=(n_step)*step

%column
for i=1:step:n_size+1
    %row
    for j=1:step:n_size+1+step
        if j <= n_size+1
        a=a+1;
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];
        
%         figure(1),imshow(I)
%         title('fft pattern')
%         rectangle('Position', [i j Size-1 Size-1], 'EdgeColor', 'r')  

        % crop a small size of image
        I2=imcrop(I,[i j Size-1 Size-1])        
%          figure(2), imshow(I2,[])

% % without Hann window
%         F=fftshift(fft2(I2));   
%         Flog = log(1+abs(F));
%         Fg = mat2gray(Flog)
% %        figure(2),imshow(Fg,[]);

% with Hann window
        w_1=hanning(M);
        w_2=hanning(N);
        w=w_1*w_2';
        %fft transform        
        F=fftshift(fft2(im2double(I2).*w));
        Flog = log(1+abs(F));
        Fg = mat2gray(Flog)  
%         figure(3), imshow(Fg,[]);  

% with background subtraction
        SE = strel('disk',strel_,0);
        FgSE = imclose(Fg,SE);
%        figure(4), imshow(FgSE, [])
        background= imopen(FgSE, strel('disk',strel_));
%         figure(5), imshow(background)
        FgSE1 = FgSE-background;
%         figure(6), imshow(FgSE1,[])

%          % without backgound subtraction
%          c = reshape(Fg,1,[]); 
         % with background subtraction
         c = reshape(FgSE1,1,[]); 
         X=[X;c];
        else
        j=sq-Size;  
        a=a+1;
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];
        
        % crop a small size of image
        I2=imcrop(I,[i j Size-1 Size-1])        
%         figure(2), imshow(I2,[])

% % without Hann window
%         F=fftshift(fft2(I2));   
%         Flog = log(1+abs(F));
%         Fg = mat2gray(Flog)
% %        figure(2),imshow(Fg,[]);

% with Hann window
        w_1=hanning(M);
        w_2=hanning(N);
        w=w_1*w_2';
        %fft transform        
        F=fftshift(fft2(im2double(I2).*w));
        Flog = log(1+abs(F));
        Fg = mat2gray(Flog)  
%         figure(3), imshow(Fg,[]);  

% with background subtraction
        SE = strel('disk',strel_,0);
        FgSE = imclose(Fg,SE);
%          figure(4), imshow(FgSE, [])
        background= imopen(FgSE, strel('disk',strel_));
%          figure(5), imshow(background)
        FgSE1 = FgSE-background;
%          figure(6), imshow(FgSE1,[])

%          % without backgound subtraction
%          c = reshape(Fg,1,[]); 
         % with background subtraction
         c = reshape(FgSE1,1,[]); 
         X=[X;c];
         end
    end
end


% the last column
i=sq-Size;
for j=1:step:n_size+1+step
        if j <= n_size+1
        a=a+1;
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];
        
%         figure(1),imshow(I)
%         title('fft pattern')
%         rectangle('Position', [i j Size-1 Size-1], 'EdgeColor', 'r')  

        % crop a small size of image
        I2=imcrop(I,[i j Size-1 Size-1])        
%         figure(2), imshow(I2,[])

% % without Hann window
%         F=fftshift(fft2(I2));   
%         Flog = log(1+abs(F));
%         Fg = mat2gray(Flog)
% %        figure(2),imshow(Fg,[]);

% with Hann window
        w_1=hanning(M);
        w_2=hanning(N);
        w=w_1*w_2';
        %fft transform        
        F=fftshift(fft2(im2double(I2).*w));
        Flog = log(1+abs(F));
        Fg = mat2gray(Flog)  
%         figure(3), imshow(Fg,[]);  

% with background subtraction
        SE = strel('disk',strel_,0);
        FgSE = imclose(Fg,SE);
%          figure(4), imshow(FgSE, [])
        background= imopen(FgSE, strel('disk',strel_));
%          figure(5), imshow(background)
        FgSE1 = FgSE-background;
%          figure(6), imshow(FgSE1,[])

%          % without backgound subtraction
%          c = reshape(Fg,1,[]); 
         % with background subtraction
         c = reshape(FgSE1,1,[]); 
         X=[X;c];
        else
        j=sq-Size;  
        a=a+1;
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];
        
        % crop a small size of image
        I2=imcrop(I,[i j Size-1 Size-1])        
%         figure(2), imshow(I2,[])

% % without Hann window
%         F=fftshift(fft2(I2));   
%         Flog = log(1+abs(F));
%         Fg = mat2gray(Flog)
% %        figure(2),imshow(Fg,[]);

% with Hann window
        w_1=hanning(M);
        w_2=hanning(N);
        w=w_1*w_2';
        %fft transform        
        F=fftshift(fft2(im2double(I2).*w));
        Flog = log(1+abs(F));
        Fg = mat2gray(Flog)  
%       figure(3), imshow(Fg,[]);


% with background subtraction
        SE = strel('disk',strel_,0);
        FgSE = imclose(Fg,SE);
%          figure(4), imshow(FgSE, [])
        background= imopen(FgSE, strel('disk',strel_));
%          figure(5), imshow(background)
        FgSE1 = FgSE-background;
%          figure(6), imshow(FgSE1,[])

%          % without backgound subtraction
%          c = reshape(Fg,1,[]); 
         % with background subtraction
         c = reshape(FgSE1,1,[]);
         X=[X;c];
         end
    end

save('Amorphous_0077crop-150503.mat','X')

%[coeff,Xt] = pca(X,'NumComponents',20);

[coeff,score,latent,tsquared,explained,mu] = pca(X,'NumComponents',20);

save('Amorphous_0077crop(20)-150503.mat','score')
