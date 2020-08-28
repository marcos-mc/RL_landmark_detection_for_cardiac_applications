# Reinforcement Learning Landmark Detection Evaluation For CardiacApplications

The DQN code used is a version of the [RL-Medical](https://github.com/amiralansary/rl-medical/tree/master/examples/LandmarkDetection/SingleAgent) code 

## Installation

### Dependencies

As specified in their [repository](https://github.com/amiralansary/rl-medical) specified requires:

+ Python=3.6
+ [tensorflow-gpu=1.14.0](https://pypi.org/project/tensorflow-gpu/)
+ [tensorpack=0.9.5](https://github.com/tensorpack/tensorpack)
+ [opencv-python](https://pypi.org/project/opencv-python/)
+ [pillow](https://pypi.org/project/Pillow/)
+ [gym](https://pypi.org/project/gym/)
+ [SimpleITK](https://pypi.org/project/SimpleITK/)
+ google, protobuf and h5py probably also needed

## Preprocessing

+ [Aorta Application](https://github.com/marcos-mc/RL_landmark_detection_for_cardiac_applications/Preprocessing/Aorta)
+ [Left Atrial Appendage (LAA) Application](https://github.com/marcos-mc/RL_landmark_detection_for_cardiac_applications/Preprocessing/LAA)

## DQN code

The DQN code used is a version of the [RL-Medical project](https://github.com/amiralansary/rl-medical/tree/master/examples/LandmarkDetection/SingleAgent) .

### Original Arguments
```
usage: DQN.py [-h] [--gpu GPU] [--load LOAD] [--task {play,eval,train}]
              [--algo {DQN,Double,Dueling,DuelingDouble}]
              [--files FILES [FILES ...]] [--saveGif] [--saveVideo]
              [--logDir LOGDIR] [--name NAME]

optional arguments:
  -h, --help            show this help message and exit
  --gpu GPU             comma separated list of GPU(s) to use.
  --load LOAD           load model
  --task {play,eval,train}
                        task to perform. Must load a pretrained model if task
                        is "play" or "eval"
  --algo {DQN,Double,Dueling,DuelingDouble}
                        algorithm
  --files FILES [FILES ...]
                        Filepath to the text file that comtains list of
                        images. Each line of this file is a full path to an
                        image scan. For (task == train or eval) there should
                        be two input files ['images', 'landmarks']
  --saveGif             save gif image of the game
  --saveVideo           save video of the game
  --logDir LOGDIR       store logs in this directory during training
  --name NAME           name of current experiment for logs

```
### New Arguments
This version also has: 
```
optional arguments:
  
  --landmark            index of current landmark to be used
  --csv_name            name of the csv file to save the results
  --viz			with a value different than 0 show images
			of the agent actions while playing a game. 
			Only for play and eval options.

```
## Evaluation Results

+ [Aorta Application](https://github.com/marcos-mc/RL_landmark_detection_for_cardiac_applications/blob/master/Evaluation/AORTA/AORTA_Eval_model.ipynb)
+ [LAA Application](https://github.com/marcos-mc/RL_landmark_detection_for_cardiac_applications/blob/master/Evaluation/AORTA/LAA_Eval_model.ipynb)

