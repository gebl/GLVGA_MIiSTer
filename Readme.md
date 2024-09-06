# GLVGA_MIiSTer - A Simple MiSTer Core for VGA Output

This repository contains a basic FPGA core designed for the MiSTer FPGA platform, specifically to generate a VGA output. The output image, which can be viewed [here](https://github.com/gebl/GLVGA_MIiSTer/blob/master/Output.png?raw=true), demonstrates the VGA output this core generates.

## Features
- **VGA Signal Generation**: Implements basic VGA signal generation logic.
- **Test Pattern Output**: The core outputs a simple VGA test pattern as seen in the provided image.
- **Customizable**: The core can be easily modified to experiment with different VGA resolutions and patterns.

## Directory Overview
- **rtl/**: Contains the RTL (Register Transfer Level) files that define the core's logic, including modules for generating VGA signals and handling sync pulses.
- **sys/**: System-level files necessary for integrating the core with the MiSTer platform.
- **scripts/**: Automation and build scripts for compiling and testing the core.

## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/gebl/GLVGA_MIiSTer.git
   ```
2. Use your preferred FPGA toolchain to synthesize the core.
3. Load the core onto your MiSTer device and connect a VGA monitor to visualize the output.

## VGA Signal Overview
The core generates standard VGA signals, including:
- **Horizontal Sync**: Controls the timing of horizontal lines on the display.
- **Vertical Sync**: Controls the timing of the vertical refresh of the display.
- **RGB Data**: Outputs color data for each pixel, resulting in the image displayed.

## Contributing
Contributions are welcome! Feel free to fork the repository and submit pull requests for improvements, bug fixes, or additional features.

## License
This project is licensed under the MIT License.

For more details, check the repository: [GLVGA_MIiSTer](https://github.com/gebl/GLVGA_MIiSTer).