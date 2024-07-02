.. mVARbox documentation master file, created by
   sphinx-quickstart on Sun Jun 23 08:37:10 2024.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

..  SPDX-License-Identifier: CC-BY-4.0



#############################################################################################
mVARbox: A tool for time series modelling, spectral estimation and synthetic data generation
#############################################################################################



**mVARbox** is a Matlab toolbox for uni/multivariate data series analysis in both time and frequency domains, with special focus on multivariate autoregressive (VAR) models. By using **mVARbox**, you will be able to, among others:

- estimate auto/cross spectra from time series using different estimation methods (Welch, Blackman-Tukey, Daniell, etc.),
- obtain optimal Autoregressive models that reproduce a predefined target covariance/spectral structure,
- generate uni/multivariate synthetic time series `(watch an example video) <http://arya.dave.upm.es/media/mVARbox_synthetic_wind_field.mp4>`_. 
- ...


**mVARbox** is a software tool developed by professors and students of the Rotary Wing and Wind Turbines unit (`ARYA <http://arya.dave.upm.es/05_software.html>`_) within the Department of Aircraft and Space Vehicles at the Universidad Politécnica de Madrid (UPM).

**mVARbox** is specifically designed for educational and research purposes. It is released under MIT license.

To get a fresh copy of **mVARbox**, clone the git repository located `here <https://github.com/arya-upm/mVARbox>`_. You can also `download <https://github.com/arya-upm/mVARbox/archive/refs/heads/main.zip>`_ it directly.






.. :hidden: es para que no salga al final de la página, solo aparece en el lateral izquierdo






.. toctree::  
   :maxdepth: 2
   :caption: How to use mVARbox

   basic_notions
   functions
   tutorials



.. toctree::  
   :maxdepth: 2
   :caption: Further details

   authors
   citation
   related_publications



.. Indices and tables
   ==================

   * :ref:`genindex`
   * :ref:`modindex`
   * :ref:`search`
