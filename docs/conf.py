# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'mVARbox'
#copyright = '2024, Cristóbal José Gallego Castillo (UPM), Álvaro Cuerva Tejero (UPM), Óscar López García (UPM)'
author = '2024, Cristóbal José Gallego Castillo (UPM), Álvaro Cuerva Tejero (UPM), Óscar López García (UPM)'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = []

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

import sphinx_rtd_theme

html_theme = 'sphinx_rtd_theme'   # NO EXISTE - El tema utilizado por Read the Docs, que es muy popular por su diseño limpio y fácil de navegar - SE INSTALA CON `> pip install sphinx_rtd_theme`
html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]

# html_theme = 'classic'   # El tema clásico de Sphinx, utilizado en versiones anteriores
# html_theme = 'alabaster'   # Un tema limpio y minimalista que es el tema predeterminado en Sphinx
# html_theme = 'nature'   # Otros temas que vienen con Sphinx y que pueden ser utilizados según las preferencias.
# html_theme = 'pyramid'   # Otros temas que vienen con Sphinx y que pueden ser utilizados según las preferencias.
# html_theme = 'agogo'   # Otros temas que vienen con Sphinx y que pueden ser utilizados según las preferencias.
# html_theme = "sphinx_book_theme"   # NO EXISTE - Usado en pypsa-eur



########## Esto es para intentar poner el botón de light/dark
##### html_static_path = ['_static']
##### 
##### # Añadir un archivo CSS personalizado
##### html_css_files = [
#####     'css/custom.css',
##### ]
##### 
##### html_js_files = [
#####     'custom.js',
##### ]


