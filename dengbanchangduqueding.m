clc;
close all;
clear all;
%% 预处理
I=imread('E:\PS图片\48.jpg');
figure;
imshow(I);title('原图');
imshow(I);                         %显示图片
a=size(I,1);                                       %获取图像高度
b=size(I,2);                                       %获取图像宽度
im=imcrop(I,[0,0,b,a*2/3]);
figure;
image(im) ;                                    %显示获取的图像
cd('E:\PS图片');                         
imwrite(im,'light.jpg');                      %保存新类型的图片
%% 灰度化、直方图均衡化
%灰度化
a=rgb2gray(im);
figure;
subplot(1,2,1);imshow(im);title('原图');
subplot(1,2,2);imshow(a);title('灰度图');
cd('E:\PS图片');
imwrite(a,'hui.jpg');
J=histeq(a);
figure;
imshow(J);title('直方图均衡化');
figure;
subplot(1,2,1);imhist(a,64);title('原始图像直方图');
subplot(1,2,2);imhist(J,64);title('处理后图像直方图');

[m,n]=size(J);
for i=1:m
    for j=1:n
       if J(i,j)<55
           J(i,j)=0;
       else
           J(i,j)=255;
       end
    end
end
figure;
imshow(J);title('保留灯板');
    
%% 形态学处理     
se=strel('disk',4);
BW=~imclose(J,se);
figure;
subplot(1,2,1);imshow(J);title('原图');
subplot(1,2,2);imshow(BW);title('闭运算')

%% 外接矩形初步标记提取

%统计标注连通域

[l,m] = bwlabel(BW);
status=regionprops(l,'BoundingBox','Area','PixelList');
centroid = regionprops(l,'Centroid','Area','PixelList');
figure;
imshow(BW);title('标记结果');hold on;
for i=1:m
    rectangle('position',status(i).BoundingBox,'LineWidth',2,'LineStyle','--','EdgeColor','r'),
    text(centroid(i,1).Centroid(1,1)-15,centroid(i,1).Centroid(1,2)-15, num2str(i),'Color', 'r') 
    area=status(i).Area;

   if area<1000||area>1300
        pointList = status(i).PixelList;                     %每个连通区域的像素位置
        rIndex=pointList(:,2);cIndex=pointList(:,1);
        pointList = status(i).PixelList;                     %连通区域的像素坐标
       BW(rIndex,cIndex)=0; 
  end

end 
I=BW;
figure;
imshow(I);title('提取结果');hold on;