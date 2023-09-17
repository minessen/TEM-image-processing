clear all;
close all;
clc;
 
% rect = [95.5100000000000,49.5100000000000,503.980000000000,504.980000000000];

% read the original image
RGB = imread('NMF_48-90.tif');

% figure();
% imshow(RGB,[]);

%% color maps segmentation  

HSV = rgb2hsv(RGB);
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);

figure();
subplot(1,3,1), imshow(H,[]), title('H');
subplot(1,3,2), imshow(S,[]), title('S');
subplot(1,3,3), imshow(V,[]), title('V');

%% segmentation
% Manual segmentation 
Hmask = (H<0.528);  % twin 2: 0.515 & |  (H>0.75) | (H<0.25)   (H>0.01) & (H<0.761);
figure(),imshow(Hmask,[])
% Vmask = (V>0.52);  % twin 1: 0.52  precip: 
% figure(),imshow(Vmask,[])
Result = Hmask % Hmask & Vmask
figure(),imshow(Result,[])

% % automatic segmentation
% t=graythresh(V)
% Hmask=im2bw(V,t);
% figure(),imshow(Hmask,[]); 
% Result = Hmask % Hmask & Vmask;

Result = imopen(Result, strel('disk',5));
Result = imclose(Result, strel('disk',5));

% % smooth the stair shape
h = fspecial('disk',5);
Result = imfilter(Result,h);
%Result = ~Result;
figure(), imshow(Result,[]);

% clean the corner white region
[rowC,colC] =size(Result);
A = ones(rowC,colC);
%A(1:5, 1:5)=0;
%A(rowC-5:rowC, 1:5)=0;
%A(1:5, colC-5:colC)=0;
%A(rowC-5:rowC, colC-5:colC)=0;
% figure(), imshow(A,[]);

Result = Result.*A;
figure(), imshow(Result,[]);title('result');

%% caputure the scale bar

path0='E:\[J3] Phase\Image small\image_small2';
i = imread(fullfile(path0,'Scanning Search2_0048.tif'));
[v, u, k] = scaleBar(i);
v = str2num(v);

[row,col] = size(i);
sq = min([row col])
sqC = max([rowC colC])
RatIm = sq/sqC;
RatRu = v/k;

%% calculate statistical information

[L, n] = bwlabel(Result);
blobs = regionprops(L,'Area','BoundingBox','Centroid','ConvexHull','MajorAxisLength','MinorAxisLength','Orientation');
% areas = cat(1,patcs(:).Area);
% [Value, index] = max(areas)

figure(), imshow(RGB,[])
for i = 1:n
%     rectangle('Position', blobs(i).BoundingBox, 'EdgeColor', 'r');
    x0 = blobs(i).Centroid(1);
    y0 = blobs(i).Centroid(2);
    line([x0-5 x0+5], [y0 y0], 'Color', 'r');
    line([x0 x0], [y0-5 y0+5], 'Color', 'r');
    text(x0,y0+8,sprintf('%d',i),'Color','red','FontSize',18,'FontWeight','bold','HorizontalAlignment','center','VerticalAlignment','middle');
    major = blobs(i).MajorAxisLength/2;
    minor = blobs(i).MinorAxisLength/2;
    ang = -blobs(i).Orientation*pi/180;
    line([x0-major*cos(ang) x0+major*cos(ang)],[y0-major*sin(ang) y0+major*sin(ang)], 'Color', 'k');
    line([x0-minor*cos(ang+pi/2) x0+minor*cos(ang+pi/2)], [y0-minor*sin(ang+pi/2) y0+minor*sin(ang+pi/2)], 'Color', 'k');    
end
hold on

allAreas = cat(1,blobs(:).Area)*(RatIm*RatRu)^2; % get all Area
allCentroids = cat(1,blobs(:).Centroid)*RatIm*RatRu; % get all centroids
allMajorAxisLength = cat(1,blobs(:).MajorAxisLength)*RatIm*RatRu; % get all major axis length
allMinorAxisLength = cat(1,blobs(:).MinorAxisLength)*RatIm*RatRu; % get all major axis length
allOrientation = cat(1,blobs(:).Orientation); % get all orientation

%% calculate the interparticle distance

cnm = size(allCentroids,1);
dim = ones (1, cnm);
allCen_ = mat2cell(allCentroids, dim) % convert the matrix into cell
allCentroids_ = allCentroids;
kdd = [];
distd = [];
for ck = 1:cnm
    allCentroids_(ck,:) = [];
    [kd, dist]= dsearchn(allCentroids_, allCen_{ck})
    kdd = [kdd; kd]
    distd = [distd; dist]
    allCentroids_ = allCentroids;
end

%% calculate fraction and area and visualization

Fraction1 = nnz(Result)/(nnz(~Result)+ nnz(Result));
Fraction2 = nnz(~Result)/(nnz(~Result)+ nnz(Result));
Area1 = Fraction1 * sq*sq * (v/k)^2; %2048  4096
Area2 = Fraction2 * sq*sq * (v/k)^2;

% % Overlay
boundaries = bwboundaries(Result);
 for k=1:length(boundaries)
     b = boundaries{k};
     plot(b(:,2),b(:,1),'g','LineWidth',2);
 end
hold off

% text position (20,15) (20 35)  30,40 30,100   % num2str(u,'%0.2f')
label_str1 = ['Precipitates:' ' ' num2str(Area1,'%0.2f') ' ' 'nm^2' ' Fraction:' ' ' num2str(Fraction1)];
text(15,10,label_str1,'Color','yellow','FontSize',14,'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','middle');
hold on
label_str2 = ['Matrix:' ' ' num2str(Area2,'%0.2f') ' ' 'nm^2' ' Fraction:' ' ' num2str(Fraction2)];
text(20,25,label_str2,'Color','yellow','FontSize',14,'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','middle');
hold on



function [value, unit, k]=  scaleBar(I)
%crop image

imshow(I,[])
[x,y]=ginput(2);
x=round(x);
y=round(y);
Iruler = imcrop(I, [x(1) y(1) x(2)-x(1) y(2)-y(1)]);
imshow(Iruler)

imshow(I,[])
[xs,ys]=ginput(2);
xs=round(xs);
ys=round(ys);
Itext = imcrop(I, [xs(1) ys(1) xs(2)-xs(1) ys(2)-ys(1)]);
imshow(Itext)

% Is=I(2050:2115,770:1250);%scale info region
% Iruler=I(2050:2115,770:1070);%ruler
% Itext=I(2050:2115,1070:1250);%scale:value+unit
% imshow(Itext)

%count pixel on the ruler
ind=Iruler==255;
k=max(sum(ind,2));%pixel number on the ruler

%text recognition
results = ocr(Itext,'TextLayout','Block');
str = num2str(results.Text);

value = str(1:2); %str(1) 1:2
unit = str(4:5); %str(2:3) 4:5

%value = results.Words{1};
%unit = results.Words{2};
% wordBBox = results.WordBoundingBoxes(2,:);
%loc=[770 2050 510 60];
loc=[x(1) y(1) x(2)-x(1)+xs(2)-xs(1) y(2)-y(1)];
figure();
scale = strcat('Ruler: ',num2str(k),' px;', ' Scale: ',num2str(results.Text))
Iname = insertObjectAnnotation(I, 'rectangle', loc, scale,...
   'LineWidth',7, 'TextBoxOpacity',0.9,'FontSize',72,'TextColor','black'); 
imshow(Iname);
end
