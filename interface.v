
`include "constants.v"
module interface(
	input nrst,
	input clk_in,
	input rx,
	output tx
	);

reg [3:0] current_state,next_state;
reg three_received_next,three_received;
reg [2:0] tx_byte_counter,tx_byte_counter_next;
reg [2:0] rx_byte_counter,rx_byte_counter_next;
reg [23:0] team_code,team_code_next;
//reg [31:0] transmit_move,transmit_move_next;
reg [7:0] transmit_piece,transmit_rotation,transmit_x,transmit_y;
reg [7:0] transmit_piece_next,transmit_rotation_next,transmit_x_next,transmit_y_next;

wire clk_uart,clk_find_move,clk_pll;
pll pll_inst(
	.inclk0(clk_in),
	.c0(clk_pll));
assign clk_uart=clk_pll;
//	
//pll_alpha_betha	pll_alpha_betha_inst (
//	clk_in,
//	clk_find_move
//	);	
//	
// uart signals
reg transmit;
reg [7:0] tx_byte;
wire [7:0] rx_byte;
wire received,is_receiving,is_transmitting,recv_error;

uart uart_inst(
    .clk(clk_uart), // The master clock for this module
    .rst(!nrst), // Synchronous reset.
    .rx(rx), // Incoming serial line
    .tx(tx), // Outgoing serial line
    .transmit(transmit), // Signal to transmit
    .tx_byte(tx_byte), // Byte to transmit
    .received(received), // Indicated that a byte has been received.
    .rx_byte(rx_byte), // Byte received
    .is_receiving(is_receiving), // Low when receive line is idle.
    .is_transmitting(is_transmitting), // Low when transmit line is idle.
    .recv_error(recv_error) // Indicates error in receiving packet.
    );

reg enemy_pass,enemy_pass_next,start_in,is_first_move_5_5,is_first_move_5_5_next;
reg [`PIECE_SIZE_BIT-1:0] enemy_piece_in,enemy_piece_in_next;
reg [2:0] enemy_piece_rotation_in,enemy_piece_rotation_in_next;
reg [`X_Y_BIT-1:0] enemy_x_pos_in,enemy_x_pos_in_next,enemy_y_pos_in,enemy_y_pos_in_next;
wire [`PIECE_SIZE_BIT-1:0] best_piece_out;
wire [2:0] best_piece_rotation_out;
wire [`X_Y_BIT-1:0] best_x_pos_out,best_y_pos_out;  
wire done_out,busy_out,pass_out;
wire [4:0] test_state;
wire [1:0] test_find_next_move_state;


/**
	your module instance
**/
find_move find_move_inst(
			.clk(clk_uart),
			.nrst(nrst),			//active low reset
			.start_in(start_in),	//start signal
			.is_first_move_5_5(is_first_move_5_5), //if =1 we must put the first tile on the board and cover (5,5)
			.enemy_pass(enemy_pass),	//the other player passes
			.enemy_piece_in(enemy_piece_in), //the other player's move.piece
			.enemy_piece_rotation_in(enemy_piece_rotation_in),//the other player's move.rotation
			.enemy_x_pos_in(enemy_x_pos_in),//the other player's move.x
			.enemy_y_pos_in(enemy_y_pos_in),//the other player's move.y
			.best_piece_out(best_piece_out),//our move.piece
			.best_piece_rotation_out(best_piece_rotation_out), //our move.rotation
			.best_x_pos_out(best_x_pos_out),	//our move.x
			.best_y_pos_out(best_y_pos_out), //our move.y
			.done_out(done_out),	
			.busy_out(busy_out),
			.pass_out(pass_out) //we could not find any move
			);
	

parameter ZERO_CHAR = `ZERO_ASCII;
parameter TWO_CHAR  = `ZERO_ASCII + 8'd2;
parameter THREE_CHAR= `ZERO_ASCII + 8'd3;
parameter FOUR_CHAR = `ZERO_ASCII + 8'd4;

parameter IDLE 							= 0;
parameter TRANSMIT_TEAM_CODE	 		= 1;
parameter TWO_RECEIVED					= 2;
parameter THREE_RECEIVED 				= 3;
parameter FOUR_RECEIVED					= 4; 			
parameter RECEIVING_FOUR_CHAR 			= 5;
parameter START_find_move 				= 6;
parameter WAIT_FOR_find_move			= 7;
parameter TRANSMIT_FOUR_CHAR			= 8;



always@(*) begin

	transmit = 0;
	enemy_pass_next = enemy_pass;
	next_state = 0;
	start_in   = 0;
	tx_byte    = 0;
	
	three_received_next = three_received;

	rx_byte_counter_next = rx_byte_counter;
	tx_byte_counter_next = tx_byte_counter;

	team_code_next = team_code;

	//transmit_move_next = transmit_move;
	
	transmit_piece_next = transmit_piece;
	transmit_rotation_next = transmit_rotation;
	transmit_x_next = transmit_x;
	transmit_y_next = transmit_y;

	is_first_move_5_5_next = is_first_move_5_5;
	enemy_piece_in_next = enemy_piece_in;
	enemy_piece_rotation_in_next = enemy_piece_rotation_in;
	enemy_x_pos_in_next = enemy_x_pos_in;
	enemy_y_pos_in_next = enemy_y_pos_in;

	case(current_state)
	IDLE :  begin

		transmit = 0;
		tx_byte = 0;
		enemy_pass_next = 0;
		start_in = 0;

		three_received_next = 0;
		rx_byte_counter_next = 0;
		tx_byte_counter_next = 0;
		team_code_next = 0;
	
		enemy_piece_in_next = 0;
		enemy_piece_rotation_in_next = 0;
		enemy_x_pos_in_next = 0;
		enemy_y_pos_in_next = 0;
		
	//	transmit_move_next = 0;
		
		transmit_piece_next = 40;
		transmit_rotation_next = 0;
		transmit_x_next = 0;
		transmit_y_next = 0;

		if(received) begin
			case(rx_byte)
			ZERO_CHAR:begin
				team_code_next = {`ZERO_ASCII + 8'd1,`TEAM_CODE}; // define team code ...
				next_state = TRANSMIT_TEAM_CODE;
			end
			TWO_CHAR: begin
				next_state = TWO_RECEIVED;
			end
			THREE_CHAR: begin
				next_state = THREE_RECEIVED;
			end
			FOUR_CHAR: begin
				next_state = RECEIVING_FOUR_CHAR;
				rx_byte_counter_next = 4;
			end
			default: begin
				next_state = IDLE;
			end
			endcase
		end
		else
			next_state = IDLE;
	end
	TRANSMIT_TEAM_CODE: begin
		if(tx_byte_counter != 3) begin
			if(!is_transmitting) begin
				tx_byte = team_code[23:16];
				transmit = 1;
				team_code_next = {team_code[15:0],8'h30};
				tx_byte_counter_next = tx_byte_counter + 1;
				next_state = TRANSMIT_TEAM_CODE;
			end
			else begin
				next_state = TRANSMIT_TEAM_CODE;
			end
		end 
		else begin
			next_state = IDLE;
		end
	end
	TWO_RECEIVED: begin
		if(received) begin
			if(rx_byte == 8'h41) begin
				//transmit_move_next = {`A_ASCII,`A_ASCII,`FIRST_PIECE_REAL,`FIRST_ROTATION_REAL};
				transmit_x_next = `A_ASCII;
				transmit_y_next = `A_ASCII;
				transmit_piece_next = `FIRST_PIECE_REAL ; 
				transmit_rotation_next = `FIRST_ROTATION_REAL;
				is_first_move_5_5_next = 0;
			end
			else if(rx_byte == `ZERO_ASCII+8'd5) begin
				//transmit_move_next = {`ZERO_ASCII+8'd5,`ZERO_ASCII+8'd5,`FIRST_PIECE_REAL,`FIRST_ROTATION_REAL};
				transmit_x_next = `ZERO_ASCII+8'd5;
				transmit_y_next = `ZERO_ASCII+8'd5;
				transmit_piece_next = `FIRST_PIECE_REAL ; 
				transmit_rotation_next = `FIRST_ROTATION_REAL;
				is_first_move_5_5_next = 1;
			end
			enemy_pass_next = 1;
			next_state = TRANSMIT_FOUR_CHAR;
			start_in = 1;	
		end
		else
			next_state = TWO_RECEIVED;
	end
	THREE_RECEIVED: begin
		if(received) begin
		if(rx_byte == 8'h41) begin
				//transmit_move_next = {`A_ASCII,`A_ASCII,`FIRST_PIECE_REAL,`FIRST_ROTATION_REAL};
				transmit_x_next = `A_ASCII;
				transmit_y_next = `A_ASCII;
				transmit_piece_next = `FIRST_PIECE_REAL ; 
				transmit_rotation_next = `FIRST_ROTATION_REAL;
				is_first_move_5_5_next = 0;
			end
			else if(rx_byte == `ZERO_ASCII+8'd5) begin
				//transmit_move_next = {`ZERO_ASCII+8'd5,`ZERO_ASCII+8'd5,`FIRST_PIECE_REAL,`FIRST_ROTATION_REAL};
				transmit_x_next = `ZERO_ASCII+8'd5;
				transmit_y_next = `ZERO_ASCII+8'd5;
				transmit_piece_next = `FIRST_PIECE_REAL ; 
				transmit_rotation_next = `FIRST_ROTATION_REAL;
				is_first_move_5_5_next = 1;
			end
			//start_in = 1;
			next_state = RECEIVING_FOUR_CHAR;
			rx_byte_counter_next = 4;
			three_received_next = 1;
		end
		else begin
			next_state = THREE_RECEIVED;
		end
	end
	RECEIVING_FOUR_CHAR: begin
		if(received) begin
			if(rx_byte_counter == 4) begin
				if(rx_byte > `ZERO_ASCII+9)
					enemy_x_pos_in_next = rx_byte - `A_ASCII + 10;
				else
					enemy_x_pos_in_next = rx_byte - `ZERO_ASCII;

				rx_byte_counter_next = rx_byte_counter - 1;
				next_state = RECEIVING_FOUR_CHAR;
			end
			else if(rx_byte_counter == 3) begin
				if(rx_byte > `ZERO_ASCII+9)
					enemy_y_pos_in_next = rx_byte - `A_ASCII + 10;
				else
					enemy_y_pos_in_next = rx_byte - `ZERO_ASCII;

				rx_byte_counter_next = rx_byte_counter - 1;
				next_state = RECEIVING_FOUR_CHAR;
			end
			else if(rx_byte_counter == 2) begin
				enemy_piece_in_next = rx_byte - `A_ASCII;
				rx_byte_counter_next = rx_byte_counter - 1;
				next_state = RECEIVING_FOUR_CHAR;
			end
			else if(rx_byte_counter == 1) begin
				enemy_piece_rotation_in_next = rx_byte - `A_ASCII;
				rx_byte_counter_next = rx_byte_counter - 1;
				next_state = START_find_move;
			end
		end
		else
			next_state = RECEIVING_FOUR_CHAR;
	end
	START_find_move: begin
		if(!enemy_x_pos_in && !enemy_y_pos_in && !enemy_piece_in && !enemy_piece_rotation_in) begin
			enemy_pass_next = 1;
		end
		if(three_received) begin
			next_state = TRANSMIT_FOUR_CHAR;
			tx_byte_counter_next = 0;
			three_received_next = 0;
		end
		else 
			next_state = WAIT_FOR_find_move;
		start_in = 1;
	end
	WAIT_FOR_find_move: begin
		if(done_out) begin
			if(0) begin	//I changed this.
				//transmit_move_next = {`ZERO_ASCII,`ZERO_ASCII,`ZERO_ASCII,`ZERO_ASCII};
				transmit_x_next = `ZERO_ASCII;
				transmit_y_next = `ZERO_ASCII;
				transmit_piece_next = `ZERO_ASCII ; 
				transmit_rotation_next = `ZERO_ASCII;
			end
			else begin
				transmit_x_next = (best_x_pos_out > 9)? `A_ASCII + best_x_pos_out-10 : `ZERO_ASCII + best_x_pos_out;
				transmit_y_next = (best_y_pos_out > 9)? `A_ASCII + best_y_pos_out-10 : `ZERO_ASCII + best_y_pos_out;
				transmit_piece_next = {3'b000,best_piece_out} + `A_ASCII ; 
				transmit_rotation_next = {5'b00000,best_piece_rotation_out} + `ZERO_ASCII ;
			end
			
			next_state = TRANSMIT_FOUR_CHAR;
			tx_byte_counter_next = 2'b00;
		end
		else
			next_state = WAIT_FOR_find_move;
	end
	TRANSMIT_FOUR_CHAR: begin
		if(tx_byte_counter == 2'b0) begin
			if(!is_transmitting) begin
				tx_byte = transmit_x;
				transmit = 1;
				//transmit_move_next = {transmit_move[23:0],8'h30};
				tx_byte_counter_next = tx_byte_counter + 2'b1;
				next_state = TRANSMIT_FOUR_CHAR;
			end
			else begin
				next_state = TRANSMIT_FOUR_CHAR;
			end
		end
		else if(tx_byte_counter == 2'd1) begin
			if(!is_transmitting) begin
				tx_byte = transmit_y;
				transmit = 1;
				//transmit_move_next = {transmit_move[23:0],8'h30};
				tx_byte_counter_next = tx_byte_counter + 2'b1;
				next_state = TRANSMIT_FOUR_CHAR;
			end
			else begin
				next_state = TRANSMIT_FOUR_CHAR;
			end
		end
		else if(tx_byte_counter == 2'd2) begin
			if(!is_transmitting) begin
				tx_byte = transmit_piece;
				transmit = 1;
				//transmit_move_next = {transmit_move[23:0],8'h30};
				tx_byte_counter_next = tx_byte_counter + 2'b1;
				next_state = TRANSMIT_FOUR_CHAR;
			end
			else begin
				next_state = TRANSMIT_FOUR_CHAR;
			end
		end 
		else if(tx_byte_counter == 2'd3) begin
			if(!is_transmitting) begin
				tx_byte =transmit_rotation;
				transmit = 1;
				//transmit_move_next = {transmit_move[23:0],8'h30};
				tx_byte_counter_next = tx_byte_counter + 2'b1;
				next_state = TRANSMIT_FOUR_CHAR;
			end
			else begin
				next_state = TRANSMIT_FOUR_CHAR;
			end
		end 	
		else begin
			next_state = IDLE;
		end
	end
	default: begin
		next_state = IDLE;
	end
	endcase
end


always@(posedge clk_uart or negedge nrst) begin
	if(!nrst) begin
		current_state = IDLE;
		
	end
	else begin
		enemy_pass = enemy_pass_next;
		
		current_state = next_state;
		three_received = three_received_next;
		rx_byte_counter = rx_byte_counter_next;
		tx_byte_counter = tx_byte_counter_next;
		team_code = team_code_next;
		
		//transmit_move = transmit_move_next;
		
		transmit_piece = transmit_piece_next;
		transmit_rotation = transmit_rotation_next;
		transmit_x = transmit_x_next;
		transmit_y = transmit_y_next;
		
		is_first_move_5_5 = is_first_move_5_5_next;
		enemy_piece_in = enemy_piece_in_next;
		enemy_piece_rotation_in = enemy_piece_rotation_in_next;
		enemy_x_pos_in = enemy_x_pos_in_next;
		enemy_y_pos_in = enemy_y_pos_in_next;
	end
end

endmodule