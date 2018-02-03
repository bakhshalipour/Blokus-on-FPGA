`include "constants.v"
module find_move(
      input [1:0] color,
      input clk,
      input nrst,
      input start_in,
      //enemy info
      input is_first_move_5_5,
      input enemy_pass,
      input [`PIECE_SIZE_BIT-1:0]	enemy_piece_in,
      input [2:0]	enemy_piece_rotation_in,
      input [`X_Y_BIT-1:0]	enemy_x_pos_in,
      input [`X_Y_BIT-1:0]	enemy_y_pos_in,
      //my info
      output reg  [`PIECE_SIZE_BIT-1:0]	best_piece_out,
      output reg  [2:0]					best_piece_rotation_out,
      output reg [`X_Y_BIT-1:0]			best_x_pos_out,
      output reg [`X_Y_BIT-1:0]			best_y_pos_out,
      output reg done_out,
      output  busy_out,
      output reg pass_out
      );
			
`include "pieces.v"
parameter WAIT=0;
parameter SECOND_MOVE=1;
parameter THIRD_MOVE=2;
parameter FINISH=3;
reg [2:0] state , next_state;
reg is_first_move,is_first_move_next;
reg [31:0] counter, next_counter;
//reg [14*14*2] board;
	reg m;
	integer x,y,piece,rotatee,xx,yy;
	reg [1:0] board[16:-2][16:-2];
	reg [1:0] next_board[16:-2][16:-2];
	
	reg next_available[20:0];
	reg available[20:0];
	integer next_player;
	reg next_enemy_pass;
	reg is_f_m_5_5;
	reg next_done_out;
	integer player;
always @(*)  //combinational behavioral , recall the circuit model !
begin
	for(xx=0;xx<21;xx=xx+1)begin
		next_available[xx]=available[xx];
	end
	for(xx=0;xx<15;xx=xx+1)begin
		for(yy=0;yy<15;yy=yy+1) begin
			next_board[xx][yy]=board[xx][yy];
		end
	end
	pass_out=0;
	next_counter=counter;
	next_player =player;
	next_done_out=0;
	is_first_move_next=is_first_move;
	best_piece_out=piece;
	best_piece_rotation_out = rotatee;
	best_x_pos_out = x;
	best_y_pos_out = y;
	next_state=WAIT;
	case (state)
		WAIT:
		begin
			if (start_in == 1) begin
					if(is_first_move) begin
						is_first_move_next = 0;
						//must update the board put `first_move on the board based on "is_first_move_5_5"
						
						//something like this:
						if (is_f_m_5_5)
						begin
							next_player =1;
							//update_board(5,5,q,0);
						//	 $display ("Current Value of xxt = %d , yyt = %d",available[0][1],available[0][0]);
							move(1,5,5,20,0);
				//	$display ("Current Value of xxt = %d , yyt = %d",available[0][1],available[0][0]);	
						end
						else
						begin
							next_player =2;
							//update_board(a,a,q,0);
							move(2,10,10,20,0);
						end
						next_done_out = 1;
						next_state = WAIT;
					end
					else begin
						next_counter=0;
						next_state = SECOND_MOVE;
					end
					if((!is_first_move || !is_f_m_5_5) && next_enemy_pass !=1 ) begin
						move(3,enemy_y_pos_in,enemy_x_pos_in,enemy_piece_in,enemy_piece_rotation_in);
						
					end
					// also you must update board state and put enemy's move on the board
			
			end
			else begin
				next_state = WAIT;
			end
		end
		SECOND_MOVE:
		begin
			//hard-coded second move:
			//best_piece_out = 5'd19; 
			//best_piece_rotation_out = 3'd5;
			//best_x_pos_out = 4'd7;
			//best_y_pos_out = 4'd2;
			//done_out=1;
			////////////
			
			check_move(player,y,x,piece,rotatee,m);
			next_state = THIRD_MOVE;
			//$display ("m equal to = %d, counter=%d",m,counter);
			if(m==1) begin
				move(player,y,x,piece,rotatee);
				best_piece_out = piece; 
				best_piece_rotation_out = rotatee;
				best_x_pos_out = x;
				best_y_pos_out = y;
				//best_piece_out = 5'd19; 
				//best_piece_rotation_out = 3'd5;
				//best_x_pos_out = 4'd7;
				//best_y_pos_out = 4'd2;
			
				next_done_out=1;
				next_state = WAIT;
			end else begin
				if (counter > 32928) begin
					best_piece_out = 0; 
					best_piece_rotation_out = 0;
					best_x_pos_out = 0;
					best_y_pos_out = 0;
					next_done_out=1;
					next_state = WAIT;
				end
				else next_counter = counter+1;
			end
			/////////////
			//next_state = WAIT;
		end
		THIRD_MOVE:
		begin
			next_state = SECOND_MOVE;
		end
		
		FINISH:
			next_state=FINISH;
		default:
			next_state=FINISH;

	endcase
end

always @(posedge clk) //sequential part
begin
	if(nrst==0) begin
		state = WAIT;
		is_first_move=1;
		counter=0;
		player=1;  
		done_out=0;
		rotatee=0;
		piece=0;
		x=1;
		y=1;
		for(xx=0;xx<21;xx=xx+1)begin
			available[xx]=1;
		end
		for(xx=0;xx<15;xx=xx+1)begin
			for(yy=0;yy<15;yy=yy+1) begin
				board[xx][yy]=0;
			end
		end
		next_enemy_pass=0;
	end
	else begin
		for(xx=0;xx<21;xx=xx+1)begin
			available[xx]=next_available[xx];
		end
		for(xx=0;xx<15;xx=xx+1)begin
			for(yy=0;yy<15;yy=yy+1) begin
				board[xx][yy]=next_board[xx][yy];
			end
		end
		next_enemy_pass=enemy_pass;
		player =next_player;
		counter=next_counter;
		rotatee=counter%8;
		piece=(counter/8)%21;
		x=(counter/168)%14+1;
		y=(counter/2352)%14+1;
		state = next_state;
		done_out=next_done_out;
		is_first_move=is_first_move_next;
		is_f_m_5_5=is_first_move_5_5;
 	end
 	
end

  `include "check_move.v"
  `include "update_board.v"
endmodule 
