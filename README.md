# Publish or Perish: A Backward-Compatible Defense against Selfish Mining in Bitcoin
This is the evaluation code of the CT-RSA 2017 paper "Publish or Perish: A Backward-Compatible Defense against Selfish Mining in Bitcoin" by Ren Zhang and Bart Preneel. Note that this is not an implementation of the defense itself, but an MDP source code that computes the optimal selfish mining strategy and the maximum relative revenue of the selfish miner within the defense, under a given set of parameters: *alphaPower*, selfish miner's mining power share, and *superOverride* (denoted as *k* in the paper), the length difference between two chains before the attacker can override with a lighter chain. The later is a parameter in our defense which can be chosen by the protocol designer. This code is programmed by Ren Zhang.

Please check [my google scholar page](https://scholar.google.be/citations?user=JB1uRvQAAAAJ&hl=en) to download the paper for more details. Although we did not provide an implementation of the defense itself, **the defense is very simple and straight-forward to implement**. We don't claim to be the optimal selfish mining defense, however we believe this is the optimal selfish mining defense in Bitcoin to date that doesn't require a hard fork.

The program has two limitations:
1. It can only compute block races up to a certain length (14, maybe 15) and therefore a lower bound of the selfish miner's revenue. However for *alphaPower*<=0.47, the output can be considered an accurate estimation of the maximum relative revenue as longer block races happen extremely rare within our defense. One way to compare the results with other defenses is to enforce the same maximum block race length to other defenses.
2. The strategy does not cover the case in which the attacker publishes the blocks right before they expire to cause inconsistent views among honest miners. The authors believe that this is not possible for *alphaPower*\<0.5 and therefore not a threat to our defense. Such strategy will be analyzed in our future work.

The MDP state encoding and transition are quite complicated: many information regarding the structure of the blockchain needs to be encoded in the state to help the attacker make decisions. Therefore if you wish to fully understand this source code rather than using it as a blackbox to execute and compare the results, the coder strongly recommend you to read the paper ["the Optimal Selfish Mining Strategies"](http://www.cs.huji.ac.il/~yoni_sompo/pubs/15/SelfishMining.pdf) and understand [my implementation](https://github.com/nirenzang/Optimal-Selfish-Mining-Strategies-in-Bitcoin) of their algorithm before modifying this code. 

## Quick Start
If you only need the results:
1. Makesure you have matlab.
2. Download the [MDP toolbox for matlab](https://nl.mathworks.com/matlabcentral/fileexchange/25786-markov-decision-processes--mdp--toolbox), decompress it, put it in a directory such as '/users/yourname/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox', copy the path.
3. Download the code, open Matlab, change the working dir to the dir of the code.
4. Open Init.m, paste your MDP toolbox path in the first line 
```
addpath('/users/yourname/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');
```
5. Modify *maxB* (the maximum length of a block race), *alphaPower* and *superOverride* in Init.m. The recommended value of *maxB* is 13; 0\<*alphaPower*<=0.47; *superOverride* must be an integer, 1<=*superOverride*<=*maxB*.
6. Run Init.m.

## Implementation

### Structure
* `Init.m`
The portal of the program. The parameters are defined here.
* `st2stnum.m`
A state in the paper is denoted as a 6-tuple. However in MDP, a state needs to be encoded as a number. This function converts a state tuple into the relevant number. 
* `stnum2st.m` 
This function does the reverse conversion.
* `SolveStrategy.m`
The code that actually computes the optimal selfish mining strategies. The structure of the code follows the paper.
* `Checkstnum2st.m`
A test file, check whether `st2stnum.m` and `stnum2st.m` are bijection.

## Citation
Zhang R., Preneel B. (2017) Publish or Perish: A Backward-Compatible Defense Against Selfish Mining in Bitcoin. In: Handschuh H. (eds) Topics in Cryptology – CT-RSA 2017. CT-RSA 2017. Lecture Notes in Computer Science, vol 10159. Springer, Cham
```
@inproceedings{zhang2017publish,
  title={Publish or Perish: A Backward-Compatible Defense Against Selfish Mining in Bitcoin},
  author={Zhang, Ren and Preneel, Bart},
  booktitle={Cryptographers’ Track at the RSA Conference},
  pages={277--292},
  year={2017},
  organization={Springer}
}
```
Chadès, I., Chapron, G., Cros, M. J., Garcia, F., & Sabbadin, R. (2014). MDPtoolbox: a multi‐platform toolbox to solve stochastic dynamic programming problems. Ecography, 37(9), 916-920.
```
@article{chades2014mdptoolbox,
  title={MDPtoolbox: a multi-platform toolbox to solve stochastic dynamic programming problems},
  author={Chad{\`e}s, Iadine and Chapron, Guillaume and Cros, Marie-Jos{\'e}e and Garcia, Fr{\'e}d{\'e}rick and Sabbadin, R{\'e}gis},
  journal={Ecography},
  volume={37},
  number={9},
  pages={916--920},
  year={2014},
  publisher={Wiley Online Library}
}
```

## License
This code is licensed under GNU GPLv3.
