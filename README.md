actiCircadian
================
### Overview
Perform parametric and non-parametric analysis for extraction of circadian features from actigraphy data. 

Cosinor (parametric) analysis is based on Cornelissen, G., 2014. Cosinor-based rhythmometry. Theoretical Biology and Medical Modelling, 11(1), p.16. and it provides Magnitude, Phase, and MESOR of the rhythm.

Non-parametric analysis is based on Van Someren, E.J., Swaab, D.F., Colenda, C.C., Cohen, W., McCall, W.V. and Rosenquist, P.B., 1999. Bright light therapy: improved sensitivity to its effects on rest-activity rhythms in Alzheimer patients by application of nonparametric methods. Chronobiology international, 16(4), pp.505-518. and Gonçalves, B.S., Cavalcanti, P.R., Tavares, G.R., Campos, T.F. and Araujo, J.F., 2014. Nonparametric methods in actigraphy: An update. Sleep Science, 7(3), pp.158-164.

Tested on Matlab R2015b, can be used in Octave (should have the io package and the statistics package installed)

You will need Casey Cox's cosinor.m function with its subfunction CIcalc.m. Download them from: https://www.mathworks.com/matlabcentral/fileexchange/20329-cosinor-analysis/content/html/cosinor.html

### How to prepare your data
The algorithms have been prepared with activity counts in mind, thus, if you have accelerations, you should employ integration or other method to obtain activity counts. In the case of a 3-axial accelerometer, the algorithm employs axis 1.

All your files should be saved in xlsx format, similar to the files Example.xlsx. Variable names for each column are:
1. ID (e.g. 001)
2. Date (e.g. 1/1/2017 - any format should work, as long as in Excel date format)
3. Time (e.g. 1:01 PM - any format should work, as long as in Excel time format)
4. Axis1	activity counts, 1 sample per minute (this is what we use for the analysis)
5. Axis2	activity counts, 1 sample per minute (can be left empty - not used)
6. Axis3	activity counts, 1 sample per minute (can be left empty - not used)
7. VM magnitude, = sqrt(Axis1^2 + Axis2^2 + Axis3^2)	(can be left empty- not used)
8. Steps	(optional -not used)
9. Lux (optional -not used)
10. Awake/sleep (S/W or 1 for sleep and 0 for wake)
11. Wear/non wear	(w/nw or 1 for wear, 0 for non wear)
12. Weekday (day of the week (e.g. Monday) or 1 for weekday, 0 for weekend)
13. Work/non work (1 for work, 0 for non-work, leave empty if not available)
14. Rest/non rest (1 for rest, 0 for non-rest, leave empty if not available)

•	All files, one per subject, should be saved in .xlsx format, in a folder

•	The script generates 5 Results spreadsheets, with one row per subject
- Whole recording
- Weekdays
- Weekends
- Work days
- Days off

### Non-Parametric Analysis
Computes the following variables:
- Interdaily Stability (IS). Quantifies the invariability between the days, i.e., the strength of coupling of the rhythm to supposedly stable environmental zeitgebers. IS = 0 for for Gaussian noise; IS =1 for perfect IS
- Intradaily Variability (IV). Gives an indication of the rhythm, i.e., the frequency and extent of transitions between rest and activity. IV = 0 for perfect sine wave; IV ≅2 for Gaussian noise; IV > 2 when definite ultradian component is present
- L5 : Least active 5-hour period --> midpoint in time and activity counts
- M10 : Most active 10-hour period --> midpoint in time and activity counts
- amplitude = M10-L5
- RA : Relative Amplitude. RA=(M10-L5)/(M10+L5)

### Cosinor Analysis
Employs Casey Cox's cosinor.m function: https://www.mathworks.com/matlabcentral/fileexchange/20329-cosinor-analysis/content/html/cosinor.html
Returns the following variables in a struct:
- Amplitude. Average difference between max and min activity
- Midline Estimating Statistic Of Rhythm (MESOR). Baseline activity
- Phase. Time to the point of peak activity.

Please make sure (modify the function accordingly if needed) that cosinor.m returns a single output, cosinorStruct, where
cosinorStruct.Mesor=M;
cosinorStruct.PhiHours=phi;
cosinorStruct.Amp=Amp;

### Considerations:
- The algorithm uses Axis 1 of the actigraphy by default. 
- The algorithm employs an integer number of days, and starts the analysis at 7 AM of each day
- Days with excessive non-wear time are discarded according to this criterion: valid days must have no more than 1 hour of non-wear time during sleep and at least 10 hours of wear time during wakefulness
- The algorithm outputs 22 values for IS and 22 values for IV for each analysis. This choice is compatible with (Gonçalves, B.S., Cavalcanti, P.R., Tavares, G.R., Campos, T.F. and Araujo, J.F., 2014. Nonparametric methods in actigraphy: An update. Sleep Science, 7(3), pp.158-164), where the measures are given for 22 different bin sizes. IV60 and IS60 correspond to the traditional hourly values
- For L5 and M10, the function amplitudes.m computes the average activity profile over all the days, then can either use a simple moving window of 5 hours and 10 hours, respectively (default option), or a further smoothing via the filtfilt function
- When breaking files into work/non work or weekday/weekend, we also include the first 7 hours of the next day. This means, each weekend starts at 7 am on Saturday and ends at 7 am on Monday. Each work week starts at 7 am on Monday and ends at 7 am on Saturday.
