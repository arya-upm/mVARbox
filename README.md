# mVARbox

mVARbox is a Matlab toolbox for uni/multivariate time series analysis in both time and frequency domains, with focus on mutivariate autoregressive (VAR) models. By using mVARbox, you will be able to, among others:

- estimate auto/cross spectra from time series using different estimation methods (Welch, Blackman–Tukey, Daniell, etc.).
- obtain optimal Autoregressive Models that reproduce a predefined target covariance/spectral structure.
- generate synthetic time series from Autoregressive Models.
- ...


mVARbox is intended for educational and research purposes. It has been developed by professors and students of the Rotary Wing and Wind Turbines ([ARYA](http://arya.dave.upm.es/)) unit of the Department of Aircraft and Space Vehicles (Universidad Politécnica de Madrid). 

mVARbox is free software and you can redistribute it and or modify it under the terms of the GNU General Public License (GPL) v3.



## Start-up

To get a fresh copy of mVARbox, clone the git repository located [here](https://github.com/cristobal-GC/mVARbox). You can also [download](https://github.com/cristobal-GC/mVARbox/archive/refs/heads/main.zip) it directly.

Add permanently the main folder of the toolbox to the matlab path.

To start-up with mVARbox, type 'setmVARboxPath' in the matlab command line to automatically add the whole toolbox to the matlab path. Once finished, type 'unsetmVARboxPath' to remove the toolbox from the path.

Functions in mVARbox are implemented to work mainly with pseudo-objects (matlab structures). Folder 'initialise_objects' contains functions to initialise different type of objects, describing the specific fields for each one.

mVARbox includes a number of well-documented and illustrative examples in folder 'tutorials'.

Please write to 'cristobaljose.gallego AT upm DOT es' to report bugs and provide feed-back. The authors and future users will be very grateful.




## List of authors and mantainers:

- Cristóbal J. Gallego Castillo
- Álvaro Cuerva Tejero
- Óscar López García


## List of contributors:

- Mohanad Elagamy
- Luis Mora de la Cruz

