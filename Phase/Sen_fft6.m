clear all;
close all;
clc;

% path0='Z:\[J3] Phase\Sen';
% path1=fullfile(path0,'image_small');
path0='E:\[J3] Phase\Image small';
path1=fullfile(path0,'image_small2');

I = imread(fullfile(path1,'Scanning Search2_0048.tif'));

imshow(I,[])
%  imtool(I,[])

%dimensions of the image  
[row, col]=size(I);

%box Size 80  200
Size = 100;  
M=Size;N=Size;
%step size 40 100
step = 50;
%strel size 3 5
strel_ = 3;

%spatial info
INF=[];
ind = 4;

a=0;
X=[];

% i = 300; j = 400; 
% % crop a small size of image 1700 1722
% I2=imcrop(I,[i j 1722 1722])
% figure(), imshow(I2,[])


[x,y]=ginput(1);
x=round(x);
y=round(y);
%row
for i=x:step:row-Size
    %column
    for j=y:step:col-Size
        a=a+1;
        
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];

        figure(1),imshow(I)
        title('fft pattern')
        rectangle('Position', [i j Size-1 Size-1], 'EdgeColor', 'r')  

        % crop a small size of image
        I2=imcrop(I,[i j Size-1 Size-1])
        figure(2), imshow(I2,[])

% without hanning window
        Fr=fftshift(fft2(I2));   
        Frlog = log(1+abs(Fr));
        Frg = mat2gray(Frlog)
        figure(3),imshow(Frg,[]);

% with hanning window
        w_1=hanning(M);
        w_2=hanning(N);
        w=w_1*w_2';
        %fft transform    
        F=fftshift(fft2(im2double(I2).*w));
        Flog = log(1+abs(F));
        Fg = mat2gray(Flog)
        figure(4),imshow(Fg,[]);
%        imtool(Fg)
%        improfile


        SE = strel('disk',strel_,0);
        FgSE = imclose(Fg,SE);
%         figure(5), imshow(FgSE, [])
        background= imopen(FgSE, strel('disk',strel_));
%          figure(6), imshow(background)
        FgSE1 = FgSE-background;
        figure(7), imshow(FgSE1,[])
%         saveas(fg, 'fg.jpg');

%  threshold 0.55
%          Fgth=im2bw(Fg,0.52)
%         t=graythresh(Fg)
%         Fgth=im2bw(Fg,t);
%         figure(4),imshow(Fgth,[]);  

        
         c = reshape(FgSE1,1,[]);
        
        X=[X;c];
    end
end
