

..  SPDX-License-Identifier: CC-BY-4.0




##########################################################################################
Functions 
##########################################################################################




Functions ``initialise_(class)``
===============================================================

To get a complete overview of the classes included in **mVARbox**, have a look at folder [initialise_objects/](https://github.com/arya-upm/mVARbox/tree/main/initialise_objects). This folder contains the functions employed to initialise objects of a particular class. Additionally, within each corresponding initialisation function, you will find a comprehensive description of the fields associated with each class. An object can be initialised either empty or with only a subset of the available fields.



Functions ``get_(class1)_(class2)``
===============================================================

These are the functions that users will handle in most cases. A function named ``get_(class1)_(class2)`` indicates that the output is an object belonging to class1, and it is generated using an object of class2 as the input. For example, the function `get_gamma_data` is used to obtain the covariance function (the output is `gamma`) from a dataset (the input is `data`). This relationship is depicted as arrow (1) in the plot above.

In certain cases, a function's name may include a third label, like in ``get_(class1)_(class2)_(method)``. This label is used for operations that can be performed using multiple methods, see for example functions `get_S_data_Welch` and `get_S_data_BT` for spectral estimation through Welch and Blackman-Tukey estimator, respectively.

The documentation provided within each function provides a comprehensive description of the fields that need to be populated in the input objects, as well as the fields that are populated in the output objects during the function execution. 




Functions ``fun_``
===============================================================

These are auxiliary functions designed to carry out secondary operations. Typically, users do not need to interact with them directly. The main exceptions are described in Tutorial **T0_starting_with_mVARbox** (see below).





Function ``fun_default_value``
===============================================================

This is a special function located in folder `funs/ <https://github.com/cristobal-GC/mVARbox/tree/main/funs>`_. 
It contains default values for a number of parameters and fields.
When optional input parameters are omitted, they are automatically assigned the corresponding default values from this function. Users have the flexibility to modify these default values by editing the function




