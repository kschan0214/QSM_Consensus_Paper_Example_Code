# Example Codes for QSM consensus data processing

Version: 0.2.1

## Introduction  

*This document can also be found in the supplementary material of the paper and the scripts are also shared with the data. This repository serves as an on-going site to provide update and version control on the QSM recon processing with the concensus paper data.*

The example codes implemented QSM reconstruction using the SEPIA framework. The example codes can be divided into two main sections:

1. (Optional) Data preparation (including shell scripts and Matlab scripts)
2. QSM recon pipeline (Matlab scripts only)

All scripts were tested in the two Unix enrivonments: (1) Linux CentOS 7 and (2) macOS 13.2. For Microsoft Windows users, you might need to explore an alternative way to run the shell scripts for the data preparation part, e.g. Gitbash, Cygwin or WLS (Unfortunately I do not have access to validate the shell scripts on Windows).

Before you getting started, please make sure you have the following setup ready in your computer:

### Environment

- Matlab R2016b onwards (except R2022b)

### Dependencies

- [dcm2niix](https://github.com/rordenlab/dcm2niix)(version 1.0.20220720)
- [SEPIA](https://github.com/kschan0214/sepia/releases/tag/v1.2.2.4) (v1.2.2.4)
- [MRITOOLS](https://github.com/korbinian90/CompileMRI.jl/releases/tag/v3.5.6) (v3.5.6)
- [MRI susceptibility calculation methods](https://xip.uclb.com/product/mri_qsm_tkd) (accessed 12 September 2019)
- [MEDI toolbox](http://pre.weill.cornell.edu/mri/pages/qsm.html) (release: 15th January 2020)
- [FANSI toolbox](https://gitlab.com/cmilovic/FANSI-toolbox) (v3)

## Data availability

Data are available from three vendors: GE, SIEMENS and PHILIPS, using the recommended acquisition in the main text. For each vendor, both monopolar and bipolar readout strategies were used to acquire the data for demonstration purposes. The data from GE and SIEMENS are not pre-scan normalized (which does not follow the recommendation), while the PHILIPS data have two normalization methods applied. In this way, we demonstrate the robustness of the proposed pipeline to a variety of implementations of the recommended protocol.

![data_availability](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/Data_availability.png?raw=true)

## Data preparation and organization

Background: There are two zip files available in Zenodo containing the example data organised in two different ways: 
(a)	“QSM_CONSENSUS_Paper_Example_DICOM_code.zip”
This zip file contains example DICOM images exported from the scanners without any modifications. The code directory accompanied with this file contains the scripts to (1) convert the DICOM images to NIFTI format, (2) organise the NIFTI images according to BIDS v1.8.0, and (3) perform QSM reconstruction.

(b)	“QSM_Consensus_Paper_example_Data_Result_Code.zip” 
This zip file contains all data and results that were produced by running all the scripts provided in the code directory. 

**Remark: The following Data Preparation section provides information on all the pre-processing steps to prepare the unmodified DICOM images to the BIDS format data that is ready for QSM reconstruction in SEPIA. If the readers are interested in the QSM reconstruction and work on the “QSM_Consensus_Paper_example_Data_Result_Code.zip” file only, they may skip Section “Data Preparation”.**

### Data preparation

The scripts created for this section were tested on a Mac system (macOS 13.2) and a Linux system (CentOS 7). These were not tested on Windows systems and would require adaptations to work on that OS.

#### Step 0: Download the DICOM data from online repository and unzip it. 

Once you uncompressed the file, you should see there is a compressed file, which contains all DICOM images, and a folder that contains all the scripts used for the processing.

Most imaging software in the field typically deals with images in Analyze or NIfTI format. As such the raw data (imaging data after coil combination) provided has to be converted to this format in 4 steps:

![data_preparation_step0](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/data_prep_step0.png?raw=true)

#### Step 1: Unzip the received data and reformat the directory structure

In this step, we are going to perform the following procedures:

1. Unzip the DICOM images to a new directory called 'raw' at the same location as the DICOM zip file.
2. Rename the ditectory structure so that all data are stored in a more 'standardised' structure

Open a command (terminal) window. Then go to 'QSM_Consensus_Paper_Example_Code/From_DICOM_zip_file_to_SEPIA_ready/' and run the shell script [Preparation_01_rename_received_data.sh](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/From_DICOM_zip_file_to_SEPIA_ready/Preparation_01_rename_received_data.sh):

`sh Preparation_01_rename_received_data.sh`

![data_preparation_step1_shell](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/data_prep_step1_shell.png?raw=true)

Once the processing is done, you should be able to see the following content:

![data_preparation_step1](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/data_prep_step1.png?raw=true)

#### Step 2: Convert DICOM images into NIfTI format

In this step, we are going to perform the following procedure:

1. Convert the DICOM images to compressed NIfTI format (.nii.gz). The NIfTI data will be stored in a new directory called 'converted' at the same location as 'raw'

Run the shell script [Preparation_02_convert_dicom2nii.sh](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/From_DICOM_zip_file_to_SEPIA_ready/Preparation_02_convert_dicom2nii.sh)

`sh Preparation_02_convert_dicom2nii.sh`

![data_preparation_step2_shell](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/data_prep_step2_shell.png?raw=true)

Once the processing is done, you should be able to see the following content:

![data_preparation_step2](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/data_prep_step2.png?raw=true)

#### Step 3: Rename the files according to the BIDS format

In this step, we are going to perform the following procedure:

1. Rename the compressed NIfTI files according to BIDS format. The naming strategy as follows:

- Vendors are identified using the session tag: **ses-<GE|PHILIPS|SIEMENS>**
- For **GE** and **SIEMENS**, different readout methods are identified using the acquisition tag: **acq-<Bipolar|Monopolar>**;
- For **PHILIPS**, the normalisation method is also printed on the acquisition tag, i.e., **acq-<BipolarCLEAR|BipolarSYNERGY|MonopolarCLEAR|MonopolarSYNERGY>**

Open Matlab. Then run the Matlab script [Preparation_03_rename_to_bids_format.m](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/From_DICOM_zip_file_to_SEPIA_ready/Preparation_03_rename_to_bids_format.m)

Once the processing is done, you should be able to see the following content:

![data_preparation_step3](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/data_prep_step3.png?raw=true)

#### Step 4: Prepare data for SEPIA

For PHILIPS and SIEMENS data, the data is already compatible to SEPIA input format (a directory containing magnitude multi-echo files + phase multi-echo files + JSON multi-echo files). However, for GE data, the complex-valued data is stored in real/imaginary format, which is currently not yet supported by SEPIA. To demonstrate the QSM recon for all data in a uniform way, the following procedures are applied: 

1. Combining individual multi-echo 3D volumes into a single 4D volume with TE in the 4th dimension
2. Obtaining header info (e.g., B0 direction and TE) from NIfTI header and JSON sidecar files and saving as SEPIA's header format
3. (GE only) Correcting inter-slice opposite polarity on real and imaginary images and exporting phase images from the corrected real/imaginary data

Run the Matlab script [Preparation_04_prepare_for_sepia.m](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/From_DICOM_zip_file_to_SEPIA_ready/Preparation_04_prepare_for_sepia.m)

Once the processing is done, you should be able to see the following content:

![data_preparation_step4](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/data_prep_step4.png?raw=true)

Now the data are ready for QSM recon in SEPIA!

### Data organization

The following tree diagram illustrates the directory structure of how the data are organised after running all the scripts provided in the code directory “QSM_Consensus_Paper_Example_Code/”. The content of the different directories is mentioned after the comment “%” symbol. Note that similar directories exist under the “/derivatives/SEPIA/SIEMENS/” and “/derivatives/SEPIA/PHILIPS/” as under “/derivatives/SEPIA/GE/”.

```
  QSM_Consensus_Paper_Example_DICOM_Code/
  |-- QSM_CONSENSUS_DATA.zip                      % zip file containing all DICOM images
  |-- protocols                                   % Protocol text files
  |-- QSM_Consensus_Paper_Example_Code            % containing all the scripts
  |   |-- doc                                     % Containing manual to use the Example data
  |   |-- From_DICOM_zip_file_to_SEPIA_ready      % Scripts for preparing QSM_CONSENSUS_DATA.zip to NIfTI images
  |   |-- SEPIA_Pipeline_FANSI 			              % SEPIA pipeline config files with FANSI recon
  |   `-- SEPIA_Pipeline_MEDI 			              % SEPIA pipeline config files with MEDI recon
  |-- raw                                         % folder containing all DICOM images, sorted by vendors
  |-- converted                                   % dcm2niix output
  |   |-- GE
  |   |   |-- Bipolar                             % Bipolar readout acquisition
  |   |   `-- Monopolar                           % Monopolar readout acquisition
  |   |-- PHILIPS
  |   |   |-- Bipolar_CLEAR                       % with CLEAR normalisation
  |   |   |-- Bipolar_SYNERGY                     % with SYNERGY normalisation
  |   |   |-- Monopolar_CLEAR
  |   |   `-- Monopolar_SYNERGY
  |   `-- SIEMENS
  |       |-- Bipolar
  |       `-- Monopolar
  `-- derivatives                                 % directory contains all derived output
      `-- SEPIA
          |-- GE
          |   |-- Bipolar
          |   |   `-- GRE
          |   |       |-- Pipeline_FANSI 	        % Full QSM recon using FANSI for dipole inversion
          |   |       `-- Pipeline_MEDI 	        % Full QSM recon using MEDI for dipole inversion
          |   `-- Monopolar
          |-- PHILIPS
          `-- SIEMENS
```

## QSM reconstruction pipeline

This section describes all the QSM reconstruction processing steps performed in SEPIA. **All the processing steps are specified in the SEPIA pipeline configuration files**, which are in the sub-directories of the script directory:

- 'QSM_Consensus_Paper_Example_Code/SEPIA_Pipeline_FANSI/' and
- 'QSM_Consensus_Paper_Example_Code/SEPIA_Pipeline_MEDI/'

corresponding to the two processing pipelines demonstrated as follows.

### Environment and dependencies

The data were processed using the following set-up

#### Operating system

- Linux CentOS 7

#### Environment

- Matlab R2021a (but the scripts are compatible to Matlab versions from R2016b to R2022a)

#### Dependencies

- [SEPIA](https://github.com/kschan0214/sepia/releases/tag/v1.2.2.4) (v1.2.2.4)
- [MRITOOLS](https://github.com/korbinian90/CompileMRI.jl/releases/tag/v3.5.6) (v3.5.6)
- [MRI susceptibility calculation methods](https://xip.uclb.com/product/mri_qsm_tkd) (accessed 12 September 2019)
- [MEDI toolbox](http://pre.weill.cornell.edu/mri/pages/qsm.html) (release: 15th January 2020)
- [FANSI toolbox](https://gitlab.com/cmilovic/FANSI-toolbox) (v3)

### QSM reconstruction using Example data

This section describes all the QSM reconstruction settings that were used on the example data. All the methods and algorithm parameters mentioned were already specified in the SEPIA pipeline configuration files (sepia_<GE|PHILIPS|SIEMENS>_<Monopolar|Bipolar>_config.m), which can be found in the sub-directories of the code folder “QSM_Consensus_Paper_Example_Code/”: 
“SEPIA_Pipeline_FANSI/” and “SEPIA_Pipeline_MEDI/”. Here, we provide an overview of the main parameters of each of these pipelines (Tables S1-S4) for the readers’ convenience.

#### Step 1: Preparation

- •	(GE only) Phase data is inverted before QSM recon processing (i.e., phase = -phase) so that paramagnetic susceptibility gives a positive value while diamagnetic susceptibility gives a negative value, same as the data from other vendors. This step was performed with the option provided by SEPIA
- Brain mask is obtained by using MEDI toolbox implementation of FSL's BET on the 1st echo magnitude image, using default setting -f 0.5 -g 0
- (Bipolar readout data only) Bipolar readout correction based on (Li et al., 2015) using the implementation provided with SEPIA.
-	Note that the relevant sequence parameters such as echo time and slice orientation are automatically derived from the data.

#### Step 2: Total field estimation and echo combination

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Echo phase combination | ROMEO total field calculation |  Dymerska et al., 2020 |
| MCPC-3D-S phase offset correction | On |  |
| Mask for unwrapping | SEPIA mask | FSL's BET mask |
| Using ROMEO Mask in SEPIA | Off |  |
| Exclude voxel using relative residual with threshold | 0.3 (applied on weighting map) | See [SEPIA's documentation](https://sepia-documentation.readthedocs.io/en/latest/method/weightings.html) |

#### Step 3: Background field removal

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Method | VSHARP | Li et al., 2011; SEPIA's implementation |
| Maximum spherical mean value filtering size | 12 | in voxel |
| Minimum spherical mean value filtering size | 1 | in voxel |
| Remove residual B1 field | No |  |
| Erode brain mask before BFR | 1 | in voxel |
| Erode brain mask after BFR | 0 |  |

#### Step 4: Dipole inversion

We demonstrate the dipole inversion steps with two recommended methods (FANSI and MEDI).

##### Step 4.1 : FANSI dipole inversion

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Method | FANSI | Milovic et al., 2019, 2018 |
| Iteration tolerance | 0.1 |  |
| Maximum number of iterations | 400 |  |
| Gradient L1 penalty, regularisation weight | 0.0005 |  |
| Gradient consistency weight | 0.05 |  |
| Fidelity consistency weight | 1 |  |
| Solver | 5 | Non-linear |
| Constraint | TV |  |
| Method for regularisation spatially variable weight | Vector field |  |
| Using weak harmonic regularisation | On |  |
| Harmonic constraint weight | 150 |  |
| Harmonic consistency weight | 3 |  |
| Reference tissue | Brain mask |  |

##### Step 4.2: MEDI Dipole inversion

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Method | MEDI | Liu et al., 2011 |
| Regularisation parameter (lambda) | 2000 |  |
| Method of data weighting | 1 |  |
| Percentage of voxels considered to be edges | 90 |  |
| Array size for zero padding | [0 0 0] |  |
| Performing spherical mean value operator | On |  |
| Radius of the spherical mean value operation | 5 | in voxel |
| Performing modal error reduction through iterative tuning (MERIT) | On |  |
| Performing automatic zero reference (MEDI+0) | Off |  |
| Reference tissue | Brain mask |  |

### Adaptation of the example pipeline to other studies

The provided SEPIA pipeline configuration file (sepia_<GE|PHILIPS|SIEMENS>_<Monopolar|Bipolar>_config.m) can be reused for other studies, assuming the data in these studies have the compatible input directory described in the SEPIA documentation website (https://sepia-documentation.readthedocs.io/en/latest/getting_started/Data-preparation.html):
This can be done by updating the “input” variable in the configuration file to the location of the input directory that contains all the essential data in your computer. Alternatively, if a graphical operation is preferred, the SEPIA pipeline configuration files can be imported to the SEPIA’s GUI by using the “Load config” button on the bottom left of the GUI display and then select the configuration .m file. The GUI will then be updated to the specified methods and algorithm parameters according to the text in the configuration file. Readers can then specify the required input and output information on the “I/O” panel on the GUI.

### Example results

Magnetic susceptibility maps with FANSI recon
![FANSI](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/example_fansi.png)

Magnetic susceptibility maps with MEDI recon
![MEDI](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/example_medi.png)

## References

[Dymerska, B., Eckstein, K., Bachrata, B., Siow, B., Trattnig, S., Shmueli, K., Robinson, S.D., 2021. Phase unwrapping with a rapid opensource minimum spanning tree algorithm (ROMEO). Magnetic resonance in medicine 85, 2294–2308.](https://doi.org/10.1002/mrm.28563)

[Li, J., Chang, S., Liu, T., Jiang, H., Dong, F., Pei, M., Wang, Q., Wang, Y., 2015. Phase-corrected bipolar gradients in multi-echo gradient-echo sequences for quantitative susceptibility mapping. Magma (New York, N.Y.) 28, 347–355.](https://doi.org/10.1007/s10334-014-0470-3)

[Li, W., Wu, B., Liu, C., 2011. Quantitative susceptibility mapping of human brain reflects spatial variation in tissue composition. Neuroimage 55, 1645–1656.](https://doi.org/10.1016/j.neuroimage.2010.11.088)

[Liu, T., Liu, J., Rochefort, L. de, Spincemaille, P., Khalidov, I., Ledoux, J.R., Wang, Y., 2011. Morphology enabled dipole inversion (MEDI) from a single-angle acquisition: Comparison with COSMOS in human brain imaging. Magnetic resonance in medicine 66, 777–783.](https://doi.org/10.1002/mrm.22816)

[Milovic, C., Bilgic, B., Zhao, B., Acosta-Cabronero, J., Tejos, C., 2018. Fast nonlinear susceptibility inversion with variational regularization. Magnetic resonance in medicine 80, 814–821.](https://doi.org/10.1002/mrm.27073)

[Milovic, C., Bilgic, B., Zhao, B., Langkammer, C., Tejos, C., Cabronero, J.A., 2019. Weak-harmonic regularization for quantitative susceptibility mapping. Magnetic resonance in medicine 81, 1399–1411.](https://doi.org/10.1002/mrm.27483)

