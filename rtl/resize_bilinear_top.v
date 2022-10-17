`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/23 16:38:01
// Design Name: 
// Module Name: resize_bilinear_top
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


module resize_bilinear_top(
    input clk,
    input rst_n,
    input in_data_en,
    input [7:0] data_in,
    
    input [9:0] width_in,
    input [9:0] height_in,
    
    
    output [7:0] data_out,
    output o_data_en,
    output o_H_SYNC,
    output o_V_SYNC,

    //test port
    output row_data_en_o,
    output [7:0] row_inter_data_o
    );
    wire [9:0] rd_row_addr;
    wire [7:0] row_pexil_out;
    row_buf row_buf_init(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .in_data_en(in_data_en),
        .width(width_in),
        .rd_row_addr(rd_row_addr),
        .row_pexil_out(row_pexil_out)
    );
    wire [10:0] row_cnt;
    wire row_data_en;
    wire [7:0] row_inter_data;
    wire o_data_en_r;
    row_interplation row_interplation_init(
        .clk(clk),
        .rst_n(rst_n),
        .in_data_en(in_data_en),
        .width(width_in),
        .rd_row_addr(rd_row_addr),
        .row_pexil_out(row_pexil_out),
        // .o_data_en(row_data_en),
        .row_inter_data(row_inter_data),
        .row_cnt(row_cnt),
        .o_data_en_r_o(o_data_en_r)
    );

    reg [5:0] o_data_en_shift;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            o_data_en_shift <= 0;
        else
            o_data_en_shift <= {o_data_en_shift[4:0],o_data_en_r};
    end
    assign row_data_en = o_data_en_shift[4];


    //test port
    assign row_inter_data_o = row_inter_data;
    assign row_data_en_o = row_data_en;
    
    wire [9:0]col_cnt;
    wire [7:0] buf1_data_out;
    wire [7:0] buf2_data_out;
    // wire [7:0] buf3_data_out;
    wire colbuf_data_en;
    col_buf col_buf_init(
        .clk(clk),
        .rst_n(rst_n),
        .in_data_en(row_data_en),
        .row_inter_data(row_inter_data),
        // .row_cnt(row_cnt),
        
        // .col_cnt(col_cnt),
        .buf1_data_out(buf1_data_out),
        .buf2_data_out(buf2_data_out),
        // .buf3_data_out(buf3_data_out),
        .o_data_en(colbuf_data_en)
    );
    
    
    col_interplation col_interplation_inti(
        .clk(clk),
        .rst_n(rst_n),
        .in_data_en(colbuf_data_en),
        .row_cnt(row_cnt),
        .buf1_data_out(buf1_data_out),
        .buf2_data_out(buf2_data_out),
        // .buf3_data_out(buf3_data_out),
        .col_inter_data(data_out),
        .o_data_en(o_data_en),
        .o_H_SYNC(o_H_SYNC),
        .o_V_SYNC(o_V_SYNC)
    );
endmodule
