%%
%第一部分：初步ROI提取
clc; close all; clear all; 

I=imread('E:\毕业设计全部资料\编程工作\测试图片\测试样本图像\数字\2.jpg');              %从指定位置读取图片 
figure;
imshow(I);                         %显示图片
a=size(I,1);                                       %获取图像高度
b=size(I,2);                                       %获取图像宽度
im=imcrop(I,[0,0,b,a*2/3]);

figure;image(im) ;                                    %显示获取的图像
% cd('E:\PS图片\jiantou');                         
% imwrite(im,'light.jpg');                      %保存新类型的图片

%%
%第二部分：基于颜色提取

B=im;
[m,n,d]=size(B); 
 
level=20;%设置阈值 
level2=80;%设置阈值 

%提取红分量
B=im;
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

subplot(2,2,2);imshow(Ba);title('提取红分量后');%显示提取红分量后的图 
% cd('E:\PS图片\jiantou');
% imwrite(r,'hong.jpg');
 
%提取绿分量，不满足阈值的变为黑色 
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
subplot(2,2,3);imshow(Bb);title('提取绿分量后'); 
%  cd('E:\PS图片\jiantou');
% imwrite(g,'lv.jpg');
 
%提取黄分量，不满足阈值的变为黑色  
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
subplot(2,2,4);imshow(Bc);title('提取黄色分量后');
% cd('E:\PS图片\jiantou');
% imwrite(b,'huang.jpg');

%%
%第三部分：图像灰度化、归一化、二值化

A=Bb;
%灰度化
a=rgb2gray(A);
figure;
subplot(2,2,1);imshow(A);title('原图');
subplot(2,2,2);imshow(a);title('灰度图');
cd('E:\PS图片\jiantou');
imwrite(a,'lvhui.jpg');

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
% cd('E:\PS图片\jiantou');
% imwrite(BWa,'lverzhi.jpg');

%%
%第四部分：箭头形状补充
se=strel('disk',1);
BW=imdilate(BWa,se);
figure;
imshow(BW);title('箭头形状补充');
% % cd('E:\PS图片\jiantou');
% % imwrite(BW,'lvbuchong.jpg');
% 
% se=strel('disk',2);
% erodedBW2=imerode(BW2,se);
% figure;
% imshow(erodedBW2);title('lvfushi');
% % cd('E:\PS图片\jiantou');
% % imwrite(erodedBW2,'lvfushi.jpg');

%%
%第五部分：外接矩形初步标记提取

%统计标注连通域
%使用外接矩形框选连通域，并使用形心确定连通域位置

[labeled,m] = bwlabel(BW);
stats=regionprops(labeled,'BoundingBox','Area','PixelList');
centroid = regionprops(labeled,'Centroid','Area','PixelList');
graindata=regionprops(labeled,'basic');
figure;
subplot(1,2,1);imshow(BW);title('标记结果');
for i=1:m
    rectangle('Position',[stats(i).BoundingBox],'LineWidth',2,'LineStyle','--','EdgeColor','r'),
    text(centroid(i,1).Centroid(1,1)-15,centroid(i,1).Centroid(1,2)-15, num2str(i),'Color', 'r') 
    area=stats(i).Area;
    area
     
   %基于面积比值的提取
    
     Area=graindata(i).BoundingBox(3)*graindata(i).BoundingBox(4);
     value=area/Area;
%      value
    if value<0.48|| value>0.68 
        pointList = stats(i).PixelList;                     %每个连通区域的像素位置
        rIndex=pointList(:,2);cIndex=pointList(:,1);
        pointList = stats(i).PixelList;                     %连通区域的像素坐标
        BW(rIndex,cIndex)=0;
    end
   
   %基于面积大小的提取
   
   if area<180|| area>350
        pointList = stats(i).PixelList;                     %每个连通区域的像素位置
        rIndex=pointList(:,2);cIndex=pointList(:,1);
        pointList = stats(i).PixelList;                     %连通区域的像素坐标
        BW(rIndex,cIndex)=0; 
   end  

end 


subplot(1,2,2);imshow(BW);title('提取结果');
% cd('E:\PS图片\jiantou');
% imwrite(BWa,'lvchutiqu.jpg');

%%
%第六部分：箭头指向的判断

[labeled,m] = bwlabel(BW);
stats=regionprops(labeled,'BoundingBox','Area','PixelList');
centroid = regionprops(labeled,'Centroid','Area','PixelList');
graindata=regionprops(labeled,'basic');
for i=1:m
%     rectangle('Position',[stats(i).BoundingBox],'LineWidth',2,'LineStyle','--','EdgeColor','r'),
%     text(centroid(i,1).Centroid(1,1)-15,centroid(i,1).Centroid(1,2)-15, num2str(i),'Color', 'r') 
%     area=stats(i).Area;
    M1=round(graindata(i).BoundingBox(1)+graindata(i).BoundingBox(3)/2);
    N1=round(graindata(i).BoundingBox(2)+graindata(i).BoundingBox(4)/2);
    M2=round(graindata(i).Centroid(1));
    N2=round(graindata(i).Centroid(2));
    if M2-M1>0 
        disp('箭头指向右方');
    elseif M2-M1<0
        disp('箭头指向左方');
    elseif N2-N1>0
         disp('箭头指向下方');
    elseif N2-N1<0
         disp('箭头指向上方');
    end  
end