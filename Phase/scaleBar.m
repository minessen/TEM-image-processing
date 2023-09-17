%% Read the scale and the Image
% input:  image
% output : scale, pixels and text



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
