# 1D RangeFinder - Camera calibration

Extrinsic calibration for single point rangefinder and monocular vision systems.

<img src="readme_img/alti_cam_fade.png" height="150"/> <img src="readme_img/alti_extr.png" height="150"/> 


## Usage

Just run the ```main.m``` script in the ```matlab/``` folder. 
There are multiple ways to try the code out:
* use the test images and range scans provided in the folders ```images/``` and ```scans/``` (camera parameters are cached in a .mat file, which can be loaded by setting the variable in line 16)
* uncomment lines 34-40 in ```main.m``` to generate a randomized synthetic dataset

## References

If you find this code useful for your projects/research, please cite the corresponding paper:
* Giubilato, R. et al. "MiniVO: Minimalistic Range Enhanced Monocular System for Scale Correct Pose Estimation", IEEE Sensors Journal, 2020
* Giubilato, R. et al. "Scale Correct Monocular Visual Odometry Using a LiDAR Altimeter", IEEE/RSJ International Conference on Intelligent Robots and Systems, 2018

```
@ARTICLE{giubilato2020minivo, 
    author={R. {Giubilato} and S. {Chiodini} and M. {Pertile} and S. {Debei}}, 
    journal={IEEE Sensors Journal}, 
    title={MiniVO: Minimalistic Range Enhanced Monocular System for Scale Correct Pose Estimation}, 
    year={2020}, 
    doi={10.1109/JSEN.2020.2978334}, 
    ISSN={2379-9153},
}

@INPROCEEDINGS{giubilato2018scale, 
    author={R. {Giubilato} and S. {Chiodini} and M. {Pertile} and S. {Debei}}, 
    booktitle={2018 IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS)}, 
    title={Scale Correct Monocular Visual Odometry Using a LiDAR Altimeter}, 
    year={2018}, 
    pages={3694-3700}, 
    keywords={distance measurement;image sequences;mobile robots;optical radar;robot vision;SLAM (robots);stereo image processing;stereo visual SLAM;monocular vision;inherent scale ambiguity;LiDAR altimeter;scale correct monocular visual odometry;RGB-D methods;scale drift;keyframe basis;scale constraint;mapping algorithm;keyframe based tracking;Visual Odometry method;laser altimeter;range data;exploration vehicles;power requirements;computational load;metrological accuracy;RGB-D sensors;3D LiDARs;metric references;sensory sources;Cameras;Laser radar;Measurement;Three-dimensional displays;Visual odometry;Visualization;Sensors}, 
    doi={10.1109/IROS.2018.8594096}, 
    ISSN={2153-0858}, 
    month={Oct},
}
```
