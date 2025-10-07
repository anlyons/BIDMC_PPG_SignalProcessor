# Remote Healthcare: Future or Fallacy?

The main motivation for this project is to examine engineering and design frameworks for harnessing photoplethysmogram (PPG) data to empower physicians with remote wearable data for improved patient care. PPG data is acquired by many commercial smart watches by transmitting light into the skin and monitoring its transmittance or reflectance, which change when a heartbeat sends microvascular pressure waves. Things that change microvascular pressure can be imputed from PPG signals, such as variations in cardiac cycles, respiration, and blood pressure. 

Hundreds of millions of people use these devices, prompting interests in a future of remote healthcare where physicians have a direct link to patients in their daily lives. If this type of remote healthcare is possible, it could reduce physician load while facilitating new approaches to both preventitive and interventional medicine that could save lives. However, if done poorly, remote healthcare only stands to increase the noise in physician and patient lives at best and at worst could be detrimental to patient care. What would physician and patient users need in order to harness wearable PPG data? What are some factors we can explore using an engineering mindset that could help make remote healthcare using wearables a reality?

## User Needs
1. Safe, reliable readouts: Patients & physicians need reliable readouts of information for healthcare safety. If a patient has a cardiovascular emergency they dismiss when an alert doesn't come, their health is at risk from false negative readout. False positive readout could be very scary and costly if a patient pursues medical treatment they don't need.
2. Clinically interpretable, maximum quality info with minimum quantity: Continuous monitoring can produce a lot of data that physicians will not have the time to pour over, so processing that data to maximize interpretability 
3. Comfort/Convenience: Patient compliance to wearing the sensor continuously to maximize monitoring could be limited if it is not comfortable and convenient to use. If the battery depletes too quickly or takes too much time to charge, that is more time lost not monitoring a patient.

## Design/Engineering Components
Using PPG data to predict cardiac cycle properties, respiration, and blood pressure, here are some ways design and engineering can facilitate a future with remote healthcare through PPG data
- sig_proc: Optimizing PPG signal processing predictions across people for accuracy/reliability
- sampling_design: Balancing PPG sampling while acknowledging battery size, power consumption, & data storage
- data_dashboard: Assuming accurate and well sampled PPG data, provide physicians with quality patient information

## About the Dataset
https://physionet.org/content/bidmc/1.0.0/
