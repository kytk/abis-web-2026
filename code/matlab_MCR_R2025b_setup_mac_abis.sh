#!/bin/bash

cd ~/Downloads

arch=$(uname -m)
if [ $arch = "arm64" ]; then
  curl -OL https://ssd.mathworks.com/supportfiles/downloads/R2025b/Release/0/deployment_files/installer/complete/maca64/MATLAB_Runtime_R2025b_maca64.dmg
  open MATLAB_Runtime_R2025b_maca64.dmg
else
  curl -OL https://ssd.mathworks.com/supportfiles/downloads/R2025b/Release/0/deployment_files/installer/complete/maci64/MATLAB_Runtime_R2025b_maci64.dmg.zip
  unzip MATLAB_Runtime_R2025b_maci64.dmg.zip
  rm MATLAB_Runtime_R2025b_maci64.dmg.zip
  open MATLAB_Runtime_R2025b_maci64.dmg
fi
