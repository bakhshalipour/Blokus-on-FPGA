task move(
  input [1:0]player,
  input [31:0]y,
  input [31:0]x,
  input [31:0]piecee,
  input [31:0]rotatee
);
  
  integer c, r, xx, yy, x_offset, y_offset;
  integer got_it;  
  integer b,xxx,yyy;
  /*******************code***********************/
  begin  
		c = piecee;
		r = rotatee;
		x_offset = x-2;
		y_offset = y-2;  
		// OK, now place the move
		for(yy=0; yy<5; yy=yy+1)begin
		  for(xx=0; xx<5; xx=xx+1)begin
			b = pieces[c][rotate[r][yy][xx]/5][rotate[r][yy][xx]%5];
			if (b==1)	next_board[y_offset+yy][x_offset+xx] = player;
		  end
		end
		if(player!=3)next_available[c] = 0;
  end
endtask