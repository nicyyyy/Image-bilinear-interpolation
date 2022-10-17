% xy = zeros(720*2,1280*2);
% for i = 1:720
%     for j = 1:1280
%        xy(i,j) =   
%     end
% end
x = 1:1:720*2;
y = 1:1:1280*2;
x = x/2 + 0.5;
y = y/2 + 0.5;
close all;
%%
fip=fopen('E:\my_verilog\prev.bin','rb');
[prev,num]=fread(fip,[720 1280],'uint8');%inf表示读取文件中的所有数据，[M,N]表
[m n]=size(prev);
%%
t = [1,2;3,4];
tt = imresize(uint8(t),[4,4],'bilinear');
%%
%系数
x1 = 1:1:1280;
y1 = 1:1:720*2;

x2 = floor((x1+0.5)/2) - 1;
%%
% %缩小图像并保存为按行输入
prev_half = imresize(uint8(prev),[m/2,n/2],'bilinear');
% prev_save = reshape(prev_half',[],1);
% fids = fopen("E:\my_verilog\resize_bilinear\prev_t.bin",'wb');
% fwrite(fids,prev_save,'uint8');
% fclose(fids);

%%
[m n]=size(prev_half);
prev_resized = imresize(uint8(prev_half),[m,n*2],"bilinear");
figure
imshow(prev_resized)

%%
%行插值计算后的图片
fip_row=fopen('E:\my_verilog\resize_bilinear\resized.bin','rb');
[my_resized,num]=fscanf(fip_row,'%02x',[1280 inf]);%inf表示读取文件中的所有数据，[M,N]表
my_resized = my_resized';
% row_resized = row_resized(1:360,1:1280);
figure
imshow(uint8(my_resized))


%%
prev_col_resized = imresize(uint8(prev_half),[m*2,n*2],"bilinear");
%
df = abs(uint8(my_resized) - prev_col_resized);
mean(mean(df))
max(max(df))

%%
m_row_resize = zeros(360,1280);
for i=1:360
    for j=1:1280
       if(j == 1)
           m_row_resize(i,j) = prev_half(i,j);
       elseif(j == 1280)
            m_row_resize(i,j) = prev_half(i,1280/2);
       else
           if(mod(j,2) == 0)
                m_row_resize(i,j) = round(0.75*prev_half(i,floor((j + 0.5)/2))) + round(0.25*prev_half(i,floor((j + 0.5)/2) + 1));
           else
                m_row_resize(i,j) = round(0.25*prev_half(i,floor((j + 0.5)/2))) + round(0.75*prev_half(i,floor((j + 0.5)/2) + 1));
           end
       end
    end
end

m_resize = zeros(720,1280);
for i =1:720
   for j = 1:1280
      if(i == 1)
          m_resize(i,j) = m_row_resize(i,j);
      elseif(i == 720)
          m_resize(i,j) = m_row_resize(360,j);
      else
          if(mod(i,2) == 0)
              m_resize(i,j) = round(0.75*m_row_resize(floor((i + 0.5)/2),j)) + round(0.25*m_row_resize(floor((i + 0.5)/2) + 1,j));
          else
              m_resize(i,j) = round(0.25*m_row_resize(floor((i + 0.5)/2),j)) + round(0.75*m_row_resize(floor((i + 0.5)/2) + 1,j));
          end
      end
   end
end

%%
%结果与自己实现的算法对比
dfm = abs(m_resize - my_resized);
max(max(dfm))