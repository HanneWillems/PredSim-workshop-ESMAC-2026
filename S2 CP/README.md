# Surgical intervention for Cerebral Palsy
### **Background:**   
Physics-based computer simulations, that can predict the effect of treatments (e.g., bony and soft tissue correction, ankle-foot-orthoses) on gait in children with cerebral palsy (CP), have the potential to improve clinical decision-making. To this end, an important challenge is to accurately estimate patient-specific neuromusculoskeletal models.

In this tutorial you will (I.) personalize for a child with Cerebral Palsy(CP). Next, (II.) you will model the effect of surgery and (III.) run a simulation and evaluate your results. The workflow you will apply in this tutorial has been published in [Van Den Bosch et al. (2025)](https://jneuroengrehab.biomedcentral.com/articles/10.1186/s12984-025-01767-w)

## Step 0: run a reference simulation with the 2D model
If you have not already done so, you need to run a reference simulation of healthy walking with the 2D model. Please follow the steps explained [here](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-smalll-2025?tab=readme-ov-file#running-a-reference-2d-simulation-with-predsim).

# I. Personalizing the musculoskeletal model
### **Background:**   
In this part you will personalize a model for a child with CP based on a clinical exam. The clinical exam is part of children's usual clinical care and is a comprehensive assesment of musculoskeletal functioning. 

In example 1. you will use (I.1) manual muscle testing strength scores to personalize optimal muscle force and (I.2) passive Range of Motion (ROM) scores  to personalize optimal muscle force and optimal muscle fiber length and coordinate limit torques.

To this end, you will create a settings file that can later be used in PredSim. In this tutorial you will change the model inputs in a default settings file. This file can later be used to run personalized simulations in PredSim.

### Step 1. Open [update_settings_pre.m](Code/update_settings_pre.m) in your Code folder
This file is a copy of the [default settings file](../code/update_settings.m) that is used to define custom user settings.

## I.1 Personalizing muscle strength
### **Background:**   
The strength is evaluated for the full active range of motion by manual muscle testing (MMT). The user will scale the maximal (active) muscle force based on the strength scores in the Clinical Exam. A lower MMT score refers to decreased strength. To represent muscle weakness in the model, maximal active fiber force of the muscles has to be scaled.

**Requirements:** Matlab.   
**Data:** MMT scores in the clinical exam (CE), provided in the folder [Clinical Exam](ClinicalExam). T0 refers to pre intervention and T1 to post intervention.       
**Additional information:** The protocol of the clinical exam, and normative values for all tests are provided in [Documentation](../Documentation)   

### Step 2. Scaling muscle strength
In this step you will scale muscle strength for the **muscles around the knee**. 

Copy the setting S.settings.muscle_strength below, and add to your update_settings_pre file. 

	S.settings.muscle_strength = {...       
		 {'glut_max_r'},0.3,...              	% R_hip_ext   
		 {'glut_max_l'},0.3,...               	% L_hip_ext 
		 {'iliopsoas_r'},0.7,...            	% R_hip_flex    
		 {'iliopsoas_l'},0.7,...             	% L_hip_flex  
		 {'hamstrings_r' 'bifemsh_r'},1,...  	% R_knee_flex %% to edit
		 {'hamstrings_l' 'bifemsh_l'},1,...  	% L_knee_flex %% to edit
		 {'rect_fem_r' 'vasti_r'},1,...      	% R_knee_ext  %% to edit
		 {'rect_fem_l' 'vasti_l'},1,...      	% L_knee_ext  %% to edit
		 {'gastroc_r' 'soleus_r'},0.3,...     	% R_ankle_pf  
		 {'gastroc_l' 'soleus_l'},0.5,...     	% L_ankle_pf
		 {'tib_ant_r'},0.3,...               	% R_ankle_df  
		 {'tib_ant_l'},0.3};                 	% L_ankle_df 
	  
This setting already includes the scaling factors for muscles acting on joints other than the knee. You still have to add the scaling factors for the knee flexors and knee extensors. Edit S.settings.muscle_strength in the settings file according to the strength scores in the clinical exam:
	
	Clinical Exam to strength scaling factor reference
	CE strength score    scaling factor
		 1           		0.05
		 2           		0.1
		 3           		0.3
		 4           		0.5
		 5           		0.7

	 EXAMPLE: 
	 CE strength score:	 	'strength_R_hip_ext' = 3 
	 In settings file: 		S.settings.muscle_strength = {{'glut_max_r'},0.3}

## I.2 Personalizing passive range of motion (pROM)
### **Background:**   
During the standardized clinical examination, goniometry is used to measure the passive range of motion (ROM). The ROM represents the maximum amplitude of the joint motion and is therefore an indication for muscle length. Therefore, when the pROM is smaller than normative values, there is a clinical indication for a contracture. Contractures are modelled by reducing optimal fiber length. When optimal fiber length is reduced, muscle fibers will be stretched more at the same muscle-tendon length resulting in higher passive forces. 

To determine the optimal fiber length for contracted muscles, the musculoskeletal model will be put in the same position as during the passive range of motion assessment. The optimal fiber length will then be adjusted so that the modeled net joint torque reaches 15 Nm at the end of the range of motion, matching the clinician’s resistance.

**Requirements:** Matlab, OpenSim, CasADi.   
**Data:** pROM scores, provided in the folder [Clinical Exam](ClinicalExam). T0 refers to pre intervention and T1 to post intervention.   
**Additional information:** The protocol of the clinical exam, and normative values are provided in [Documentation](../Documentation)      
**Code:**  [main_scale_lMo_sol_gas_hams.m](Code/main_scale_lMo_sol_gas_hams.m) and [main_scale_lMo_iliopsoas.m](Code/main_scale_lMo_iliopsoas.m) provided in the folder [Code](Code).    

### Step 3. Scaling muscle fiber length of the hamstrings
In this step you will scale the optimal muscle fiber length of the hamstrings.

Open the clinical exam file and evaluate the passive range of motion scores against normative values.  

		Clinical exam		Normative value
		pROM_Poplbi			-15° to 0°
		pROM_Ankledf0 		 10° to 20°
		pROM_Ankledf90		 20° to 30° 

As can be seen, no contracture is specified for the soleus and gastrocnemii, and the scaling factor for optimal fiber length (lMo) therefore remains 1. However, both left and right bilateral popliteal angles deviate from the normative value, so you have to model a contracture in both left and right hamstring muscles. 

Add a setting S.settings.scale_MT_params to your update_settings_pre file all muscles in the model to scale lMo:

	S.subject.scale_MT_params = {{'hamstrings_r'},'lMo',1,... 		% pROM_Poplbi_R %% to edit 
									{'hamstrings_l'},'lMo',1,... 	% pROM_Poplbi_L %% to edit 
									{'iliopsoas_r'},'lMo',1,...  	% explained in step 4
									{'iliopsoas_l'},'lMo',1,... 	% explained in step 4  (%% to edit)
									{'gastroc_r'},'lMo',1,...		% pROM_Ankledf0_R
									{'gastroc_l'},'lMo',1,...		% pROM_Ankledf0_L
									{'soleus_r'},'lMo',1,... 		% pROM_Ankledf90_R
									{'soleus_l'},'lMo',1};			% pROM_Ankledf90_L

	  
Open [main_scale_lMo_sol_gas_hams](/Code/main_scale_lMo_sol_gas_hams.m) and calculate scaling factors for the hamstrings. The code guides you through the estimation process and you only have to edit the lines of code that are inbetween:   
% ------ start edit -----    
            and   
% -----  end edit 	-----   

**EXAMPLE:**   
In this case you want to pick the scaling factor that gives the red line. A scaling factor of 60% would be 0.6 in the code.   
<img width="369" height="297" alt="lmo scale example" src="https://github.com/user-attachments/assets/2d02ad5f-13ed-464c-884b-abd892525ea2" />   
**⚠️ Note:** Run the file for both hamstrings seperately

Add the computed scaling factors to S.subject.scale_MT_params. 

### Step 4. Scaling muscle fiber length of iliopsoas
### **Background:**   
Because the evaluation of iliopsoas contractures is more detailed, the iliopsoas will require a different modeling approach. Iliopsoas contractures will lead to a different unilateral ($\theta_{\text{uni}}$). and bilateral ($\theta_{\text{bi}}$) popliteal angle. When assessing the unilateral popliteal angle, the contralateral leg is laying down. Iliopsoas contractures will cause flexion of the contralateral hip and this will be compensated for by anterior pelvis tilt, which in turn will lead to increased hip flexion to position the thigh of the evaluated leg vertically. Increased hip flexion will in turn increase bi-articular hamstrings length and will thus lead to a larger knee extension deficit. The increase in hip flexion angle is determined based on the difference in popliteal angles and the ratio of the average moment arms of all bi-articular hamstrings with respect to the knee and hip:

$$
\Delta \theta_{\text{hip}} =
\left( \theta_{\text{bi}} - \theta_{\text{uni}} \right)
\cdot
\frac{
\sum_{i=1}^{n} \frac{ma_{\text{knee},i}}{ma_{\text{hip},i}}
}{
n
}
$$

with _n_ the number of bi-articular hamstrings, $ma_{\text{hip}, i}$ and $ma_{\text{knee}, i}$ the moment arm of muscle _i_ around knee and hip when in the position of the bilateral popliteal angle. The contracture of the contralateral iliopsoas is determined by solving for the scaling factor that led to passive torque when the contralateral hip is extended beyond $\Delta \theta_{\text{hip}}$.

### **Instructions:**   
Open [main_scale_lMo_iliopsoas.m](Code/main_scale_lMo_iliopsoas.m) and calculate scaling factors for the iliopsoas. Again, the code guides you through the estimation process and you only have to edit the lines of code that are inbetween:  
% ------ start edit -----    
            and   
% -----  end edit 	-----   
**⚠️ Note:** A difference in uni- and bi- popliteal angle refers to a contracture in the **contralateral** iliopsoas (see background). In this step, you have to use the uni- and bi- popliteal angle of the right leg to compute the scaling factor of the left iliopsoas.


Add the computed scaling factors to S.subject.scale_MT_params. 

### Step 5. Adjusting coordinate limit torques
### **Background:**   
Observed knee extension and plantar flexion deficits are modeled by shifting the coordinate limit torques that model the stiffness of the non-muscle soft tissues around the joint.

### **Instructions:**   
Add a setting S.subject.set_limit_torque_coefficients_selected_dofs to your update_settings file for all dofs in the model.

	S.subject.set_limit_torque_coefficients_selected_dofs =...
			{{'lumbar_extension'},[-0.7644,11.2154,1.2788,-7.2704], [-0.3716,0.1068],...
            {'hip_flexion_r','hip_flexion_l'},[-2.44,5.05,1.51,-21.88],[-0.6981,1.81],...
            {'knee_angle_r','knee_angle_l'},[-6.09,33.94,11.03,-11.33],[-2.4,0.13],... %% to edit
            {'ankle_angle_r','ankle_angle_l'},[-2.03,38.11,0.18,-12.12],[-0.4363,0.6109]};

You will only change the last two values in each line as they represent rotational limits in radians. See the [PredSim documentation](https://github.com/KULeuvenNeuromechanics/PredSim/blob/master/Documentation/SettingsOverview.md) for an extensive description of all these parameters. 
For the knee that means:

	{'knee_angle_r','knee_angle_l'},[... ... ... ...],[flexion, extension]

Shift the limits such that they represent the observed end ROM knee extension angle from the clinical exam. The limits for plantar flexion have already been adjusted.
**⚠️ Note:** All joint limit values below are reported in **radians**, not degrees. 
	
	1 rad = 180/pi 
	
	EXAMPLE
	angle in degrees = 30
	angle in radians = 30 *pi/180 = 0.5236
	
	angle in radians = 0.5236
	angle in degrees = 0.5236 *180/pi = 30
	

### :tada: Congratulations you have personalized your model!  
To run a simulation with the personalized model scroll down to III. Running PredSim with personalized settings

# II. Simulate the effect of a surgical intervention
### **Background:**   
This patient underwent a bilateral distal femur extension osteotomy, a surgical procedure performed on both thighs to correct a knee extension deficit. In this operation, the surgeon removes a wedge-shaped piece of bone from the lower (distal) part of the femur (thigh bone). This wedge is taken from the anterior part of the distal femur. When the remaining bone ends are stabilised, the femur straightens, allowing the knee to move from a bent position toward a more normal extended position.    
In the model, this surgical correction shifts the knee geometry, this means that passive extension torques will begin to act at a more extended (= less negative) knee angle.

**Requirements:** Matlab.   
**Data:** pROM scores in the clinical exam (CE), provided in the [Clinical Exam](ClinicalExam). T0 refers to pre intervention and T1 to post intervention.   
**Additional information:** The protocol of the clinical exam, and normative values are provided in [Documentation](../Documentation)   

### Step 1: open [update_settings_post.m](Code/update_settings_post.m) in your Code folder and copy+paste all the settings that you previously defined in your pre-surgical settings (update_settings_pre.m)

### Step 2: Evaluate the clinical exam and change the knee extension deficit setting
Open the clinical exam post surgery ([CE_CP_T1](ClinicalExam)) in your ClinicalExam folder. (T0 refers to pre intervention and T1 to post intervention) 

Evaluate the knee extension pROM post surgery in CE_CP_T1  and change S.subject.set_limit_torque_coefficients_selected_dofs = ...{'knee_angle_r','knee_angle_l'}, accordingly, as you did in step 5.

# III. Running PredSim with personalized settings
### Step 1: open [main.m](https://github.com/KULeuvenNeuromechanics/PredSim/blob/master/main.m) in your ⚠️PredSim folder

### Step 2: adapt the code for your simulation
1. Line 20 - change to  [S] = initializeSettings('gait1018');   
2. Line 21 - add    	S = update_settings_pre(S); OR S = update_settings_post(S);
3. line 25 - change to 	S.subject.name = 'gait1018';  

### Step 3: Click the green :arrow_forward: button at the top of your screen to run the simulation :smiley:

##  Visualizing and plotting the results
Once your simulations are done, the results are stored in PredSimResults\gait1018 as gait1018_vx. Every time you run a simulation, the results are saved with an incremental version number: v1, v2, v3, v4, … The most recently run simulation always has the highest version number.

### To visualize the motion in OpenSim:
1. Open the model (File > Open Model...) PredSim/gait1018/gait1018.osim in OpenSim 
2. Load the .mot file (File > Load Motion...) PredSimResults/gait1018/gait1018_vx.mot in OpenSim
   
### To visualize the kinematics of your simulations and compare it to the experimental data of the patient:
1. Open the script [run_this_file_to_plot_figures_CP_SMALLL.m](Code/run_this_file_to_plot_figures_CP_SMALLL.m)
2. Change lines 12 to 29 with the .mat files containing the simulation results that you want to plot

	**⚠️ Be aware** that the simulations are based on a simplified 2D musculoskeletal model, while the experimental data represent full 3D 	kinematics. Consequently, differences between simulated and experimental curves may partly arise from model simplifications rather than 	true biomechanical discrepancies.	
	
