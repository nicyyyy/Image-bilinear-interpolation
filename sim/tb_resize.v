`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/23 17:08:47
// Design Name: 
// Module Name: tb_resize
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_resize(

    );
    reg clk;
    reg rst_n;
    reg in_data_en;
    reg [7:0] data_in;
    reg in_H_SYNC;
	reg in_V_SYNC;
    reg [9:0] width_in;
    reg [9:0] height_in;
    
    wire [7:0] data_out;
    wire o_data_en;
    wire o_H_SYNC;
    wire o_V_SYNC;

	//test_port
	wire row_data_en_o;
	wire [7:0] row_inter_data_o;
    resize_bilinear_top resize_bilinear_top_init(
        .clk(clk),
        .rst_n(rst_n),
        .in_data_en(in_data_en),
        .data_in(data_in),
        
        .width_in(width_in),
        .height_in(height_in),
        
        .data_out(data_out),
        .o_data_en(o_data_en),
        .o_H_SYNC(o_H_SYNC), 
        .o_V_SYNC(o_V_SYNC),

		//test port
		.row_data_en_o(row_data_en_o),
		.row_inter_data_o(row_inter_data_o) 
    );
    parameter period = 200;
    initial
	begin
		clk = 1;
		rst_n = 0;
		height_in = 360;
		width_in = 640;
		
		#(period);
		rst_n = 1;
	end
    //?
	reg [7:0] temp8b;
	integer fd1;
	integer stop_flag;
	integer pixel_cnt;
	integer row_cnt;
	initial
	begin
		
		in_H_SYNC = 0;
		in_V_SYNC = 0;
		in_data_en = 0;
		stop_flag = 0;
		pixel_cnt = 0;
		row_cnt = 0;
		fd1 = $fopen("E:/my_verilog/resize_bilinear/prev_t.bin", "rb");
		
		#(period*2);
		in_data_en = 1;
		while(pixel_cnt < 230400)
		begin
			$fread(temp8b, fd1, , 1);
			data_in = temp8b;
			pixel_cnt = pixel_cnt + 1;
			
			if(row_cnt == 640)
			begin
				row_cnt = 1;
				in_data_en = 0;
				#(period*(640 + 1280));
				in_data_en = 1;
			end
			else
				row_cnt = row_cnt + 1;
			#(period);
		end
		in_data_en = 0;
		$fclose(fd1);
		stop_flag = 1;
		pixel_cnt = pixel_cnt + 1;
		#(period);
	end
	
	//保存行插值图片
	integer fds;
	initial
	begin
		fds = $fopen("E:/my_verilog/resize_bilinear/resized.bin", "wb");
		
		while(1)
		begin
			if(o_data_en == 1)
			begin	
				$fwrite(fds,"%02x",data_out);						
			end
			else if(o_data_en == 0 && stop_flag == 1)
				begin
					$fclose(fds);
					$stop;
				end
			#(period);
		end
	end
	
	always
	begin
		#(period/2);
		clk = ~clk;
	end
endmodule
