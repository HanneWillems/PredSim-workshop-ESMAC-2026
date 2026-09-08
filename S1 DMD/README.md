# DMD Case

Physics-based computer simulations that can predict the effect of underlying impairments (e.g., muscle weakness and muscle stiffness) and treatments (e.g., Achilles tendon lengthening) on gait in children with Duchenne muscular dystrophy (DMD) have the potential to improve clinical decision-making. In this section, the user will personalize muscle parameters of a neuromusculoskeletal model based on the instrumented strength assessment and the clinical examination of a case with DMD and the user will simulate an intervention, i.e. Achilles tendon lengthening. 

The workflow you'll apply in this tutorial has been published in [Vandekerckhove et al.(2025)](https://jneuroengrehab.biomedcentral.com/articles/10.1186/s12984-025-01631-x)

### Step 0. Run a reference simulation with the 2D model
If you have not already done so, you need to run a reference simulation of healthy walking with the 2D model. Please follow the steps explained [here](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026?tab=readme-ov-file#running-a-reference-2d-simulation-with-predsim).

## Personalize muscle parameters based on instrumented assessment and clinical exam

In this section the user will use instrumented strength scores (step 1), and passive Range of Motion (ROM) scores and clinical stiffness scale scores (step 2) to personalize active muscle force and passive muscle stiffness in the Hill-type muscle model, respectively. In this tutorial, you will create a symmetrical model, so the clinical examination scores will be used for both the left and right sides. For future reference, you can also use this code to create asymmetrical models if you record left-right differences during the clinical examination. To save time, the user will only need to personalize the ankle muscles. We provide the hip and knee muscle personalizations.

To this end, you will edit the function [PredSim-workshop-ESMAC-2026/code/update_settings.m](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/code/update_settings.m). This function can later be used to run personalized simulations in PredSim.

### Step 1. Scaling muscle strength to model muscle weakness
The strength was assessed with fixed dynamometry. The user will scale the maximal active muscle force based on the instrumented strength scores to model subject-specific muscle weakness.

**Requirements:** web app [Anthropometric-related percentile curves for muscle strength of typically developing children](https://shiny.gbiomed.kuleuven.be/Z-score_calculator_muscle_strength/)

**Data:** Instrumented strength scores (mean joint torques), provided in [Clinical Exam/IWA_DMDcase.xlsx](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/Clinical%20Exam/IWA_DMDcase.xlsx)

**Additional information:** The protocol of the instrumented strength assessment is provided in [Documentation](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/tree/main/Documentation) (Optional content you can explore if you want to learn more)

1. Open the web app ([Anthropometric-related percentile curves for muscle strength of typically developing children](https://shiny.gbiomed.kuleuven.be/Z-score_calculator_muscle_strength/)).
2. Open the excel with the mean joint torques from the instrumented weakness assessment provided in the Clinical Exam folder ([Clinical Exam/IWA_DMDcase.xlsx](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/Clinical%20Exam/IWA_DMDcase.xlsx))
3. In the web app
 - Click on the tab `Ankle muscle strength` and enter body mass, height and mean ankle joint torques that are given in the excel file ([Clinical Exam/IWA_DMDcase.xlsx](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/Clinical%20Exam/IWA_DMDcase.xlsx))
<img width="253" height="342" alt="Screenshot_app_1" src="https://github.com/user-attachments/assets/03a05437-0578-417b-8be6-63df50a85069" />

 - Click `Calculate z-score`
<img width="277.5" height="325" alt="Screenshot_app_2" src="https://github.com/user-attachments/assets/306456cb-2707-423f-8b12-c69743abeb36" />

 - The web app will automatically plot the subject-specific torques on the TD percentile curves and compute z-scores as well as percentages relative to the median of the percentile curves (indicated via the red rectangle on the image below). You will use these percentages to scale the muscle strength of the model (in 4.)
<img width="4123" height="2071" alt="Screenshot_app_3" src="https://github.com/user-attachments/assets/1b742f52-eeff-413b-8f81-34579b370783" />

4. Open matlab and navigate to `PredSim-workshop-ESMAC-2026/code` in matlab. Open the function `update_settings.m`. You will add the setting `S.settings.muscle_strength` to this function to scale the model’s muscle strengths using the percentage values calculated in the web app. Specifically, copy and paste the code below into `update_settings.m`. We have already provided scaling factors for the hip and knee muscles (e.g., the strength of glut_max is scaled to 22% of its original value (i.e., multiplied by 0.22)). You only need to update the scaling factors for `tib_ant`, `gastroc`, and `soleus` using the percentages you calculated in the web app (remember: a strength value of 100% means the scaling factor should be 1 (not 100)) :

	 	S.settings.muscle_strength = {... 
			{'iliopsoas_r', 'iliopsoas_l'}, 0.435, ...									% hip_flex (provided)
			{'glut_max_r', 'glut_max_l'}, 0.22, ...										% hip_ext (provided) 
			{'rect_fem_r', 'vasti_r', 'rect_fem_l', 'vasti_l'}, 0.317, ...				% knee_ext (provided)
			{'bifemsh_r',  'bifemsh_l', 'hamstrings_r', 'hamstrings_l'}, 0.316, ...		% knee_flex (provided)
			{'tib_ant_r', 'tib_ant_l'}, 1, ...											% ankle_df (REPLACE THE '1' VALUES ON THIS LINE WITH YOUR OWN SCALING FACTORS FROM THE WEB APP (Remember: 100% = scaling factor 1.0, 50% = 0.5, etc.))
			{'gastroc_r', 'gastroc_l', 'soleus_r', 'soleus_l'}, 1,... 					% ankle_pf (REPLACE THE '1' VALUES ON THIS LINE WITH YOUR OWN SCALING FACTORS FROM THE WEB APP (Remember: 100% = scaling factor 1.0, 50% = 0.5, etc.))
			};
 
**Background:** The muscles in the model are represented as Hill-type muscle–tendon units. The muscle–tendon unit consists of an active contractile element in parallel with a passive element, which is in series with a tendon. The muscle force arises from both the active contractile component and the passive elastic element. The most common parametrization of this model assumes that maximal isometric force, and passive muscle and tendon stiffness are coupled. Therefore, they all scale with maximal isometric force. However, in DMD, active and passive muscle forces do not decrease simultaneously. The loss of contractile tissue is accompanied by its replacement with fat and fibrotic tissue, resulting in a decline in active muscle force while passive muscle stiffness increases. Therefore, we modeled muscle weakness by scaling only the active force component, rather than scaling maximal isometric force that also scales the passive elements.


### Step 2. Shifting the passive force-length curve to model passive muscle stiffness
Muscle stiffness was evaluated through passive ROM and clinical stiffness scale. The user will estimate the start of the passive force-length curves of the muscles based on the passive ROM and clinical stiffness scale to model subject-specific passive muscle stiffness. 

**Requirements:** OpenSim, Matlab.

**Data:** passive ROM and clinical stiffness scale values, provided in [Clinical Exam/Clinical_Exam_DMDCase.xlsx](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/Clinical%20Exam/Clinical_Exam_DMDcase.xlsx), reference passive ROM values for typically developing children from Mudge et al., matched to the case’s age, are provided in subfolder [Clinical Exam/Ref_ROM_TD.xlsx](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/Clinical%20Exam/Ref_ROM_TD.xlsx) 

**Code:** [Muscle stiffness code/Personalize_passive_muscle_stiffness_based_on_CE.m](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/Muscle%20stiffness%20code/Personalize_passive_muscle_stiffness_based_on_CE.m)

**Additional information:** The protocol of the clinical examination is provided in [Documentation](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/tree/main/Documentation) (Optional content you can explore if you want to learn more)

1. In matlab navigate to `PredSim-workshop-ESMAC-2026\S1 DMD\Muscle stiffness code` and open the script `Personalize_passive_muscle_stiffness_based_on_CE.m`. This code guides users through the estimation process of passive muscle stiffness based on clinical assessments.
 - For future use after the workshop: update lines 18-23 if the file paths or filenames change and update lines 27-62 if new clinical measurements are added and need to be linked to specific muscles

2. Run `Personalize_passive_muscle_stiffness_based_on_CE.m` by clicking the green 'Run' button. This script computes the start of the passive muscle force–length curve based on clinical examination data. It returns the normalized muscle length at which passive force begins, personalized using (1) ROM values and (2) the clinical stiffness scale. After running the script, matlab prints a table showing the shift calculated from ROM data, the shift from the clinical stiffness scale, and the average of the two.

3. Go back to `update_settings.m` in matlab (located in `PredSim-workshop-ESMAC-2026/code`) and change the setting `S.settings.muscle_pass_stiff_shift` to shift the passive force–length curves based on the clinical exam. Specifically, comment this line `S.subject.muscle_pass_stiff_shift = {{'iliopsoas_l', 'iliopsoas_r'}, 0.9};` by putting your cursor on this line and do Ctrl+R and add the code below instead into `update_settings.m`. We have already provided the shifts for the hip and knee muscles. You only need to update the shifts for `gastroc` and `soleus` using the average shift printed after running `Personalize_passive_muscle_stiffness_based_on_CE.m` (outcome from 2.) :

		% S.subject.muscle_pass_stiff_shift = {{'iliopsoas_l', 'iliopsoas_r'}, 0.9};
	 	S.subject.muscle_pass_stiff_shift = {{'tib_'},0.9,...							% ankle_df (provided)
     		{'gastroc_r','gastroc_l'},0.9,...											% gastroc (REPLACE THE '0.9' VALUES ON THIS LINE WITH YOUR OWN AVERAGE SHIFTS (Use the average shifts printed in the Matlab command window after running the script.))
     		{'soleus_l', 'soleus_r'}, 0.9,...											% soleus (REPLACE THE '0.9' VALUES ON THIS LINE WITH YOUR OWN AVERAGE SHIFTS (Use the average shifts printed in the Matlab command window after running the script.))
     		{'bifemsh_r',  'bifemsh_l', 'hamstrings_r', 'hamstrings_l'},0.90839,...		% knee_flex (provided)
     		{'iliopsoas_r', 'iliopsoas_l'},0.76948,...									% hip_flex (provided)
     		}; 	 	 

**Background:** In DMD, contractile tissue is not only lost but also replaced by fat and fibrotic tissue, resulting in increased muscle stiffness and eventually leading to contractures. We modeled this by shifting the passive muscle force-length relationship to shorter fiber lengths through a reduction in the fiber length at which passive muscle force begins to develop. We use the ROM measurements and clinical stiffness scale to estimate this shift. For the ROM measurements, we estimate the difference in fiber length at which the muscle starts to develop passive force between TD and DMD from the difference in joint angle at the end of ROM. The joint angle at the end of ROM of TD children was based on age-related reference data reported by Mudge et al. To estimate the corresponding difference in fiber length, we multiply the difference in measured joint angle at end ROM between TD and DMD (in radians) with the moment arm of the muscles in the anatomical position. This difference in fiber length was normalized to optimal fiber length to compute the shift of the passive force-length relationship. 
For the clinical stiffness scale, the normalized fiber length at which passive force starts to develop was assumed 1 when the clinical stiffness score was 0 (no increased resistance), 0.83 when the score was 1 (minimal increased resistance), 0.67 when the score was 2 (increased resistance), and 0.5 when the score was 3 (highly pronounced resistance) corresponding to a shift of respectively 0, 0.17, 0.33, and 0.5. These values were tested and used in [Vandekerckhove et al.(2025)](https://jneuroengrehab.biomedcentral.com/articles/10.1186/s12984-025-01631-x). 
We shifted the passive force-length relationship by the mean of the shifts estimated based on the ROM and clinical stiffness score.

### Step 3. Running PredSim with estimated muscle parameters:

The user will run a predictive simulation in [PredSim](https://github.com/KULeuvenNeuromechanics/PredSim) using a 2D model with DMD-specific muscle impairments. 
1. In Matlab navigate to the `PredSim` folder
2. Open the script `main.m` in Matlab by clicking on it ([PredSim/main.m](https://github.com/KULeuvenNeuromechanics/PredSim/blob/master/main.m))
3. Line 21 in `main.m` - add `S = update_settings(S);` This will update the settings of the 2D model with the calculated muscle weakness and stiffness.
4. Click on the green 'Run' button
5. After the iterations complete, check if you see **“EXIT: Optimal solution found.”** in the Matlab command window, then the optimization completed successfully and an optimal solution was obtained. Congratulations! 

### Step 4. Visualizing and plotting the results

Once your simulations are done, the results are stored in `PredSimResults\gait1018_esmac` as `gait1018_esmac_vx` as explained [here](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026?tab=readme-ov-file#predsimresults).

To visualize the mot file in OpenSim follow the steps described [here](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026?tab=readme-ov-file#visualizing-your-simulation-results-in-opensim).
   
To plot the kinematics of your simulations and compare them to the Experimental Data of the patient:
1. Open the script [run_this_file_to_plot_figures_DMD_ESMAC.m](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/PlotFigure/run_this_file_to_plot_figures_DMD_ESMAC.m) in matlab.
2. Edit the section marked `% ------- start edit -------` to `% ------- stop edit -------` (lines 14–45) to point to your own simulation results and configure which comparisons you want to see.

#### What to edit

**`results_folder`**
Set this to the folder on your machine where PredSim saves its output.

**`results_path`**
A struct that links a label (used in the legend) to the `.mat` file of a specific simulation. Only the fields you include here will be plotted. 

> ⚠️ **Note:** the version numbers (`_v1`,`_v2`, `_v3`, `_v4`, …) will be different for you, depending on how many simulations you've run and in what order. Check the `PredSimResults\gait1018_esmac` folder to confirm which version corresponds to which settings (reference, DMD_simulation), and update the paths accordingly.

> 💡 The field names you choose (`reference`, `DMD_simulation`) become the legend labels in your figures (spaces are inserted automatically instead of underscores), so keep them short and descriptive.

**`plot_experimental_kinematics`** *(true/false)*
Set to `true` to overlay the patient's own experimental IK envelope (from motion capture) on the kinematic plots. Set to `false` to skip this.

**`include_TD_reference`** *(true/false)*
Set to `true` to overlay a typically-developing (TD) reference envelope for comparison. Set to `false` to skip this.

**`apply_clinical_convention`** *(true/false)*
Set to `true` to convert joint angle signs/directions to the clinical convention (as typically reported in clinical gait analysis reports) instead of the raw OpenSim convention. This affects both the simulation curves and the experimental/TD reference curves, so keep it consistent across your figures.

**`legend_names`**
By default, this is generated automatically from the field names in `results_path`, with underscores replaced by spaces:

**`figure_folder`** and **`figure_savename`**
Control where figures are saved and the common prefix used in the filenames. By default, `figure_folder` points to the `IK` results folder and doesn't need to be changed unless you want figures saved elsewhere.
	
3. Click on the green 'Run' button

If you chose to plot the reference simulation and the DMD simulation against the experimental data of the patient (`plot_experimental_kinematics = true;`) and the TD experimental reference data (`include_TD_reference = true;`) and if you chose to apply the clinical convention (`apply_clinical_convention = true;`), the figure should look like this: 
<img width="3988" height="2956" alt="Figure for op github" src="https://github.com/user-attachments/assets/5014c851-7eea-49eb-8af8-97f27d270665" />


You can see that the simulation with DMD impairments (yellow line) is closer to the experimental data of the patient (yellow band), than the reference simulation (dark gray line). This means that incorporating the DMD-specific impairments into the model already brings the simulation closer to the experimental data. The DMD simulation predicts a tiptoeing gait pattern, which is also observed experimentally. However, the simulated gait still does not fully match the experimental data. This may be due to the use of a 2D model instead of a more accurate 3D model, and because not all mechanisms are yet captured in the simulations. We are currently working on further improving the models so that the simulation results better match the experimental data across all conditions. 
**⚠️ Be aware** that the simulations are based on a simplified 2D musculoskeletal model, while the experimental data represent full 3D kinematics. Consequently, differences between simulated and experimental curves may partly arise from model simplifications rather than true biomechanical discrepancies. 

## Optional: simulate the effect of Achilles tendon lengthening

In this section, the user will simulate an Achilles tendon release in the DMD case to predict the effect of this intervention. 
This treatment was often performed in patients with DMD who walk on their toes (tiptoeing gait), but may cause loss of ambulation. 

### Step 5. Simulate an Achilles tendon lengthening surgery

1. Go to `update_settings.m` in matlab (located in `PredSim-workshop-ESMAC-2026/code`) and change the setting `S.subject.scale_MT_params` to scale the tendon slack length (lTs) in order to simulate a Achilles tendon lengthening. Specifically, comment this line `S.subject.scale_MT_params = {{'tib_ant_l','tib_ant_r'},'lMo',0.85,{'tib_ant_l','tib_ant_r'},'FMo',0.5};` by putting your cursor on this line and do Ctrl+R  and add this line instead `S.subject.scale_MT_params = {{'tib_ant_l','tib_ant_r'},'lMo',0.85,{'tib_ant_l','tib_ant_r'},'FMo',0.5, {'soleus_l', 'soleus_r', 'gastroc_r', 'gastroc_l'}, 'lTs', 1.3};` in `update_settings.m`. This line will scale the tendon slack length (lTs) of both muscles (left and right) by 1.3 :
		
	% S.subject.scale_MT_params = {{'tib_ant_l','tib_ant_r'},'lMo',0.85,{'tib_ant_l','tib_ant_r'},'FMo',0.5};
   S.subject.scale_MT_params = {{'tib_ant_l','tib_ant_r'},'lMo',0.85,{'tib_ant_l','tib_ant_r'},'FMo',0.5, {'soleus_l', 'soleus_r', 'gastroc_r', 'gastroc_l'}, 'lTs', 1.3};	

Important: Do not change the other settings in `update_settings.m`. This way, you will simulate an Achilles tendon lengthening on a model that has DMD-specific muscle weakness and stiffness. 

### Step 6. Running PredSim with estimated muscle parameters:

The user will run a predictive simulation in [PredSim](https://github.com/KULeuvenNeuromechanics/PredSim) using a 2D model with DMD-specific muscle impairments and simulated Achilles tendon lengthening. 
1. In Matlab navigate to the `PredSim` folder
2. Open the script `main.m` in Matlab by clicking on it ([PredSim/main.m](https://github.com/KULeuvenNeuromechanics/PredSim/blob/master/main.m))
3. Click on the green 'Run' button
4. After the iterations complete, check if you see **“EXIT: Optimal solution found.”** in the Matlab command window, then the optimization completed successfully and an optimal solution was obtained.

⚠️ Note the message **“Converged to a point of local infeasibility. Problem may be infeasible.”** This indicates that no solution could be found. This may suggest that performing an Achilles tendon lengthening in this patient carries a risk of loss of ambulation.

### Step 7. Visualizing and plotting the results

To visualize the mot file in OpenSim follow the steps described [here](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026?tab=readme-ov-file#visualizing-your-simulation-results-in-opensim).
   
⚠️ Note that plotting the kinematics of the last simulation is not very useful because no solution was found (see visualization in OpenSim). The instructions below are therefore primarly intended for future use after the workshop.

To plot the kinematics of your simulations and compare them to the Experimental Data of the patient:  
1. Open the script [run_this_file_to_plot_figures_DMD_ESMAC.m](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026/blob/main/S1%20DMD/PlotFigure/run_this_file_to_plot_figures_DMD_ESMAC.m) in matlab.
2. Edit the section marked `% ------- start edit -------` to `% ------- stop edit -------` (lines 14–45) to point to your own simulation results and configure which comparisons you want to see. 

#### What to edit

**`results_path`**
Add your third simulation in this struct. You may want to comment lines 17-19 (highlight the lines and do Ctrl+R) and uncomment lines 21-22 (highlight the lines and do Ctrl+Shift+R). ⚠️ Don't forget to change the version number of your simulation results. 

You may also want to change the other settings depending on what you want to see (see instructions above). 

3. Click on the green 'Run' button

