#Current Papers

This file contains a list and a description, as well as some comments of papers about stereoscopic matching and correspondance, or stereoscopic vision in genenral.

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




