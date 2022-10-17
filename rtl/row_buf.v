`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/21 16:49:37
// Design Name: 
// Module Name: matrix_2x2_8bit
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


module row_buf(
    input clk,
    input rst_n,
//    input in_H_SYNC,
//    input in_V_SYNC,
    input [7:0] data_in,
//    input [9:0] wr_row_addr,
	input in_data_en,
	input [9:0] width,
//	input [10:0] height,
//	output reg o_H_SYNC,
//    output reg o_V_SYNC,
//	output reg o_data_en,
	
	input [9:0] rd_row_addr,
	output [7:0] row_pexil_out
    );
    //输入延迟一个周期
    reg [7:0] data_in_r1;
    // reg [9:0] rd_row_addr_r1;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            data_in_r1 <= 0;
            // rd_row_addr_r1 <= 0;
        end
        else
        begin
            data_in_r1 <= data_in;
            // rd_row_addr_r1 <= rd_row_addr;
        end
    end
    // reg in_data_en_r1;
    // always@(posedge clk or negedge rst_n)
    // begin
    //     if(~rst_n)
    //         in_data_en_r1 <= 0;
    //     else
    //         in_data_en_r1 <= in_data_en;
    // end


    reg [9:0] wr_row_addr;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            wr_row_addr <= 0;
        else
        begin
            if(in_data_en)
            begin
                if(wr_row_addr < (width - 1))
                     wr_row_addr <= wr_row_addr + 1;
                else                  
                    wr_row_addr <= 0;
            end      
            else
                wr_row_addr <= wr_row_addr;
        end
    end
    //写地址延迟一个周期
    reg [9:0] wr_row_addr_r1,
              wr_row_addr_r2;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            wr_row_addr_r1 <= 0;
            wr_row_addr_r2 <= 0;
        end
        else
        begin
            wr_row_addr_r1 <= wr_row_addr;
            wr_row_addr_r2 <= wr_row_addr_r1;
        end
    end
    wire [9:0] rd_row_addr_r1;
    assign rd_row_addr_r1 = rd_row_addr <= (width - 1) ?  rd_row_addr : 10'dz;

    //portA: wirte date, portB: read data
   row_ram_640x8bit row_ram_640x8bit_init (
  .clka(clk),    // input wire clka
  .ena(1),      // input wire ena
  .wea(1),      // input wire [0 : 0] wea
  .addra(wr_row_addr_r1),  // input wire [9 : 0] addra
  .dina(data_in_r1),    // input wire [7 : 0] dina
//  .douta(douta),  // output wire [7 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(1),      // input wire enb
  .web(0),      // input wire [0 : 0] web
  .addrb(rd_row_addr_r1),  // input wire [9 : 0] addrb
//  .dinb(dinb),    // input wire [7 : 0] dinb
  .doutb(row_pexil_out)  // output wire [7 : 0] doutb
);
    
endmodule
