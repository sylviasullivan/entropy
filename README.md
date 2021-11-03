# entropy
Codes to use information entropy to quantify convective organization:

*entropy.m* - a MATLAB code to test entropy calculation on randomly-generated matrices using the checkerboard function

*entropyVis.py* - visualizes entropy in a surface plot as a function of time and ``neighborhood extent", or spatial kernel size

*entropy\_driver.f90* - driver program to run either *entropy\_profile\_continuous.f90* or *entropy\_profile\_binary.f90*. Change the module used in the header of the driver to switch between these two. The time and spatial dimensions of the field are also specified here, so that the output entropy matrix can be properly allocated. 

*entropy\_profile\_binary.f90* - use a binary variable, like cloud fraction at high resolution or MCS occurrence, to evaluate entropy. *subroutine entropy\_run* opens the netcdf file and saves the input variable to a matrix. It then iterates timepoint-by-timepoint over this matrix and passes submatrices to *moving\_window\_filter*, where a spatial kernel of dimensions *window\_size* is swept over to create *output\_mat*. Finally *output\_mat* is passed to *same\_val\_prob* to calculate probabilities that values in the upper left corner match the others identically. These probabilities are finally used to calculate entropy in *calc\_entropy* and then saved to an external file within *entropy\_run*.

*entropy\_profile\_continuous.f90* - use a continuous variable, like cloud liquid or ice water content, and a threshold value in this variable to evaluate entropy. *subroutine entropy\_run* opens the netcdf file and saves the input variable to a matrix. It then iterates timepoint-by-timepoint over this matrix and passes submatrices to *moving\_window\_filter*, where a spatial kernel of dimensions *window\_size* is swept over to create *output\_mat*. Finally *output\_mat* is passed to *thresh\_val\_prob* to calculate probabilities that values in the upper left corner match the others within a certain threshold. These probabilities are finally used to calculate entropy in *calc\_entropy* and then saved to an external file within *entropy\_run*.

*Makefile_binary* - the Makefile to compile *entropy\_profile\_binary* and *entropy\_driver* and generate an executable from the latter

*submit_entropy.sh* - a sample script to compile and execute the entropy algorithm on Habanero

Some extra non-code resources:

*entropy-schematic.pdf* - a visualization of the algorithm to calculate entropy

*entropySeries.pdf* - a visualization of how entropy decreases as the ``neighborhood extent", or spatial kernel size, approaches that of a characteristic feature size, e.g. the size of convective coverage

*Hsurf_ocean_D576_T305.pdf* - example of a surface plot of entropy (versus time and neighborhood extent) generated from Sara Shamekh's SAM output over an ocean with SST of 305 K

*information-entropy.pptx* - some theoretical tests with *entropy.m* above and checkboard matrices

*lit-review-organization-metrics.pdf* - contains a description of the information entropy calculation, as well as a short review of some other convective organization metrics

