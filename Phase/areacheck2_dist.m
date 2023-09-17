clear all;close all;clc;
currentFolder = pwd;
path0=fullfile(currentFolder,'dist.xlsx');
[allCentroids, text1]=xlsread(path0,'Sheet1');

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
