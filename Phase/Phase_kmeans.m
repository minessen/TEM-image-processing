clear all;
close all;
clc;

% path0='Z:\[J3] Phase\Sen';
% path1=fullfile(path0,'image_1');
path0='E:\[J3] Phase\TEM image-Sen';
path1=fullfile(path0,'980-0.25-720-24');

I = imread(fullfile(path1,'28.tif'));

%dimensions of the image
[row, col]=size(I);
sq=min([row col])
I=imcrop(I,[0 0 sq sq]);
imshow(I,[])
% imtool(I)

%box Size 80
Size = 240;
%Hanning window size
M=Size;
N=Size;
%step size 40
step = 80;

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
        else
        j=sq-Size;  
        a=a+1;
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];
        end
    end
end

i=sq-Size;
for j=1:step:n_size+1+step
        if j <= n_size+1
        a=a+1;
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];
        else
        j=sq-Size;  
        a=a+1;
        %INF: a, ind of image, size, intial point
        INF=[INF;a ind Size i j];
        end
end


path2='C:\Users\liuse\CODE\TEM image Phase';
load(fullfile(path2,'980-0.25-720-24_28-240803.mat'));

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
%visualize the results
%plot
imshow(I,'InitialMagnification','fit')
title('fft pattern clustering')
hold on;
a=0.1;
% Choose the number of correct clusters 
cmap = hsv(NUM);


for k=1:size(INF,1)
    %read locations of the filter box
    Size=INF(k,3);%box size
    p0=[INF(k,4) INF(k,5)];%%inital point of the box
    c=[p0(1) p0(2); p0(1)+Size p0(2)+Size];%coners of the box
    % I= imresize(I, 0.3);
    color=[cmap(idx(k),:) a];
    rectangle('Position', [c(1,1) c(1,2) Size Size], 'FaceColor',color ,'EdgeColor', color)%# Plot each column with a different color
    
    hold on;
    
    pause(0.1)
end
saveas(fig1, 'fig_phase.jpg');

 figeva = figure();
 plot(eva);
% saveas(figeva, 'fig_eva.jpg')
