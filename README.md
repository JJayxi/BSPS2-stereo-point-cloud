# ReadMe
Stereo-Point-Cloud is a project made part of the Bachelor Semester Project course in University of Luxembourg. The project was made in processing, an extension to java which allows easy manipulation of images and drawing objects on a screen in a relatively easy manner. The goal of this project was to understand how a 3d scene can be derived from stereoscopic images.

The stereoscopic images pass through 3 steps to generate the point cloud. The disparity generation, the post-processing and the 3d reprojection.

## Disparity generation
The disparity is the difference in position of a pixel that represents the same thing from one image to the other. We introduce a cost function which compares two pixels and its local neighbours in a square around to compute how different the pixels are, and try to minimise this function across all pixels.

## Post-processing
To disparity map generated during the previous step contains a very large amount of noise, which is partially removed in this step. This step assumes 2 things, that neighbouring pixels must have at least a few pixels with similar dispartiy, and that nothing can "float" in the air.

These two properties are used to do a high-frequency denoising and a low-frequency denoising.

As of now, the disparity map was stored as integer values, which when reproject in 3d, is very visible as each point is part of a layer. For this, we perform a smoothing step, which smoothes the disparties of the pixels with its similar neighbouring pixels, creating a smoother image without smoothing out the crisp edges.

## Reprojection
With some linear algebra and trigonometry, the position in space from these pixels can be found using the disparity and the position on the image. A wavefront format object is generated containing the 3d representation of the stereoscopic image pair.
