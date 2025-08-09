# vvmc

code for SIGGRAPH 2025 paper "Vector-Valued Monte Carlo Integration Using Ratio Control Variates".

project page: [https://suikasibyl.github.io/vvmc](https://suikasibyl.github.io/vvmc)

![](https://suikasibyl.github.io/files/vvmc/teaser.webp "teaser")

***

## Preparation

1. **Install** [sibylengine](https://github.com/SuikaSibyl/sibylengine) following its setup instructions.
2. **Download** the [scenes](https://drive.google.com/drive/folders/1N4GwTGJ2auJz2Iluq4terVPHVEwXGg9A?usp=sharing) and place them in the `/scenes` folder.
3. **Run the examples**:

   - Open the `vvmc` folder in **VS Code**.
   - Activate the Python environment where **sibylengine** is installed.
   - Execute `main.py` in each example folder.

## Examples
- ```example-rglmat```: ratio control variates for BRDF sampling. A material ball with RGL measured BRDF under uniform environment lighting. The material can be switched in editor.
- ```example-lightbvh```: ratio control variates for many-light sampling and MIS. Direct illumination only. 3 test scenes can be switched in ```main.py```.
- *more examples later...* 

## Play with the editor
![](https://suikasibyl.github.io/files/vvmc/work-with-editor.webp "editor-hints")