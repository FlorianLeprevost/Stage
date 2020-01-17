# Stage
MATLAB scripts pipeline HEP analysis

## Scripts
1. heart_detect_plus_EVENT_STATS.m
 - uses heart_peak_detect.m and Read_iEEG_data.m
 - creates patient_number_Heart_info.mat with an event and a trl file
 - does basic distribution statistics


2. pipeline_florian_bipolar_macro_extract.m
 - use Read_iEEG_data.m and need Heart_info in workspace to work
 - extract, rereference, downsample and timelock on R peaks an entire macro-electrode
 - creates a fieldtrip structure data_final saved (among many other inter-step data) in data_patient_number_macro_name.mat


3. EDA.m
 - need Heart_info (stats variable) + data_final_trial in workspace to wotk
 - remove outliers
 - plot averaged trials of several bipolar channels by bins ordered by IBI next, previous and difference
 - creates a fieldtrip structure with data without outliers and only the desired channels


4. spectral_ana_adapted_from_magdalena
 - pretty straightforward title
 - used PUPIL_script_ECG_preprocessing from Magdalena to do time series spectral analysis
