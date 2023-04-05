# mVARbox

**mVARbox** is a Matlab toolbox for uni/multivariate time series analysis in both time and frequency domains, with focus on mutivariate autoregressive (VAR) models. By using **mVARbox**, you will be able to, among others:

- estimate auto/cross spectra from time series using different estimation methods (Welch, Blackman–Tukey, Daniell, etc.).
- obtain optimal Autoregressive Models that reproduce a predefined target covariance/spectral structure.
- generate synthetic time series from VAR models.
- ...


**mVARbox** is intended for educational and research purposes. It is under development by professors and students of the Rotary Wing and Wind Turbines ([ARYA](http://arya.dave.upm.es/)) unit of the Department of Aircraft and Space Vehicles (Universidad Politécnica de Madrid). 

**mVARbox** is free software and you can redistribute it and or modify it under the terms of the GNU General Public License (GPL) v3.

To get a fresh copy of **mVARbox**, clone the git repository located [here](https://github.com/cristobal-GC/mVARbox). You can also [download](https://github.com/cristobal-GC/mVARbox/archive/refs/heads/main.zip) it directly.



## mVARbox in a nutshell

Functions in mVARbox are implemented to work mainly with pseudo-objects (matlab structures). The following classes are included:

- `data`, to handle time series.
- `AR`, to handle autoregressive models.
- `gamma` to handle auto/cross covariance functions.
- `S` to handle auto/cross power spectral densities.
- `window` to handle time/lag windows.
- `DTFT` to handle Discrete Time Fourier Transforms.
- ...

Each class has a number of associated fields. Several fields are shared between classes, but others are just class-specific.

Below is a description of the main type of functions that you will find in **mVARbox**.


### Functions `initialise_(class)`

This family of functions are located in folder [initialise_objects/](https://github.com/cristobal-GC/mVARbox/tree/main/initialise_objects). They are employed to initialise an object of a specific class. The object can be initialise empty, or assessing some or all the associated fields. You will find a detailed description of the fields associated to each class in the corresponding initialisation funcion.



### Functions `get_`

These are the functions mainly intended for users. They usually take objects as inputs and generate one or more objects as outputs. The documentation of the functions describes thoroughly the fields that need to be filled in the input objects, as well as the fields that are filled in the output objects. 
Sometimes, specific parameters not contained in a object field are also required. 



### Functions `fun_`

These are support functions to perform secondary operations. Users generally do not need to deal with them.



### Function `fun_default_value`

This is a special function located in folder [funs/](https://github.com/cristobal-GC/mVARbox/tree/main/funs). It contains default values for a number of parameters and fields. When optional input parameters are ommited, they take their value from here. Users may change default values editing this function.



### Tutorials

**mVARbox** includes a number of well-documented and illustrative tutorials. You will find them in folder [tutorials/](https://github.com/cristobal-GC/mVARbox/tree/main/tutorials). The corresponding [pdf files](http://arya.dave.upm.es/library/mVARbox_tutorials/) are also available.



## First steps...

To start using **mVARbox**, add permanently the main folder of the toolbox to the matlab path. This will enable functions `setmVARboxPath` and `unsetmVARboxPath` to easily add and remove **mVARbox** from the matlab folder.


We hope you enjoy and find **mVARbox** useful. 

Please write to *cristobaljose.gallego AT upm DOT es* to report bugs and provide feed-back. The authors and future users will be very grateful.




## List of authors and mantainers

- Cristóbal J. Gallego Castillo
- Álvaro Cuerva Tejero
- Óscar López García


## List of contributors

- Mohanad Elagamy
- Luis Mora de la Cruz



## Related publications

Gallego-Castillo, C.; Cuerva-Tejero, A.; Elagamy, M.; Lopez-Garcia, O. & Avila-Sanchez, S. A tutorial on reproducing a predefined autocovariance function through AR models: Application to stationary homogeneous isotropic turbulence. Stochastic Environmental Research and Risk Assessment, 2021, 36, 2711-2736. DOI: [10.1007/s00477-021-02156-0](https://link.springer.com/article/10.1007/s00477-021-02156-0)

Elagamy, M.; Gallego-Castillo, C.; Cuerva-Tejero, A.; Lopez-Garcia, O. & Avila-Sanchez, S. Optimal autoregressive models for synthetic generation of turbulence. Implications of reproducing the spectrum or the autocovariance function. 17th European Academy of Wind Energy (EWEA) PhD Seminar on Wind Energy, Porto (Portugal), 2021.

Luis Mora de la Cruz, Spectral estimation methods from finite time series: application to wind energy related variables. ETSIAE, Universidad Politécnica de Madrid, Master thesis, 2023. (link)

Elagamy, M.; Gallego-Castillo, C.; Cuerva-Tejero, A.; Lopez-Garcia, O. & Avila-Sanchez, Eigenanalysis of vector autoregressive model
for optimal fitting of a predefined cross power spectral density matrix: Application to numeric generation of stationary homogeneous isotropic/anisotropic turbulent wind fields. Journal of Wind Engineering and Industrial Aerodynamics (in press).



