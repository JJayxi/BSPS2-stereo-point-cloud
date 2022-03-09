#Current Papers

This file contains a list and a description, as well as some comments of papers about stereoscopic matching and correspondance, or stereoscopic vision in genenral.

##Sum of Squared Difference / Sum of Absolute Difference
This technique is the base of most disparity map creation algorithm. However, it was not developed for this use only. It allows the comparaison of data, and computes the dispersion between different data points. In this scenario, we compute which pixel is more or less similar (according to it's neighbour), to find which pixels matches to what other pixel.

##PMF: A Stereo Correspondance Algorithm Using a Disparity Gradient Limit
  
 `1. Pollard SB, Mayhew JEW, Frisby JP. PMF: A Stereo Correspondence Algorithm Using a Disparity Gradient Limit. Perception. 1985;14(4):449-470. doi:10.1068/p140449`
*Link*: https://journals.sagepub.com/doi/abs/10.1068/p140449

This paper presents a method which limits the maximum disparity. An simple algorithm explaining how to implement this in a described. 
*Comment*: This is interesting, by reducing the maximum disparity, we limit the range of pixels that have to be checked. A pixel won't map to the other side of the image. 

##A stereo matching algorithm with an adaptive window: theory and experiment
`T. Kanade and M. Okutomi, "A stereo matching algorithm with an adaptive window: theory and experiment," in IEEE Transactions on Pattern Analysis and Machine Intelligence, vol. 16, no. 9, pp. 920-932, Sept. 1994, doi: 10.1109/34.310690.`
*Link*:https://ieeexplore.ieee.org/abstract/document/310690/metrics#metrics

Paper describing an algorithm which changes the windows size depending on the variation of the pixels in the window. In a case where the variant on the pixels is very small, a larger window will be taken to increase accuracy. The algorithm in the paper doesn't just resize the window in both directions but it changes it rectangularly.

A similar paper, (*link*: https://ieeexplore.ieee.org/abstract/document/1114859) explains a algorithm implement the same type of idea in an optimized manner. 

##Census Transform
The census transform creates for every pixel an array containing the information whether the neighbour pixels are brighter or darker. This signature is then used to check if pixels are similar or not. Depending on the number of differences there are in this array, the pixels are more similar and thus more likely to match.  (*link*: https://en.wikipedia.org/wiki/Census_transform)


This method is generally very noise sensitive, and methods such as comparing the pixel color to not the center of the window but other pixels has been proposed, to be more robust against gaussian noise (*link*: https://www.spiedigitallibrary.org/journals/optical-engineering/volume-55/issue-06/063107/Improved-census-transform-for-noise-robust-stereo-matching/10.1117/1.OE.55.6.063107.full?SSO=1 ).

##Waterloo course about stereo matching

https://cs.uwaterloo.ca/~yboykov/Courses/cs484/Lectures/lec08_stereo_u.pdf?r=0.08148897485807538


##Non integer disparity (self)
By using non-natural number to weigh the value of the pixels for the sum of squared difference, we can find a best position that may not be exactly on a pixel. We may find a best pixel by matching on specific pixels, but the ground truth might be shifted slightly and by adjusting it with non-integer steps we might improve the precision.

##Applying constraints 
`Wided Miled, Jean-Christophe Pesquet, Michel Parent. Dense Disparity Estimation From Stereo Im-
ages. 3rd International Symposium on Image/Video Communications, Sep 2006, Hammamet, Tunisia.
￿inria-00069063v2￿`

*Link*: https://hal.inria.fr/inria-00069063v2/document

This paper sets a number of constraints which the disparity map has to follow, which augments the quality of the disparity and augments the speed of the algorithm. 