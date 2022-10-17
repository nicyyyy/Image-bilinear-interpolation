# Image-bilinear-interpolation
Image enlargement on FPGA; Ram control; Simulation for VGA timing

将像素点的插值分为两个步骤：先对行方向插值，再对列方向插值。即先将图像插值得到360*1280，再插值到720*1280
在行方向的插值中，设插值后的图像像素点的坐标为y，则需要用到的原图中的坐标为(y+0.5)/2向上和向下取整。例如坐标y=3，(3+0.5)/2=1.75，那么用到的便是原图中y坐标为1和2的点，权重分别为(2-1.75)和(1.75-1)。通过下表坐标与系数的观察可以发现，除了第一个特殊位置外，其余系数均可以通过坐标奇偶性判断，即判断坐标寄存器最低位。列方向插值原理相同。

![image](https://user-images.githubusercontent.com/57220819/196198332-cc9e3ca3-83fe-4fa6-b877-ffb1cec8b57a.png)

在从内存中读取图像时，每一行图像结束后需要暂停640+1280个周期，在读取行像素和暂停时间的前640个周期中，完成行方向的插值，在读取行像素和暂停时间的前640+1280个周期中使用两行图像完成列方向的插值。

系统原理图如图所示，包含row_buf、row_interplation、col_buf和col_interplation四个基本模块。
![image](https://user-images.githubusercontent.com/57220819/196198400-578ac93b-9e07-4576-9860-46b807eccb13.png)


row_buf模块：

输入图像根据一个宽度计数器产生地址，通过写端口存入行缓存ram中。进入每行后的暂停时间时，ram暂停写入。
用到的ram配置为：真双端口，深度640，数据宽度8bit，无输出寄存器。Port a用于缓存的数据写入，port b用于读出缓存数据。

row_interplation模块：
根据插值后图像中的宽度寄存器生成读行缓存ram地址，根据寄存器数据的奇偶性判断插值权重。对于插值权重系数为0.75的像素，计算公式如下，等价于pixel*3后再除以4，同时对结果四舍五入

((pixel≪1)+pixel+2)≫2

对于插值系数为0.25的像素，计算公式如下：

(pixel+2)≫2

col_buf模块：

模块中使用了两个深度为1280的移位寄存器，用于缓存行插值模块输出的插值结果。在从内存中读取一行图像和之后暂停的前640个周期中，两个寄存器构成级联的移位寄存器，输出插值所用的像素值并完成一行图像的插值。由于相邻两行插值中用到的图像行坐标相同，因此在暂停时间的后1280个周期中，将两个缓存寄存器自身循环移位。
![image](https://user-images.githubusercontent.com/57220819/196198545-f57404a0-1511-4e7b-ad4b-0489c34a1e2b.png)

col_interplation模块：

插值计算方式与行插值模块相同。
