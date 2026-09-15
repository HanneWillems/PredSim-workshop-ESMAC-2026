# Surgical intervention for Cerebral Palsy

| Section                    | What you will find                                                     |
| -------------------------- | ---------------------------------------------------------------------- |
| **Background**             | Brief explanation of the concept and why the parameter is personalized |
| **Requirements**           | Software needed to complete the step                                   |
| **Data**                   | Required data                                                          |
| **Additional information** | Protocols and normative values for the clinical tests                  |

Want to quickly go through this example? Simply follow the step instructions and skip the Background and Additional information sections.

**Background:**
Cerebral palsy (CP) is caused by a non-progressive lesion of the developing brain, resulting in impaired motor control and secondary musculoskeletal impairments. These impairments can lead to pathological gait patterns. Treatment decisions aim to improve gait function but their effect can be difficult to predict.

Physics-based computer simulations, that can predict the effect of treatments (e.g., bony and soft tissue correction, ankle-foot-orthoses) on gait in children with CP, have the potential to improve clinical decision-making. To this end, an important challenge is to accurately estimate patient-specific model parameters.

In this tutorial you will (I.) personalize a neuromusculoskeletal model for a child with CP. Next, (II.) you will model the effect of surgery and (III.) run simulations to evaluate the predicted gait pattern. The workflow you will apply in this tutorial has been published in [Van Den Bosch et al. (2025)](https://jneuroengrehab.biomedcentral.com/articles/10.1186/s12984-025-01767-w)

## Step 0: run a reference simulation with the 2D model
If you have not already done so, you need to run a reference simulation of healthy walking with the 2D model. Please follow the steps explained [here](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-esmac-2026?tab=readme-ov-file#running-a-reference-2d-simulation-with-predsim).

# I. Personalizing the musculoskeletal model

### Summary
In this step, you will personalize the maximal active muscle force of the muscles based on the strength scores obtained during the Clinical Exam (CE).

**Background:**
In this part you will personalize a model for a child with CP based on a clinical exam. The clinical exam is part of children's usual clinical care and is a comprehensive assessment of musculoskeletal functioning. The personalization process modifies different muscle-tendon properties to represent patient-specific impairments. These modifications affect the active and passive force–length relationships of the muscles, as illustrated below.

<img width="1774" height="575" alt="fig_muscle_tendon_properties_scaling" src="https://github.com/user-attachments/assets/0cfed741-a472-4051-993d-3efbb9ab882a" />

In example 1. you will use (I.1) manual muscle testing strength scores to personalize muscle strength and (I.2) passive Range of Motion (pROM) scores to personalize optimal muscle fiber length (lMo) and coordinate limit torques.

In this tutorial you will change the model inputs in a default settings file. This file can later be used to run personalized simulations in PredSim.

## I.1 Personalizing muscle strength

**Background:**
The strength is evaluated for the full active range of motion by manual muscle testing (MMT). You will scale the maximal (active) muscle force based on the strength scores (MMT scores) in the Clinical Exam. A lower MMT score refers to decreased strength; to represent this in the model, the maximal active fiber force of the muscles has to be scaled.

**Requirements:** Matlab.
**Data:** MMT scores in the clinical exam (CE) [`CE_CP_ESMAC_T0_T1`](ClinicalExam/CE_CP_ESMAC_T0_T1.xlsx), provided in the folder [ClinicalExam](ClinicalExam). `T0` refers to pre intervention and `T1` to post intervention.
**Additional information:** The protocol of the clinical exam, and normative values for all tests, are provided in [Documentation](../Documentation)

### Step 1. Open `update_settings_pre.m`
Open [update_settings_pre.m](Code/update_settings_pre.m) in your Code folder (e.g. `PredSim-workshop-ESMAC-2026\S2 CP\Code`).

This file is a copy of the [default settings file](../code/update_settings.m) that is used to define custom user settings.

### Step 2. Scaling muscle strength
In this step you will scale muscle strength for the **muscles around the knee**. The scaling factors represent the remaining percentage of maximal muscle force (FMo) in the model. As shown in the "Scaling muscle strength" panel of the figure above, reducing this parameter decreases the maximum force-generating capacity of the muscle and represents muscle weakness.

**To do:**

1. Copy the `S.settings.muscle_strength` setting below and add it to your `update_settings_pre` file.

```matlab
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
```

The setting already includes the scaling factors for muscles acting on joints other than the knee. You only need to edit the scaling factors for the **knee flexors and knee extensors**.

2. Open [`CE_CP_ESMAC_T0_T1.xlsx`](ClinicalExam/CE_CP_ESMAC_T0_T1.xlsx) in **Excel** for the best viewing experience:
    * Navigate to the `ClinicalExam` folder on your PC, **or**
    * In MATLAB's **Files** panel, right-click the file and select **Open Outside MATLAB**

> **⚠️ Note:** `T0` refers to the pre-intervention assessment and `T1` refers to the post-intervention assessment.

3. Find the strength scores for the **right and left knee flexors** and **right and left knee extensors**.
4. Use the reference table below to convert each CE strength score into a scaling factor.
5. Edit the four knee-related scaling factors in `S.settings.muscle_strength`:
   * `R_knee_flex`
   * `L_knee_flex`
   * `R_knee_ext`
   * `L_knee_ext`

* Leave the scaling factors for the other muscle groups unchanged.

**Clinical Exam strength score → scaling factor**

| CE strength score | Scaling factor |
| ----------------: | -------------: |
|                 1 |           0.05 |
|                 2 |            0.1 |
|                 3 |            0.3 |
|                 4 |            0.5 |
|                 5 |            0.7 |

**Example:**

If the Clinical Exam strength score is:

```matlab
strength_R_knee_flex = 3
```

enter the corresponding scaling factor:

```matlab
S.settings.muscle_strength = {{'hamstrings_r' 'bifemsh_r'},0.3}
```

<details>
<summary>Click to reveal the correct strength scaling factors</summary>

```matlab
S.settings.muscle_strength = {...       
	 {'glut_max_r'},0.3,...              	% R_hip_ext   
	 {'glut_max_l'},0.3,...               	% L_hip_ext 
	 {'iliopsoas_r'},0.7,...            	% R_hip_flex    
	 {'iliopsoas_l'},0.7,...             	% L_hip_flex  
	 {'hamstrings_r' 'bifemsh_r'},0.3,...  	% R_knee_flex
	 {'hamstrings_l' 'bifemsh_l'},0.3,...  	% L_knee_flex
	 {'rect_fem_r' 'vasti_r'},0.5,...      	% R_knee_ext
	 {'rect_fem_l' 'vasti_l'},0.7,...      	% L_knee_ext
	 {'gastroc_r' 'soleus_r'},0.1,...     	% R_ankle_pf  
	 {'gastroc_l' 'soleus_l'},0.1,...     	% L_ankle_pf
	 {'tib_ant_r'},0.1,...               	% R_ankle_df  
	 {'tib_ant_l'},0.1};                 	% L_ankle_df
```

</details>

## I.2 Personalizing passive range of motion (pROM)

**Background:**
During the standardized clinical examination, goniometry is used to measure the passive range of motion (pROM). The pROM represents the maximum amplitude of the joint motion and is therefore an indication for muscle length. Therefore, when the pROM is smaller than normative values, there is a clinical indication for a contracture. Contractures are modeled by reducing optimal fiber length. When optimal fiber length is reduced, muscle fibers will be stretched more at the same muscle-tendon length, resulting in higher passive forces.

The model is positioned according to the clinical pROM assessment, after which optimal fiber length is adjusted until the simulated passive joint torque matches the clinically applied resistance. The optimal fiber length will then be adjusted so that the modeled net joint torque reaches 15 Nm at the end of the range of motion, matching the clinician's resistance.

**Requirements:** Matlab, OpenSim, CasADi.
**Data:** pROM scores in the [`CE_CP_ESMAC_T0_T1`](ClinicalExam/CE_CP_ESMAC_T0_T1.xlsx) file, provided in the folder [ClinicalExam](ClinicalExam). `T0` refers to pre intervention and `T1` to post intervention.
**Additional information:** The protocol of the clinical exam, and normative values, are provided in [Documentation](../Documentation)
**Code:** [main_scale_lMo.m](Code/Scale_MT_params/main_scale_lMo.m) provided in the folder [Code](Code).

> 💡 Optional: Now that you have updated the muscle strength (`S.settings.muscle_strength`), you can already start a simulation with these settings (see III. Running PredSim with personalized settings). Since a simulation can take several minutes to run, you can let it run in the background while you continue with I.2 Personalizing passive range of motion (pROM). Remember to re-run the simulation later once you have also added the pROM settings.

### Step 3. Scaling muscle fiber length of the hamstrings

In this step, you will scale the optimal muscle fiber length of the hamstrings. Scaling the optimal muscle fiber length modifies the muscle force–length relationship. As shown in the "Scaling passive muscle stiffness" panel of the figure above, reducing optimal fiber length increases passive forces at the same muscle-tendon length, representing a contracted muscle.

**To do:**

1. Open [`CE_CP_ESMAC_T0_T1.xlsx`](ClinicalExam/CE_CP_ESMAC_T0_T1.xlsx) in **Excel** for the best viewing experience:
    * Navigate to the `ClinicalExam` folder on your PC, **or**
    * In MATLAB's **Files** panel, right-click the file and select **Open Outside MATLAB**

> **⚠️ Note:** `T0` refers to the pre-intervention assessment and `T1` refers to the post-intervention assessment.

2. Compare the passive range of motion scores with the normative values below.

| Clinical exam measure | Normative value |
| ---------------------- | ---------------: |
| `pROM_Poplbi`          |      −15° to 0° |
| `pROM_Ankledf0`        |      10° to 20° |
| `pROM_Ankledf90`       |      20° to 30° |

<details>
<summary>Click to reveal which muscles need scaling</summary>
	
The scores indicate no contracture of the soleus or gastrocs. Therefore, their optimal fiber length scaling factors remain **1**. However, both the left and right popliteal angles deviate from the normative range, indicating a hamstring contracture on both sides.

</details>

3. Add the following `S.subject.scale_MT_params` setting to your `update_settings_pre` file.
4. Keep the scaling factors at **1** for the soleus, gastrocs, and iliopsoas for now.
5. The hamstring scaling factors will be determined using `main_scale_lMo.m` below (in folder `Code/`).

```matlab
S.subject.scale_MT_params = merge_PredSim_settings(...
							 S.subject.scale_MT_params, ...
							 {{'hamstrings_r'},'lMo',1,...  % pROM_Poplbi_R %% to edit
                             {'hamstrings_l'},'lMo',1,...   % pROM_Poplbi_L %% to edit
                             {'iliopsoas_r'},'lMo',1,...    % explained in Step 4
                             {'iliopsoas_l'},'lMo',1,...    % explained in Step 4
                             {'gastroc_r'},'lMo',1,...      % pROM_Ankledf0_R
                             {'gastroc_l'},'lMo',1,...      % pROM_Ankledf0_L
                             {'soleus_r'},'lMo',1,...       % pROM_Ankledf90_R
                             {'soleus_l'},'lMo',1});         % pROM_Ankledf90_L
```

### Calculate the hamstring scaling factors

6. Open [`main_scale_lMo.m`](Code/Scale_MT_params/main_scale_lMo.m) and use the script to calculate the scaling factors for the hamstrings.

7. You only need to edit the lines between the following markers:

```matlab
% ------ start edit -----
% ----- end edit -----
```

There are three sections to edit:

**1. Lines 27–28:** Specify the paths to PredSim and CasADi.

```matlab
PredSim_path = 'C:\GBW_MyPrograms\PredSim'; % path to PredSim
casadi_path = 'C:\GBW_MyPrograms\casadi_3_5_5'; % path to CasADi
```

**2. Lines 40, 42 and 47:** Specify the muscle, side, and corresponding clinical exam angle.

```matlab
muscle_toScale = 'gastroc'; % Options: 'soleus', 'gastroc', 'hamstrings', 'iliopsoas'

side = 'l'; % side evaluated in clinical exam

% Step 3. scaling muscle fiber length of the hamstrings
if ismember(muscle_toScale, {'soleus','gastroc','hamstrings'})

    CE_angle = 20;

end
```

**3. Line 151:** Define the range of scaling factors to be explored. Here you have to experiment with different ranges, see the comments in the script for further instructions.

```matlab
%% -------    start edit  -------

% Define scaling factor range
% (sf_lMo = flip([start range : step size : end range]));

sf_lMo = flip([0.7:0.1:1]);

%% -------    stop edit   -------
```

**Bug fixing:** if you get an error saying `'update_settings' is not found in the current folder or on the MATLAB path`, run the script called `set_up_paths.m`. See [explanation](https://github.com/KULeuvenNeuromechanics/PredSim-workshop-ESMAC-2026#getting-started-with-one-of-the-cases) for more details.

8. Click the green ▶️ **Run** button to run the code.

   You'll be prompted to enter scaling factors for the soleus and gastrocnemius muscles. These could influence the scaling of proximal muscles. Since there was no indication of a contracture, these remain at **1**.

9. Select the scaling factor at which the CE angle intersects the **−15 Nm torque** applied by the experimenter.

	**Example:**
	A scaling factor of 60% is entered as `0.6` in the code.

	<img alt="example_hamstrings_scaling" src="https://github.com/user-attachments/assets/72040245-ecc4-4f6a-bf4d-b6560126a415" width="600" />

> **⚠️ Note:** A pop-up will appear to remind you that contractures in distal muscles can also affect joint posture during the clinical exam and, consequently, the measured popliteal angle. Therefore, the `CE_angle` should represent the posture resulting from the (possibly scaled) muscle-tendon lengths of all relevant muscles in the model.

> **⚠️ Note:** Run the file separately for the **right and left hamstrings**.

* Add the computed scaling factors to `S.subject.scale_MT_params`.

<details>
<summary>Click to reveal the correct scaling factors</summary>

```matlab
S.subject.scale_MT_params = merge_PredSim_settings(...
							 S.subject.scale_MT_params, ...
							 {{'hamstrings_r'},'lMo',0.88,...  % pROM_Poplbi_R
                             {'hamstrings_l'},'lMo',0.91,...   % pROM_Poplbi_L
                             {'iliopsoas_r'},'lMo',1,...       % explained in Step 4
                             {'iliopsoas_l'},'lMo',1,...       % explained in Step 4
                             {'gastroc_r'},'lMo',1,...         % pROM_Ankledf0_R
                             {'gastroc_l'},'lMo',1,...         % pROM_Ankledf0_L
                             {'soleus_r'},'lMo',1,...          % pROM_Ankledf90_R
                             {'soleus_l'},'lMo',1});           % pROM_Ankledf90_L
```

</details>


### Step 4. Scaling muscle fiber length of iliopsoas

**Summary:**
Iliopsoas contractures cannot be directly estimated from the popliteal angle, as hip position affects hamstring length. We therefore first estimate how much the hip position differs between the unilateral and bilateral tests, based on how the hamstrings act around the knee and hip. We then use this hip angle difference to estimate the iliopsoas contracture.

**Background:**

The popliteal angle is assessed twice: unilaterally and bilaterally.

- **Unilateral test:** the patient lies supine, the evaluated limb is flexed at the hip with the knee flexed, while the contralateral limb remains extended on the table. The knee of the evaluated limb is then moved into maximum extension, and the deficit until full extension is noted (as a negative angle). If the contralateral hip flexors (iliopsoas) are tight, the extended contralateral leg pulls the pelvis into anterior tilt, which effectively increases hip flexion of the tested limb. Because the hamstrings are biarticular, this additional hip flexion pre-lengthens them, causing the measured knee extension deficit to overestimate true hamstring tightness.
- **Bilateral test:** the same test is repeated with the contralateral limb held in flexion, which flattens the lumbar lordosis and keeps the pelvis in a neutral position. The bilateral popliteal angle therefore represents the *real* hamstring length, undistorted by pelvic tilt.

The difference between the unilateral and bilateral popliteal angles is called the **shift**, and indicates the contribution of a hip flexor (iliopsoas) contracture.

<img width="4287" height="1675" alt="Popliteal angle" src="https://github.com/user-attachments/assets/0e0eddc4-4619-4c63-93bf-7fd08452ff0c" />

**Normative value:** no shift

The increase in hip flexion angle is determined from the difference between the bilateral and unilateral popliteal angles and the ratio of the average moment arms of the bi-articular hamstrings around the knee and hip:

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

where *n* is the number of bi-articular hamstrings, and $ma_{\text{hip},i}$ and $ma_{\text{knee},i}$ are the moment arms of muscle *i* around the hip and knee at the bilateral popliteal angle.

The contracture of the contralateral iliopsoas is determined by finding the scaling factor that results in passive torque when the contralateral hip is extended beyond $\Delta \theta_{\text{hip}}$.

**To do:**

1. (If not already open) Open [`CE_CP_ESMAC_T0_T1.xlsx`](ClinicalExam/CE_CP_ESMAC_T0_T1.xlsx) in **Excel** for the best viewing experience:
    * Navigate to the `ClinicalExam` folder on your PC, **or**
    * In MATLAB's **Files** panel, right-click the file and select **Open Outside MATLAB**

> **⚠️ Note:** `T0` refers to the pre-intervention assessment and `T1` refers to the post-intervention assessment.

2. Compare the unilateral and bilateral popliteal angles to check for a difference between them (= shift).

<details>
<summary>Click to reveal the answer</summary>

| Side evaluated | Shift present? |
| --------------- | --------------: |
| Right            | Yes             |
| Left             | No              |

A shift is only present for the **right popliteal angle**, indicating a contracture in the **contralateral (left) iliopsoas**. Since there is no shift on the left side, the **right iliopsoas** scaling factor remains **1**.

</details>

3. (If not already open) Open [`main_scale_lMo.m`](Code/Scale_MT_params/main_scale_lMo.m) to calculate the scaling factors for the iliopsoas.

4. Edit **only** the lines between:

```matlab
% ------ start edit -----
% ----- end edit -----
```

There are three sections to edit:

**1. Lines 27–28:** Specify the paths to PredSim and CasADi.

```matlab
PredSim_path = 'C:\GBW_MyPrograms\PredSim'; % path to PredSim
casadi_path = 'C:\GBW_MyPrograms\casadi_3_5_5'; % path to CasADi
```

**2. Lines 40, 42 and 52–53:** Specify the muscle, side, and the unilateral and bilateral clinical exam angles.

```matlab
muscle_toScale = 'iliopsoas'; % Options: 'soleus', 'gastroc', 'hamstrings', 'iliopsoas'

side = 'r'; % side evaluated in clinical exam
```
```matlab
% Step 4. Scaling optimal muscle fiber length of iliopsoas
elseif strcmp(muscle_toScale, 'iliopsoas')

    CE_angle_bi  = -70;
    CE_angle_uni = -80;

end
```

> **⚠️ Note:** For `iliopsoas`, fill in **both** `CE_angle_uni` and `CE_angle_bi` — the unilateral and bilateral popliteal angles from the Clinical Exam (see Background above). Unlike `soleus`, `gastroc`, and `hamstrings`, a single `CE_angle` is not used here.

**3. Line 151:** Define the range of scaling factors to be explored. Here you have to experiment with different ranges, see the comments in the script for further instructions.

```matlab
%% -------    start edit  -------

% Define scaling factor range
% (sf_lMo = flip([start range : step size : end range]));

sf_lMo = flip([0.7:0.1:1]);

%% -------    stop edit   -------
```

5. Click the green ▶️ **Run** button to run the code.

   You'll be prompted to enter scaling factors for the soleus, gastrocnemius, and hamstring muscles. These could influence the scaling of the iliopsoas. Use the scaling factors determined in the previous steps.

* Use the **unilateral and bilateral popliteal angles of the right leg** to calculate the scaling factor for the **left iliopsoas**.
* Add the computed scaling factors to `S.subject.scale_MT_params`.

> **⚠️ Note:** A difference between the unilateral and bilateral popliteal angles indicates a contracture in the **contralateral iliopsoas**. For example, use the unilateral and bilateral popliteal angles of the **right leg** to calculate the scaling factor of the **left iliopsoas**.

---

### Step 5. Adjusting coordinate limit torques

**Background:**

Observed knee extension and plantar flexion deficits are modeled by shifting the coordinate limit torques that represent the stiffness of the non-muscle soft tissues around the joint.

**To do:**

* Add the following `S.subject.set_limit_torque_coefficients_selected_dofs` setting to your `update_settings_pre` file.
* This setting defines the coordinate limit torques for all degrees of freedom (DOFs) in the model.
* **Only change the last two values** in each line. These values represent the rotational limits.
* For the **knee**, adjust the extension limit based on the observed knee extension deficit in the Clinical Exam.
* Leave the other values unchanged.

```matlab
S.subject.set_limit_torque_coefficients_selected_dofs =...
        {{'lumbar_extension'},[-0.7644,11.2154,1.2788,-7.2704],[-0.3716,0.1068],...
         {'hip_flexion_r','hip_flexion_l'},[-2.44,5.05,1.51,-21.88],[-0.6981,1.81],...
         {'knee_angle_r','knee_angle_l'},[-6.09,33.94,11.03,-11.33],[-2.4,0.13],... %% to edit
         {'ankle_angle_r','ankle_angle_l'},[-2.03,38.11,0.18,-12.12],[-0.4363,0.6109]};
```

The plantar flexion limits have already been adjusted. The onset of the coordinate limit torques is set to **25° plantar flexion** when the score is `discrete`, or **0°** when the score is `severe`.

For the knee, the relevant line is:

```matlab
{'knee_angle_r','knee_angle_l'},[... ... ... ...],[flexion, extension]
```

* Shift the extension limit so that it represents the observed knee extension deficit from the Clinical Exam.

> **For example,** if the clinical exam shows a **20° knee extension deficit**, shift the extension limit from 7.44° (0.13 rad) to approximately **−20° (−0.35 rad)**, depending on the coordinate convention used.

> **⚠️ Note:** All joint limit values below are reported in **radians**, not degrees.

**Conversion between degrees and radians:**

`angle (rad) = angle (°) × π / 180`

`angle (°) = angle (rad) × 180 / π`

**Example:**

`30° × π / 180 = 0.5236 rad`

`0.5236 rad × 180 / π = 30°`

### 🎉 Congratulations, you have personalized your model!

Now that you have personalized your model, it is time to run a simulation with your personalized settings.

Scroll down to III. Running PredSim with personalized settings to start the simulation.

The optimization will take approximately 5–10 minutes. While it is running, take a well-deserved break from the coding and reading ☕. Or, if you are feeling productive, you can already continue reading through the next steps!

# II. Simulate the effect of a surgical intervention

**Background:**
This patient underwent a bilateral distal femur extension osteotomy, a surgical procedure performed on both thighs to correct a knee extension deficit. The procedure reduces the knee flexion deformity by rotating the distal femoral segment into a more extended alignment, thereby improving the patient's ability to achieve knee extension during stance. During this procedure, the surgeon removes a wedge-shaped piece of bone from the lower (distal) part of the femur (thigh bone). The wedge is taken from the anterior part of the distal femur. When the remaining bone ends are brought together and stabilized, the distal femoral segment is rotated into a more extended position. This changes the alignment of the femur relative to the knee, allowing the knee to achieve greater extension.

In the model, this surgical correction shifts the knee geometry; this means that passive extension torques will begin to act at a more extended (= less negative) knee angle.

**Requirements:** Matlab.
**Data:** pROM scores in the [`CE_CP_ESMAC_T0_T1`](ClinicalExam/CE_CP_ESMAC_T0_T1.xlsx) file, provided in the folder [ClinicalExam](ClinicalExam). `T0` refers to pre intervention and `T1` to post intervention.
**Additional information:** The protocol of the clinical exam, and normative values, are provided in [Documentation](../Documentation)

### Step 1. Copy the pre-intervention settings

Open [`update_settings_post.m`](Code/update_settings_post.m) in your **Code** folder.

The post-intervention model starts from the personalized pre-intervention model. Therefore:

* Open your `update_settings_pre.m` file.
* Copy all the settings you previously defined.
* Paste them into `update_settings_post.m`.
* Keep these settings unchanged; only the surgical modifications will be updated in the following steps.

### Step 2. Adapt the knee extension deficit

**To do:**

* (If not already open) Open [`CE_CP_ESMAC_T0_T1.xlsx`](ClinicalExam/CE_CP_ESMAC_T0_T1.xlsx) in **Excel** for the best viewing experience:
    * Navigate to the `ClinicalExam` folder on your PC, **or**
    * In MATLAB's **Files** panel, right-click the file and select **Open Outside MATLAB**

> **⚠️ Note:** `T0` refers to the pre-intervention assessment and `T1` refers to the post-intervention assessment.

* Evaluate the **knee extension deficit** in the post-intervention Clinical Exam.
* Compare it with the knee extension deficit used in your pre-intervention model.
* Update the corresponding knee extension limit in `update_settings_post.m` to reflect the **post-intervention** clinical exam.

# III. Running PredSim with personalized settings

### Step 1. Open `main.m`

Open [`main.m`](https://github.com/KULeuvenNeuromechanics/PredSim/blob/master/main.m) in your **PredSim** folder.

### Step 2. Adapt the code for your simulation

Update the following lines in `main.m`:

* **Line 20:** Initialize the `gait1018_esmac` model.

```matlab
S = initializeSettings('gait1018_esmac');
```

* **Line 21:** Add the settings file corresponding to the simulation you want to run.

For the **pre-intervention model**:

```matlab
S = update_settings_pre(S);
```

For the **post-intervention model**:

```matlab
S = update_settings_post(S);
```

* **Line 25:** Set the subject name.

```matlab
S.subject.name = 'gait1018_esmac';
```

### Step 3. Run the simulation

Click the green ▶️ **Run** button at the top of the MATLAB window to start the simulation. 🚀

Now sit back and let PredSim do the work! ☕

## Visualizing and plotting the results

Once your simulations are done, the results are stored in `PredSimResults\gait1018_esmac` as `gait1018_esmac_vx`. Every time you run a simulation, the results are saved with an incremental version number: v1, v2, v3, v4, … The most recently run simulation always has the highest version number.

### To visualize the motion in OpenSim:

1. Open the model (File > Open Model...) `PredSim/gait1018_esmac/gait1018_esmac.osim` in OpenSim.
2. Load the .mot file (File > Load Motion...) `PredSimResults/gait1018_esmac/gait1018_esmac_vx.mot` in OpenSim.

### To visualize the kinematics of your simulations and compare it to the experimental data of the patient:

1. Open the script [run_this_file_to_plot_figures_CP_ESMAC.m](Code/PlotFigures/run_this_file_to_plot_figures_CP_ESMAC.m) in the `Code/PlotFigures` folder.
2. Edit the section marked `% ------- start edit -------` to `% ------- stop edit -------` (lines 14–29) to point to your own simulation results and configure which comparisons you want to see.

#### What to edit

**`results_folder`**
Set this to the folder on your machine where PredSim saves its output.

**`results_path`**
A struct that links a label (used in the legend) to the `.mat` file of a specific simulation run. Only the fields you include here will be plotted. You don't need to fill in all three.

> ⚠️ **Note:** the version numbers (`_v2`, `_v3`, `_v4`, …) will be different for you, depending on how many simulations you've run and in what order. Check the `PredSimResults\gait1018_esmac` folder to confirm which version corresponds to which settings (pre-intervention, post-intervention, reference), and update the paths accordingly.

> 💡 The field names you choose (`reference`, `pre_surgery`, `post_surgery`) become the legend labels in your figures (spaces are inserted automatically instead of underscores), so keep them short and descriptive.

**`plot_experimental_kinematics`** *(true/false)*
Set to `true` to overlay the patient's own experimental IK envelope (from motion capture) on the kinematic plots. Set to `false` to skip this.

**`include_TD_reference`** *(true/false)*
Set to `true` to overlay a typically-developing (TD) reference envelope for comparison. Set to `false` to skip this.

**`apply_clinical_convention`** *(true/false)*
Set to `true` to convert joint angle signs/directions to the clinical convention (as typically reported in gait analysis reports) instead of the raw OpenSim convention. This affects both the simulation curves and the experimental/TD reference curves, so keep it consistent across your figures.

**`legend_names`**
By default, this is generated automatically from the field names in `results_path`, with underscores replaced by spaces.

**`figure_folder`** and **`figure_savename`**
Control where figures are saved and the common prefix used in the filenames. By default, `figure_folder` points to the `IK` results folder and doesn't need to be changed unless you want figures saved elsewhere.

**⚠️ Be aware** that the simulations only include the main musculoskeletal deficits identified in the clinical assessment. Other factors, such as deficits in motor control, are not explicitly included in the model. These factors may therefore contribute to differences between the simulated and experimental gait. The aim is not to reproduce every detail of the experimental gait, but to evaluate whether the personalized model captures the main clinically relevant features and predicts the key changes following the intervention.

## Switching to another case

Once you have completed this case, you may want to switch to another. In that case, you have to start from a new `update_settings` file.

Since you worked with `update_settings_pre` and `update_settings_post` in this case (rather than editing `update_settings` directly), you can start from a new `update_settings` file and the case-specific settings won't carry over.

Before starting a new case, `update_settings` should look like this:

```matlab
function[S] = update_settings(S)

% Full gait cycle simulations instead of Half gait cycle (default) simulations
S.misc.gaitmotion_type = 'FullGaitCycle';

end
```
