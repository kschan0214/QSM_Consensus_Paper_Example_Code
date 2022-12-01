# Example Codes for QSM consensus data processing

## Introduction  

The example codes implemented QSM reconstruction using the SEPIA framework. Before you getting started, please make sure you have the following setup ready in your computer:

### Environment

- Matlab R2016b onwards

### Dependencies

- [dcm2niix](https://github.com/rordenlab/dcm2niix)
- [SEPIA](https://github.com/kschan0214/sepia/releases/tag/v1.2) (v1.2)
- [MRITOOLS](https://github.com/korbinian90/CompileMRI.jl/releases/tag/v3.5.5) (v3.5.5)
- [MRI susceptibility calculation methods](https://xip.uclb.com/product/mri_qsm_tkd) (accessed 12 September 2019)
- [MEDI toolbox](http://pre.weill.cornell.edu/mri/pages/qsm.html) (release: 15th January 2020)
- [FANSI toolbox](https://gitlab.com/cmilovic/FANSI-toolbox) (v3)

## Data availability

Data are available from three vendors: GE, Siemens and Philips. For each vendor, both monopolar and bipolar readout strategies were used to acquire the data. The data from GE and Siemens are not pre-scan normalized, while the Philips data have two normalization methods applied.

![data_availability](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/Data_availability.png?raw=true)

## Data preparation and organization

This section describes all procedures performed to prepare SEPIA-ready data from the DICOM images.

**Remark: The following steps only required if you want to start the processing using the ‘QSM_CONSENSIS_DATA.zip’ file from a clean directory.**

### Data preparation

#### Step 0: Download the DICOM data from online repository and unzip it. 

You should see there is a compressed file, which contains all DICOM images, and a folder that contains all the scripts used for the processing.

#### Step 1: Unzip the received data and reformat the directory structure

In this step, we are going to perform the following procedures:

1. Unzip the DICOM images to a new directory called 'raw' at the same location as the DICOM zip file.
2. Rename the ditectory structure so that all data are stored in a more 'standardised' structure

Open a command (terminal) window. Then go to 'QSM_Consensus_Paper_Example_Code/From_DICOM_zip_file_to_SEPIA_ready/' and run the shell script 'Preparation_00_rename_received_data.sh':

`sh Preparation_00_rename_received_data.sh`

#### Step 2: Convert DICOM images into NIfTI format

In this step, we are going to perform the following procedure:

1. Convert the DICOM images to compressed NIfTI format (.nii.gz). The NIfTI data will be stored in a new directory called 'converted' at the same location as 'raw'

Run the shell script 'Preparation_01_convert_dicom2nii.sh'

`sh Preparation_00_rename_received_data.sh`

#### Step 3: Rename the files according to the BIDS format

In this step, we are going to perform the following procedure:

1. Rename the compressed NIfTI files according to BIDS format. The naming strategy as follows:

- Vendors are identified using the session tag: **ses-<GE|PHILIPS|SIEMENS>**
- For **GE** and **SIEMENS**, different readout methods are identified using the acquisition tag: **acq-<Bipolar|Monopolar>**;
- For **PHILIPS**, the normalisation method is also printed on the acquisition tag, i.e., **acq-<BipolarCLEAR|BipolarSYNERGY|MonopolarCLEAR|MonopolarSYNERGY>**

Open Matlab. Then run the Matlab script 'Preparation_02_rename_to_bids_format.m'

#### Step 4: Prepare data for SEPIA

For PHILIPS and SIEMENS data, the data is already compatible to SEPIA input format (a directory containing magnitude multi-echo files + phase multi-echo files + JSON multi-echo files). However, for GE data, the complex-valued data is stored in real/imaginary format, which is currently not yet supported by SEPIA. To demonstrate the QSM recon for all data is a uniform way, the following procedures are applied: 

1. Combining individual multi-echo 3D volumes into a single 4D volume with TE in the 4th dimension
2. Obtaining header info (e.g., B0 direction and TE) from NIfTI header and JSON sidecar files and saving as SEPIA's header format
3. (GE only) Correcting inter-slice opposite polarity on real and imaginary images and exporting phase images from the corrected real/imaginary data

Run the Matlab script 'Preparation_03_prepare_for_sepia.m'

Now the data are ready for QSM recon in SEPIA!

### Data organization

The data should be organised in the following way after the above operations

```
  QSM_consensus_paper/
    |-- converted                               % dcm2niix output
    |   |-- GE
    |   |   |-- Bipolar
    |   |   `-- Monopolar
    |   |-- PHILIPS
    |   |   |-- Bipolar_CLEAR
    |   |   |-- Bipolar_SYNERGY
    |   |   |-- Monopolar_CLEAR
    |   |   `-- Monopolar_SYNERGY
    |   `-- SIEMENS
    |       |-- Bipolar
    |       `-- Monopolar
    |-- derivatives                             % directory contains all derived output
    |   |-- ANTs
    |   `-- Coregistration
    |       `-- Transform                       % rigid body transform matrices to common (MNI) space
    | `-- SEPIA                                 % SEPIA output
    |   |-- GE
    |   |   |-- Bipolar
    |   |   |   `-- GRE
    |   |   |       `-- Pipeline_Standard       % Standard reconstruction output
    |   |   |       |-- Pipeline_Alternative1   % Dipole inversion alternative 1 output
    |   |   |       `-- Pipeline_Alternative2   % Dipole inversion alternative 2 output
    |   |   `-- Monopolar
    |   |-- PHILIPS
    |   `-- SIEMENS
    |-- protocols     % Protocol text files
    |-- raw     % DICOM images
    |   |-- GE
    |   |   |-- Bipolar             % Bipolar readout acquisition
    |   |   |   `-- GRE
    |   |   `-- Monopolar           % Monopolar readout acquisition
    |   |-- PHILIPS
    |   |   |-- Bipolar_CLEAR       % with CLEAR normalisation
    |   |   |-- Bipolar_SYNERGY     % with SYNERGY normalisation
    |   |   |-- Monopolar_CLEAR
    |   |   `-- Monopolar_SYNERGY
    |   `-- SIEMENS
    |       |-- Bipolar
    |       `-- Monopolar
    `-- QSM_Consensus_Paper_Example_Code % containing all the scripts
        |-- SEPIA_Standard_Pipeline         % SEPIA pipeline config files for Standard
        |-- SEPIA_Alternative1_Pipeline     % SEPIA pipeline config files for Alternative 1 (MEDI)
        `-- SEPIA_Alternative2_Pipeline     % SEPIA pipeline config files for Alternative 2 (FANSI)
```

## QSM reconstruction pipeline

This section describes all the QSM reconstruction processing steps performed **in SEPIA**. All the processing steps are specified in the SEPIA pipeline configuration files, which are in the sub-directories of the script directory: QSM_Consensus_Paper_Example_Code/SEPIA_Standard_Pipeline/’, QSM_Consensus_Paper_Example_Code/SEPIA_Alternative1_Pipeline/’ and QSM_Consensus_Paper_Example_Code/SEPIA_Alternative2_pipeline/’, corresponding to the three processing pipelines demonstrated as follows.

### Environment and dependencies

The data were processed using the following set-up

#### Operating system

- Linux CentOS 7

#### Environment

- Matlab R2022a (but the scripts are backwards compatible to early Matlab version from R2016b onwards)

#### Dependencies

- [SEPIA](https://github.com/kschan0214/sepia/releases/tag/v1.2) (v1.2)
- [MRITOOLS](https://github.com/korbinian90/CompileMRI.jl/releases/tag/v3.5.5) (v3.5.5)
- [MRI susceptibility calculation methods](https://xip.uclb.com/product/mri_qsm_tkd) (accessed 12 September 2019)
- [MEDI toolbox](http://pre.weill.cornell.edu/mri/pages/qsm.html) (release: 15th January 2020)
- [FANSI toolbox](https://gitlab.com/cmilovic/FANSI-toolbox) (v3)

### Processing steps

#### Step 1: Preparation

- (GE only) Phase data is inverted before processing (i.e., phase = -phase), so that paramagnetic susceptibility gives a positive value while diamagnetic susceptibility gives a negative value, same as the other data
- Brain mask is obtained by using MEDI toolbox implementation of FSL's BET on the 1st echo magnitude image, using default setting -f 0.5 -g 0
- (Bipolar readout data only) Bipolar readout correction based on (Li et al., 2015) using the implementation provided with SEPIA.

#### Step 2: Total field estimation and echo combination

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Echo phase combination | ROMEO total field calculation |  Dymerska et al., 2020 |
| MCPC-3D-S phase offset correction | On |  |
| Mask for unwrapping | SEPIA mask | FSL's BET mask |
| Using ROMEO Mask in SEPIA | Off |  |
| Exclude voxel using relative residual with threshold | 0.3 (applied on weighting map) | See <https://sepia-documentation.readthedocs.io/en/latest/method/weightings.html> |

#### Step 3: Background field removal

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Method | VSHARP | Li et al., 2011 |
| Spherical mean value filtering size | 12 | in mm |
| Remove residual B1 field | No |  |
| Erode brain mask before BFR | 1 | in voxel |
| Erode brain mask after BFR | 0 |  |

#### Step 4: Dipole inversion (corresponding to “Standard” pipeline)

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Method | Iterative Tikhonov | Karsa et al., 2020; Schweser et al., 2013 |
| Regularisation parameter (lambda) | 0.1 |  |
| Conjugate gradient tolerance | 0.03 |  |
| Reference tissue | Brain mask |  |

### Alternative dipole inversion methods: (MEDI and FANSI)

#### Step 4 (Alternative 1): Dipole inversion

**Output from the ‘Standard’ pipeline is required. The scripts are in QSM_Consensus_Paper_Example_Code/SEPIA_Alternative1_Pipeline/’.**

| Parameters | Values | Remark |
| ----------- | ----------- | ----------- |
| Method | MEDI | Liu et al., 2011 |
| Regularisation parameter (lambda) | 2000 |  |
| Method of data weighting | 1 |  |
| Percentage of voxels considered to be edges | 90 |  |
| Array size for zero padding | [0 0 0]] |  |
| Performing spherical mean value operator | On |  |
| Radius of the spherical mean value operation | 5 | in voxel |
| Performing modal error reduction through iterative tuning (MERIT) | On |  |
| Performing automatic zero reference (MEDI+0) | Off |  |
| Reference tissue | Brain mask |  |

#### Step 4 (Alternative 2): Dipole inversion

**Output from the ‘Standard’ pipeline is required. The scripts are in QSM_Consensus_Paper_Example_Code/SEPIA_Alternative2_Pipeline/’.**

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

### Example results

![example_results](https://github.com/kschan0214/QSM_Consensus_Paper_Example_Code/blob/main/docs/Figures/standard_chimap.png?raw=true)

## References

Dymerska, B., Eckstein, K., Bachrata, B., Siow, B., Trattnig, S., Shmueli, K., Robinson, S.D., 2020. Phase unwrapping with a rapid opensource minimum spanning tree algorithm (ROMEO). Magnet Reson Med. <https://doi.org/10.1002/mrm.28563>

Karsa, A., Punwani, S., Shmueli, K., 2020. An optimized and highly repeatable MRI acquisition and processing pipeline for quantitative susceptibility mapping in the head-and-neck region. Magnet Reson Med. <https://doi.org/10.1002/mrm.28377>

Li, J., Chang, S., Liu, T., Jiang, H., Dong, F., Pei, M., Wang, Q., Wang, Y., 2015. Phase-corrected bipolar gradients in multi-echo gradient-echo sequences for quantitative susceptibility mapping. Magma (New York, N.Y.) 28, 347–355. <https://doi.org/10.1007/s10334-014-0470-3>

Li, W., Wu, B., Liu, C., 2011. Quantitative susceptibility mapping of human brain reflects spatial variation in tissue composition. Neuroimage 55, 1645–1656. <https://doi.org/10.1016/j.neuroimage.2010.11.088>

Liu, T., Liu, J., Rochefort, L. de, Spincemaille, P., Khalidov, I., Ledoux, J.R., Wang, Y., 2011. Morphology enabled dipole inversion (MEDI) from a single-angle acquisition: Comparison with COSMOS in human brain imaging. Magnetic resonance in medicine 66, 777–783. <https://doi.org/10.1002/mrm.22816>

Milovic, C., Bilgic, B., Zhao, B., Acosta-Cabronero, J., Tejos, C., 2018. Fast nonlinear susceptibility inversion with variational regularization. Magnetic resonance in medicine 80, 814–821. <https://doi.org/10.1002/mrm.27073>

Milovic, C., Bilgic, B., Zhao, B., Langkammer, C., Tejos, C., Cabronero, J.A., 2019. Weak-harmonic regularization for quantitative susceptibility mapping. Magnetic resonance in medicine 81, 1399–1411. <https://doi.org/10.1002/mrm.27483>

Schweser, F., Deistung, A., Sommer, K., Reichenbach, J.R., 2013. Toward online reconstruction of quantitative susceptibility maps: superfast dipole inversion. Magnetic resonance in medicine 69, 1582–1594. <https://doi.org/10.1002/mrm.24405>

