## What's Implemented
1. Resmapler, TwiddleGenerator Implementation for Data Processing
2. Hardware Version Spectrogram GUI Implementation based on Qt
3. In-place FFT Architecture Implementation with Verilog HDL and We use Quartus IP for FPU(DE2 board used)

## Reference paper
In-Place FFT Architecture are designed by [L. G. Johnson's Conflict Free Memory Addressing for Dedicated FFT Hardware](https://ieeexplore.ieee.org/document/142032).
Johnson presented only DIT architecture. He didn't prove DIF algorithm and present DIF architecture.
However, we proved, designed and implemented DIF architecture.
Compared two architecture(In the paper : DIT, Ours : DIF), you can understand conflict free addressing technique.

## DEMO
Our architecture is setted on FFT-Point : 32, Radix : 2
If you want to more FFT-Point, Just convert some parameters and change ADDRgen.v(instantiate more ADDRgen_element module)

https://user-images.githubusercontent.com/109369687/204363690-38570695-cc74-4868-a109-0807d4b00894.mp4
