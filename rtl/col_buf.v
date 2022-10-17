`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/23 13:55:51
// Design Name: 
// Module Name: col_buf
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


module col_buf(
    input clk,
    input rst_n,
    input in_data_en,
    input [7:0] row_inter_data,
    // input [10:0] row_cnt,
    // output reg [9:0] col_cnt,
    output [7:0] buf1_data_out,
    output [7:0] buf2_data_out,
    // output [7:0] buf3_data_out,
    output reg o_data_en    
//    input [10:0] col_buf3_rd_addr,
//    output [7:0] col_buf3_rd_data,
//    output [7:0] col_buf1_rd_data
    );
    parameter reg_size = 8*1280;
    reg [reg_size - 1:0] shift_buf1,//级联的移位寄存器，当data_en = 0时，每个寄存器自身循环移位
                         shift_buf2;
                        //  shift_buf3;

    
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            shift_buf1 <= 0;
            shift_buf2 <= 0;
            // shift_buf3 <= 0;
        end
        else
        begin
            if(in_data_en)
            begin
                shift_buf1 <= {shift_buf1[reg_size - 8 -1 : 0],row_inter_data};
                shift_buf2 <= {shift_buf2[reg_size - 8 -1 : 0],shift_buf1[reg_size - 1 : reg_size - 8]};
                // shift_buf3 <= {shift_buf3[reg_size - 8 -1 : 0],shift_buf2[reg_size - 1 : reg_size - 8]};
            end
            else
            begin
                shift_buf1 <= {shift_buf1[reg_size - 8 -1 : 0],shift_buf1[reg_size - 1 : reg_size - 8]};
                shift_buf2 <= {shift_buf2[reg_size - 8 -1 : 0],shift_buf2[reg_size - 1 : reg_size - 8]};
                // shift_buf3 <= {shift_buf3[reg_size - 8 -1 : 0],shift_buf3[reg_size - 1 : reg_size - 8]};
            end
        end
    end
    assign buf1_data_out = shift_buf1[7:0];
    assign buf2_data_out = shift_buf2[7:0];
    // assign buf3_data_out = shift_buf3[7:0];
    
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            o_data_en <= 0;
        else 
            o_data_en <= in_data_en;
    end
    // always@(posedge clk or negedge rst_n)
    // begin
    //     if(~rst_n)
    //         col_cnt <= 1;
    //     else if(row_cnt == 1280)
    //         col_cnt <= col_cnt + 1;
    //     else;
    // end

    // always@(*)
    // begin
    //     if(~rst_n)
    //         o_data_en = 0;
    //     else if(col_cnt >= 3)
    //         o_data_en = 1;
    //     else
    //         o_data_en = 0;
    // end
endmodule
