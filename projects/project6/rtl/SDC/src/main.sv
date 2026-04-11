`timescale 1ms / 1ps  


module FSM_ex_control (
	input logic Clk,
	input Clk_half_period,
	input logic Reset, 
	input logic Init,
	input logic Ovf4,
	input logic Ovf5,
	input reg [4:0]	Exp_time,
	input logic ADC_control,
	output logic NRE_1,
	output logic NRE_2,
	output logic ADC,
	output logic Expose,
	output logic Erase,
	output logic Start
	);
	
	typedef enum logic [2:0] { Idle, Exposure, Readout1, Readout2, Wait_exp, Wait_r1, Wait_r2 } State;
	
	State currentState, nextState;
	
	always_ff @(posedge Clk) begin
		currentState = nextState;
	end
	
	always@(*) begin
		ADC = ADC_control;
		
		case(currentState)
			Idle:			if(Init && !Reset)
								nextState = Exposure;
							else
								nextState = Idle;
			Exposure:		if (Reset)
								nextState = Idle;
							else if (Ovf5)
								nextState = Wait_exp;
							else
									nextState = Exposure;
			Wait_exp:		if (Reset) 
								nextState = Idle;
							else begin 
								#(2*Clk_half_period);
								nextState = Readout1;
							end
			Readout1:   	if (Reset)
								nextState = Idle;
							else if (Ovf4) 
								nextState = Wait_r1;
							else 
								nextState = Readout1;
			Wait_r1:		if (Reset) 
								nextState = Idle;
							else begin 
								#(2*Clk_half_period);
								nextState = Readout2;
							end
			Readout2:		if (Reset)
								nextState = Idle;
							else if(Ovf4)
								nextState = Wait_r2;
							else 
								nextState = Readout2;
			Wait_r2:		if (Reset) 
								nextState = Idle;
							else begin 
								#(2*Clk_half_period);
								nextState = Idle;
							end
			default:    	nextState = Idle;
		endcase
	end
	
	assign Expose = (currentState == Exposure);
	assign Erase = (currentState == Idle);
	assign NRE_1 = !(currentState == Readout1);
	assign NRE_2 = !(currentState == Readout2);
	assign Start = !(currentState == Idle);

endmodule


module CTRL_ex_time (
	input logic Clk, 
	input logic Reset, 
	input logic Exp_increase, 
	input logic Exp_decrease,
	output reg [4:0] Exp_time
	);
	
	initial
		Exp_time = 3;
	
	always @ (posedge Clk) begin
		if (Exp_increase && Exp_time < 30)
			Exp_time <= Exp_time+1;
		else if (Exp_decrease && Exp_time > 2)
			Exp_time <= Exp_time-1;        
	end 
endmodule


module Timer_counter(input logic Start,
	input logic Clk,
	input logic Reset,
	input reg [4:0] Initial,
	output logic Ovf4,
	output logic Ovf5,
	output logic ADC_control);
	
	integer Exp_counter = 0;
	integer Read_counter = 0;
	logic Read_count1 = 0;
	logic Read_count2 = 0;
	integer Read_time = 3;
	
	initial begin
		Ovf4 = 0;
		Ovf5 = 0;
	end
	
	always_comb begin
		if ((Read_count1 || Read_count2) && Read_counter == 3 && Start)
			ADC_control = 1;
		else
			ADC_control = 0;
	end
	
	always @(posedge Clk) begin
		if ((Ovf5 || Read_count1) && Start) begin
			if (Start && (Read_counter < Read_time)) begin
				Read_counter = Read_counter + 1;
				Read_count1 = 1;
				Ovf5 = 0;
			end
			else if (Start && (Read_counter == Read_time)) begin
				Ovf4 = 1;
				Read_counter = 0;
				Read_count1 = 0;
				end
		end
		else if (Start && (Ovf4 || Read_count2)) begin
			if (Start && (Read_counter < Read_time)) begin
				Read_counter = Read_counter + 1;
				Read_count2 = 1;
				Ovf4 = 0;
		end
		else if (Start && (Read_counter == Read_time)) begin
			Ovf4 = 1;
			Read_counter = 0;
			Read_count2 = 0;
			end
		end
		else if (Start && (Exp_counter < Initial-2 && !Ovf4)) begin
			Exp_counter = Exp_counter + 1;
		end
		else if (Start && (Exp_counter == Initial-2 && !Ovf4)) begin
			Ovf5 = 1;
			Exp_counter = 0;
		end
		else begin
			Ovf4 = 0;
			Read_counter = 0;						
			Read_count1 = 0;
			Read_count2 = 0;
		end			
	end
endmodule 			
