clear all;
close all;
clc;

% path0='Z:\[J3] Phase\Sen';
% path1=fullfile(path0,'image_1');
path0='E:\[J3] Phase\Image small';
path1=fullfile(path0,'image_small2');
I = imread(fullfile(path1,'Scanning Search2_0048.tif'));

%dimensions of the image
[rowI, colI]=size(I);
sq=min([rowI colI])
I=imcrop(I,[0 0 sq sq]);
imshow(I,[])
% imtool(I)

path2='E:\[J3] Phase\Sen code\Quadtree';
load(fullfile(path2,'Scanning search2_0048.mat'));

[dim, ~] = size(sparce_mtx);
%spatial info
strel_ = 3;

INF=[];
a=0;
X=[];

for i = 1:dim
    for j = 1:dim
        square = sparce_mtx(i, j);
        if square ~= 0 && square ~= 1
        
        Size = sparce_mtx(i, j);
        a=a+1;
        %INF: a, size, intial point
        INF=[INF;a Size i j];
        
        I2=imcrop(I,[i j Size-1 Size-1]) 
        figure(2), imshow(I2,[])

% % without Hann window
%       F=fftshift(fft2(I2));   
%       Flog = log(1+abs(F));
%       Fg = mat2gray(Flog)
% %     figure(2),imshow(Fg,[]);

% with Hann window
        w_1=hanning(Size);
        w_2=hanning(Size);
        w=w_1*w_2';
        %fft transform        
        F=fftshift(fft2(im2double(I2).*w));
        Flog = log(1+abs(F));
        Fg = mat2gray(Flog)  
        figure(3), imshow(Fg,[]);  

% with background subtraction
        SE = strel('disk',strel_,0);
        FgSE = imclose(Fg,SE);
%       figure(4), imshow(FgSE, [])
        background= imopen(FgSE, strel('disk',strel_));
%       figure(5), imshow(background)
        FgSE1 = FgSE-background;
        figure(6), imshow(FgSE1,[])
        
        scal = 64/Size;
        FgSE2 = imresize(FgSE1,scal,'lanczos2'); % 'bilinear','bicubic'
        figure(7), imshow(FgSE2,[])      
        
        c = reshape(FgSE2,1,[]); 
        X=[X;c];      
        
        end
    end
end


% % Gap statistics
% eva = evalclusters(X,'kmeans','gap','KList',[1:5]);
% %NUM =eva.OptimalK;
% [h, NUM] = max(eva.CriterionValues);

% BIC criterion
NUM=2;

% k-means model
[idx,C] = kmeans(X,NUM,'Distance','cosine','Replicates',5);

fig1 = figure();
x0=10;
y0=10;
width=500;
height=480;
set(gcf,'units','points','position',[x0,y0,width,height])
% %visualize the results
% %plot
imshow(I,'InitialMagnification','fit')
title('fft pattern clustering')
hold on;
a=0.5;
% Choose the number of correct clusters 
cmap = hsv(NUM);

for k=1:size(INF,1)
    %read locations of the filter box
    
    Size=INF(k,2);%box size
    p0=[INF(k,3) INF(k,4)];%%inital point of the box
    c=[p0(1) p0(2); p0(1)+Size p0(2)+Size];%coners of the box
    % I= imresize(I, 0.3);
    color=[cmap(idx(k),:) a];
    rectangle('Position', [c(1,2) c(1,1) Size Size], 'FaceColor',color ,'EdgeColor', color)%# Plot each column with a different color
    hold on;
    pause(0.1)
    
end

% saveas(fig1, 'fig_phase.jpg');

% figeva = figure();
% plot(eva);
% saveas(figeva, 'fig_eva.jpg')
