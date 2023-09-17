clear all;
close all;
clc;

% path0='Z:\[J3] Phase\Sen';
% path1=fullfile(path0,'image_1');
path0='E:\[J3] Phase\TEM image-Sen';
path1=fullfile(path0,'1020-720 24');
I = imread(fullfile(path1,'35.tif'));

%dimensions of the image
[rowI, colI]=size(I);
sq=min([rowI colI])
I=imcrop(I,[0 0 sq sq]);
imshow(I,[])
% imtool(I)

path2='E:\[J3] Phase\Sen code\Quadtree';
load(fullfile(path2,'1020-720 24_35-64.mat'));

[dim, ~] = size(sparce_mtx);
%spatial info
strel_ = 3;

INF=[];
a=0;
Val=[];
Sz=[];

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

% without Hann window
      F=fftshift(fft2(I2));   
      Flog = log(1+abs(F));
      Fg = mat2gray(Flog)
      figure(3),imshow(Fg,[]);

% % with Hann window
%         w_1=hanning(Size);
%         w_2=hanning(Size);
%         w=w_1*w_2';
%         %fft transform        
%         F=fftshift(fft2(im2double(I2).*w));
%         Flog = log(1+abs(F));
%         Fg = mat2gray(Flog)  
%         figure(3), imshow(Fg,[]);  
% % with background subtraction
%         SE = strel('disk',strel_,0);
%         FgSE = imclose(Fg,SE);
% %       figure(4), imshow(FgSE, [])
%         background= imopen(FgSE, strel('disk',strel_));
% %       figure(5), imshow(background)
%         FgSE1 = FgSE-background;
%         figure(6), imshow(FgSE1,[])
        
        Ig = im2uint8(Fg)
        value = std2(Ig)
    
    Sz = [Sz; Size];         
    Val = [Val; value];
        end
    end
end

[sortSz, idx] = sort(Sz)
sortVal = Val(idx);
[Sdim, ~] = size(sortSz);

% C = unique(sortSz,'sorted')
% [Cdim, ~] = size(C);
% Uni = []
% UniT = []
% for i = 1:Cdim
%     nj=0;
%     Cval=0;
%     for j = 1:Sdim
%         if C(i) == sortSz(Sdim)
%            Cvaldim = Val(Sdim);
%            nj=nj+1;
%            Cval = Cval + Cvaldim
%         end
% 
%     end
%     Uni = [C(i) Cval, nj]   
%     UniT = [UniT; Uni]
% end

