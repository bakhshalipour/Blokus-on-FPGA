# Blokus-on-FPGA

This project provides an FPGA-based implementation for popular [Blokus](https://en.wikipedia.org/wiki/Blokus) game. The code is written in Verilog and deals with interfaces of [Altera DE2](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=183&No=30&PartNo=1) board. 

As Blokus is a somehow complicated game, designing a sound AI algorithm for the game, is a challenging work. Generally, the algorithm should analysis *many* potential places for a specific shape, and put the shape in the best position. As a consequence, most of the algorithms exhibit an undesirable execution latency. Fortunately, such algorithms provide abundant parallelism which can be exploited by inherently-parallel FPGA.

This project implements an effective AI algorithm for Blokus on FPGA. The code uses *UART* for sending commands to and receiving states from Altera DE2 board. The maximum acceptable response time is 10 seconds, but the response usually is provided within 1 second.

Primarily, the code was developed for attending in the fourth [FPGA Challenge](http://fpga.sharif.edu/) of Sharif University of Technology and ranked 3rd among 30+ participants.

## Acknowledgments
This project was a joint work: **Mohammad Bakhshalipour**, Mostafa Karimi, and Hamed Sadat-Hosseini.
