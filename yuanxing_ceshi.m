%%
%第一部分：初步ROI提取
clc; close all; clear all; 

I=imread('E:\毕业设计全部资料\编程工作\测试图片\测试样本图像\圆形\1.jpg');              %从指定位置读取图片 
figure;
imshow(I); title('原图');                          %显示图片
a=size(I,1);                                       %获取图像高度
b=size(I,2);                                       %获取图像宽度
im=imcrop(I,[0,0,b,a*2/3]);

figure;image(im) ; title('基于位置信息提取');       %显示获取的图像
% cd('E:\PS图片\yuanxing');                         
% imwrite(im,'light.jpg');                           %保存新类型的图片

%%
%第二部分：基于颜色提取（红绿黄三色提取）

B=im;
[m,n,d]=size(B); 
 
level=20;                                            %设置阈值 
level2=80;                                           %设置阈值 
 
%提取红分量
for i=1:m 
    for j=1:n 
        if((B(i,j,1)-B(i,j,2)<level2)||(B(i,j,1)-B(i,j,3)<level2)) 
 
            B(i,j,1)=0; 
            B(i,j,2)=0; 
            B(i,j,3)=0; 
        end 
    end 
end 
Ba=B; 
figure; 
subplot(2,2,1);imshow(im);title('原图像'); 

subplot(2,2,2);imshow(Ba);title('提取红分量后');     %显示提取红分量后的图 
% cd('E:\PS图片\yuanxing');
% imwrite(r,'hong.jpg');
  
%提取绿分量
B=im;
for i=1:m 
    for j=1:n 
        if((B(i,j,2)-B(i,j,1)<level)||(B(i,j,2)-B(i,j,3)<level)) 
            B(i,j,1)=0; 
            B(i,j,2)=0; 
            B(i,j,3)=0; 
        end 
    end 
end 
Bb=B;
subplot(2,2,3);imshow(Bb);title('提取绿分量后');      %显示提取绿分量后的图 
% cd('E:\PS图片\yuanxing');
% imwrite(g,'lv.jpg');
 
%%提取黄分量
B=im;
for i=1:m 
    for j=1:n 
        if((B(i,j,1)-B(i,j,3)<level2)||(B(i,j,2)-B(i,j,3)<level2))         
            B(i,j,1)=0; 
            B(i,j,2)=0; 
            B(i,j,3)=0; 
        end 
    end 
end 
Bc=B; 
subplot(2,2,4);imshow(Bc);title('提取黄色分量后');     %显示提取黄分量后的图 
% cd('E:\PS图片\yuanxing');
% imwrite(b,'huang.jpg');

%%
%第三部分：图像灰度化、归一化及二值化

A=Ba;
%灰度化
a=rgb2gray(A);
figure;
subplot(2,2,1);imshow(A);title('原图');
subplot(2,2,2);imshow(a);title('灰度图');
% cd('E:\PS图片\yuanxing');
% imwrite(a,'honghui.jpg');

%归一化
originalMinValue = min(min(min(a)));
originalMaxValue = max(max(max(a)));
originalRange = originalMaxValue - originalMinValue;
dblImageS1 = double(1. * (a - originalMinValue) / originalRange);

subplot(2,2,3);imshow(dblImageS1);title('归一化');

%二值化
level = graythresh(dblImageS1);
BWa=im2bw(dblImageS1,level);

subplot(2,2,4);imshow(BWa);title('二值化');
% cd('E:\PS图片\yuanxing');
% imwrite(BWa,'hongerzhi.jpg');

%%
%第四部分：形态学处理
se=strel('disk',4);
BW=imclose(BWa,se);

figure;
subplot(1,2,1);imshow(BWa);title('二值化');
subplot(1,2,2);imshow(BW);title('开运算');

% cd('E:\PS图片\yuanxing');
% imwrite(BW,'hongkai.jpg');

%%
%第五部分：连通区域标记提取


[mark_image,num] = bwlabel(BW,8);

stats=regionprops(mark_image,'BoundingBox','Area','PixelList');
centroid=regionprops(mark_image,'Centroid','Area','PixelList');
graindata=regionprops(mark_image,'basic');

figure;
subplot(2,1,1);imshow(mark_image);title('标记后的图像');
for i=1:num
    rectangle('Position',[stats(i).BoundingBox],'LineWidth',1,'LineStyle','--','EdgeColor','r'),
    text(centroid(i,1).Centroid(1,1)-15,centroid(i,1).Centroid(1,2)-15, num2str(i),'Color', 'r') 
    area=stats(i).Area;
   
    %基于面积比值的提取
     Area=graindata(i).BoundingBox(3)*graindata(i).BoundingBox(4);
     value=area/Area;
    if value<0.7 || value>0.85    
        pointList = stats(i).PixelList;                       %每个连通区域的像素位置
        rIndex=pointList(:,2);cIndex=pointList(:,1);
        pointList = stats(i).PixelList;                       %连通区域的像素坐标
        BW(rIndex,cIndex)=0;
    end
   
   %基于面积大小的提取 
   if area<250 || area>500
        pointList = stats(i).PixelList;                       %每个连通区域的像素位置
        rIndex=pointList(:,2);cIndex=pointList(:,1);
        pointList = stats(i).PixelList;                       %连通区域的像素坐标
        BW(rIndex,cIndex)=0; 
   end  
end

subplot(2,1,2);imshow(BW);title('面积提取后');

% cd('E:\PS图片\yuanxing');
% imwrite(BW,'result.jpg')
