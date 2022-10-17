`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/23 15:35:54
// Design Name: 
// Module Name: col_interplation
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


module col_interplation(
    input clk,
    input rst_n,
    input in_data_en,
    
    input [10:0] row_cnt,
    input [7:0] buf1_data_out,
    input [7:0] buf2_data_out,
    // input [7:0] buf3_data_out,
    
    output [7:0] col_inter_data,
    output reg o_data_en,
    output o_V_SYNC,
    output reg o_H_SYNC
    );
    reg [9:0] cnt;
    reg [9:0] col_cnt1,
              col_cnt2;
    reg [9:0] col_cnt;
    reg [10:0] col_cnt_flip;

    always@(posedge in_data_en or negedge in_data_en or negedge rst_n)
    begin
        if(~rst_n)
            cnt <= 0;
        else if(~in_data_en)
        begin
            if(cnt == 721)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end
        // else if(col_cnt == 721)
        //     cnt <= cnt + 1;
        else
        begin
            if(cnt == 720)
                cnt <= 0;
            else
                cnt <= cnt + 1;
        end
    end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            col_cnt_flip <= 1;
        else if(col_cnt_flip == 1280)
            col_cnt_flip <= 1;
        else if(in_data_en == 0)
            col_cnt_flip <= col_cnt_flip + 1;
        else
            col_cnt_flip <= 1;
    end

    
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            col_cnt <= 1;
        else if(row_cnt == 1280 || col_cnt_flip == 1279)
            col_cnt <= col_cnt + 1;
        else if(col_cnt == 720 && col_cnt_flip == 1280)
            col_cnt <= col_cnt + 1;
        else;
    end 

    //col_cnt延迟3个周期
    
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            col_cnt1 <= 0;
            col_cnt2 <= 0;
        end
        else
        begin
            col_cnt1 <= col_cnt;
            col_cnt2 <= col_cnt1;
        end
    end
    //插值计算
    wire [9:0] buf1_data_out_10bit,
               buf2_data_out_10bit;
            //    buf3_data_out_10bit;
    assign buf1_data_out_10bit = {2'b00,buf1_data_out};
    assign buf2_data_out_10bit = {2'b00,buf2_data_out};
    
    reg [9:0] col_inter_data_r;
    // reg [9:0] test1,test2;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            col_inter_data_r <= 0;
        else
        begin
            if(col_cnt2 == (1 + 1) && cnt != 3)//有1行的延迟
                col_inter_data_r <= buf1_data_out_10bit;
            else if(col_cnt2 == (720 + 1))
                col_inter_data_r <= buf1_data_out_10bit;
            else
            begin
                if(cnt[0] == 1)
                begin
                    col_inter_data_r <= ((((buf2_data_out_10bit << 1) + (buf2_data_out_10bit + 2)) >> 2)) + ((buf1_data_out_10bit + 2) >> 2);
                    // col_inter_data_r <= ((buf2_data_out_10bit + 1)>>1) + ((buf2_data_out_10bit + 2)>>2) + ((buf1_data_out_10bit + 2) >> 2);
                    // col_inter_data_r <= ((buf2_data_out_10bit*3 + 2) >> 2) + ((buf1_data_out_10bit + 2) >> 2);
                    // col_inter_data_r <= (buf2_data_out_10bit*3 + buf1_data_out_10bit + 2) >> 2;
                    // test1 <= ((((buf2_data_out_10bit << 1) + (buf2_data_out_10bit + 2)) >> 2));
                    // test2 <= ((buf1_data_out_10bit + 2) >> 2);
                    // col_inter_data_r <= ((buf2_data_out_10bit*3 + 2) >> 2) + ((buf1_data_out_10bit + 2) >> 2);
                    // col_inter_data_r <= ((buf2_data_out_10bit << 1) + buf2_data_out_10bit + buf1_data_out_10bit + 2) >> 2;
                end
                else
                begin
                    col_inter_data_r <= ((((buf1_data_out_10bit << 1) + (buf1_data_out_10bit + 2)) >> 2)) + ((buf2_data_out_10bit + 2) >> 2);
                    // test1 <= ((((buf1_data_out_10bit << 1) + (buf1_data_out_10bit + 2)) >> 2));
                    // test2 <= ((buf2_data_out_10bit + 2) >> 2);
                end
            end
            // else if(col_cnt1 == (2 + 1))
            //     col_inter_data_r <= (((buf2_data_out_10bit << 1) + buf2_data_out_10bit + 2) >> 2) + ((buf1_data_out_10bit + 2) >> 2);        
            // else if(col_cnt2 == (2 + 2))
            //     col_inter_data_r <= (((buf1_data_out_10bit_r << 1) + buf1_data_out_10bit_r + 2) >> 2) + ((buf2_data_out_10bit + 2) >> 2);
            // else
            // begin
            //     if(col_cnt2[0] == 1)
            //         col_inter_data_r <= (((buf2_data_out_10bit << 1) + buf2_data_out_10bit + 2) >> 2) + ((buf3_data_out_10bit + 2) >> 2);
            //     else
            //         col_inter_data_r <= (((buf3_data_out_10bit << 1) + buf3_data_out_10bit + 2) >> 2) + ((buf2_data_out_10bit + 2) >> 2);
            // end
        end
    end
    assign col_inter_data = col_inter_data_r[7:0];
    //同步信号产生
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            o_data_en <= 0;
        else if(col_cnt2 >= 2 && col_cnt1 <= 721)
            o_data_en <= 1;
        // else if(col_cnt2 == 721 && col_cnt_flip <= 512)
        //     o_data_en <= 1;
        else
            o_data_en <= 0;
    end

    //in_data_en 延迟一个周期
    reg in_data_en_r;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            in_data_en_r <= 0;
        else
            in_data_en_r <= in_data_en;
    end
    assign o_H_SYNC_W = in_data_en_r ^ in_data_en;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            o_H_SYNC <= 0;
        else
            o_H_SYNC <= o_H_SYNC_W;
    end
    //o_data_en 延迟一个周期
    reg o_data_en_r;
    always@(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
            o_data_en_r <= 0;
        else
            o_data_en_r <= o_data_en;
    end
    assign o_V_SYNC = o_data_en_r ^ o_data_en;
    // always@(posedge clk or negedge rst_n)
    // begin
    //     if(~rst_n)
    //         o_V_SYNC <= 0;
    //     else
    //         o_V_SYNC <= o_V_SYNC_W;
    // end
endmodule
