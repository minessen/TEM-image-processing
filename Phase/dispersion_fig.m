clear all;close all;clc;
%1.read excel 
%dir: get all the filenames under current directory
currentFolder = pwd;
path0=fullfile(currentFolder,'dispersion.xlsx');
[num, text1]=xlsread(path0,'Sheet1');

x1 = num(:,1);
x2 = num(:,2);
y1 = num(:,3);
y2 = num(:,4);

figure
plot (x1, y1, 'Color', 'r')
% hold on
% scatter (x1, y1, 10,'r', 'filled')
ax1 = gca; % current axes
set(ax1, 'XColor', 'r', 'YColor', 'r')

ax2 = axes('Position',get(ax1, 'Position'),...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor', 'k', 'YColor', 'k');
plot(x2,y1,'Parent',ax2,'Color','k')