`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/22 16:34:40
// Design Name: 
// Module Name: row_interplation
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


module row_interplation(
    input clk,
    input rst_n,
    input in_data_en,
    input [9:0] width,
    
    input [7:0] row_pexil_out,
    output reg [9:0] rd_row_addr,
    output [10:0] row_cnt,
    
    //
    output o_data_en_r_o,
    //
    output o_data_en,
    output [7:0] row_inter_data
    );
    reg [10:0] rowx2; //resie后的宽度
    reg [10:0] rowx2_cnt;//计数器
    
    always@(*)
    begin
        rowx2 = width << 1;
    end

    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            rowx2_cnt <= 1;
        else
        begin
            if(rowx2_cnt < width)
            begin
                if(in_data_en)
                    rowx2_cnt <= rowx2_cnt + 1;
                 else
                    rowx2_cnt <= rowx2_cnt;
            end
            else
            begin
                if(rowx2_cnt < rowx2)
                    rowx2_cnt <= rowx2_cnt + 1;
                 else
                    rowx2_cnt <= 1;
            end
        end
    end
     //延迟一个周期开始读buf，等待数据进入buf
    // reg in_data_en_r1;
    // always@(posedge clk or negedge rst_n)
    // begin
    //     if(~rst_n)
    //         in_data_en_r1 <= 0;
    //     else
    //         in_data_en_r1 <= in_data_en;
    // end
    
    
    // data in delay 2T
    reg [7:0] row_pexil_out1;
    reg [7:0] row_pexil_out2;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            row_pexil_out1 <= 0;
            row_pexil_out2 <= 0;
        end
        else
        begin
            row_pexil_out1 <= row_pexil_out;
            row_pexil_out2 <= row_pexil_out1;
        end
    end
    //cnt delay 4T
    reg [10:0] rowx2_cnt1,
               rowx2_cnt2,
               rowx2_cnt3,
               rowx2_cnt4,
               rowx2_cnt5;
               
   assign row_cnt = rowx2_cnt5;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            rowx2_cnt1 <= 0;
            rowx2_cnt2 <= 0;
            rowx2_cnt1 <= 0;
            rowx2_cnt4 <= 0;
            rowx2_cnt5 <= 0;
        end
        else
        begin
            rowx2_cnt1 <= rowx2_cnt;
            rowx2_cnt2 <= rowx2_cnt1;
            rowx2_cnt3 <= rowx2_cnt2;
            rowx2_cnt4 <= rowx2_cnt3;
            rowx2_cnt5 <= rowx2_cnt4;
        end
    end
    
    //interplation
    wire [9:0] row_pexil_out2_10bit;
    wire [9:0] row_pexil_out_10bit;
    reg [9:0] row_inter_data_r;
    assign row_pexil_out2_10bit = {2'b0,row_pexil_out2};
    assign row_pexil_out_10bit = rowx2_cnt5 == 1279? {2'b0,row_pexil_out1} : {2'b0,row_pexil_out};
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            row_inter_data_r <= 0;
        else
        begin
            if(rowx2_cnt5 <= width)
            begin
                // if(in_data_en)
                // begin
                    if(rowx2_cnt5 == 1)
                        row_inter_data_r <= {2'b0,row_pexil_out};
                    else
                    begin
                        if(rowx2_cnt5[0] == 0)//0.75 0.25
                            // row_inter_data <= ((row_pexil_out2 + 1) >> 2)*3 + ((row_pexil_out + 1) >> 2);
                            row_inter_data_r <= (((row_pexil_out2_10bit << 1) + row_pexil_out2_10bit + 2) >> 2) + ((row_pexil_out_10bit + 2) >> 2);
                         else//0.25 0.75
                            // row_inter_data <= ((row_pexil_out2 + 1) >> 2) + ((row_pexil_out + 1) >> 2)*3;
                            row_inter_data_r <= ((row_pexil_out2_10bit + 2) >> 2) + (((row_pexil_out_10bit << 1) + row_pexil_out_10bit + 2) >> 2);
                    end
                // end
                // else;
            end
            else if(rowx2_cnt5 == 1280)
                    row_inter_data_r <= {2'b0,row_pexil_out2_10bit};
            else
            begin
                if(rowx2_cnt5[0] == 0)//0.75 0.25
                    // row_inter_data <= ((row_pexil_out2 + 1) >> 2)*3 + ((row_pexil_out + 1) >> 2);
                    row_inter_data_r <= (((row_pexil_out2_10bit << 1) + row_pexil_out2_10bit + 2) >> 2) + ((row_pexil_out_10bit + 2) >> 2);
                else//0.25 0.75
                    // row_inter_data <= ((row_pexil_out2 + 1) >> 2) + ((row_pexil_out + 1) >> 2)*3;
                    row_inter_data_r <= ((row_pexil_out2_10bit + 2) >> 2) + (((row_pexil_out_10bit << 1) + row_pexil_out_10bit + 2) >> 2);
            end
        end
    end
    assign row_inter_data = row_inter_data_r[7:0];
    // assign rd_row_addr = rowx2_cnt1 == 1? 10'd0 : (rowx2_cnt1 >> 1) - 1;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            rd_row_addr <= 0;
        else
            rd_row_addr <= rowx2_cnt1 == 1280 ? 10'd639 :(rowx2_cnt1 == 1? 10'd0 : (rowx2_cnt1 >> 1) - 1);
    end

    // always@(*)
    // begin
    //     if(rowx2_cnt3 <= rowx2)
    //         o_data_en = 1;
    //     else
    //         o_data_en = 0;
    // end

    //输出要延迟周期
    reg o_data_en_r;
    always@(posedge clk or negedge rst_n)
    // always@(*)
    begin
        if(~rst_n)
            o_data_en_r <= 0;
        else if(in_data_en == 1)
            o_data_en_r <= 1;
        else if(rowx2_cnt > 639 && rowx2_cnt1 <= 1280)
            o_data_en_r <= 1;
        // else if(in_data_en == 0 && rowx2_cnt1 <= 1280)
        //     o_data_en_r = 1;
        // else if(in_data_en == 0 && rowx2_cnt2 == 1280)
        //     o_data_en_r = 1;
        // else if(in_data_en == 0 && rowx2_cnt == 1)
            // o_data_en_r = 0;
        else
            o_data_en_r = 0;
    end
    assign o_data_en_r_o = o_data_en_r;
    // reg o_data_en_r1,
    //     o_data_en_r2,
    //     o_data_en_r3,
    //     o_data_en_r4,
    //     o_data_en_r5;
    // always@(posedge clk or negedge rst_n)
    // begin
    //     if(~rst_n)
    //     begin
    //         o_data_en_r1 <= 0;
    //         o_data_en_r1 <= 0;
    //         o_data_en_r1 <= 0;
    //         o_data_en_r1 <= 0;
    //         o_data_en_r1 <= 0;
    //     end
    //     else
    //     begin
    //         o_data_en_r1 <= o_data_en_r;
    //         o_data_en_r2 <= o_data_en_r1;
    //         o_data_en_r3 <= o_data_en_r2;
    //         o_data_en_r4 <= o_data_en_r3;
    //         o_data_en_r5 <= o_data_en_r4;
    //     end
    // end
    // reg [5:0] o_data_en_shift;
    // always@(posedge clk or negedge rst_n)
    // begin
    //     if(~rst_n)
    //         o_data_en_shift <= 0;
    //     else
    //         o_data_en_shift <= {o_data_en_shift[4:0],o_data_en_r};
    // end
    // assign o_data_en = o_data_en_shift[4];
endmodule
