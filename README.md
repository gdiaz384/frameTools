# frameTools

frameTools is a set of AviSynth functions for manipulating frames and clips. frameTools supports:

- Quickly fixing bad frames via duplication.
- Splicing one clip into another. Uses:
   - Merging stabalized and unstabalized clips.
   - Replacing OP/EDs with NCOP/NCEDs.
   - Replacing sceneA_filteredDifferently.lossless.mkv into current clip.
- (Inefficent) scene filtering. Tip: Use [ReplaceFramesSimple](http://avisynth.nl/index.php?title=RemapFrames) instead.
- Splicing parts of frames with parts of another clip.
- Freezing parts of a frame for a range of frames.

## Download:

Click [here](https://github.com/gdiaz384/frameTools/releases) or on "releases" at the top to download the latest version.

## Documentation:

```
fix frames by replacement - replace frame start for number of frames "length"
Syntax: ff(clip clp, int start, int "length")
Usage: ff(234,1)


#reverse fix frame - replaces frame from start backwards
Syntax: rff(clip clp, int start, int "length")
Usage: rff(234,2)


#merge fix frame - creates a hybrid frame from the adjacent frames
Dependency: http://avisynth.org.ru/badframes/badframes.html
Syntax: mff(clip clp, int frame)
Usage: mff(234)


#fix scene change - replaces frame specified, and the one before with length specified by lengthPrior, lengthPost
Dependency: ff() and rff()
Syntax: fs(clip clp, int start, int "lengthPrior",int "lengthPost")
Usage1: fs(234,1,1)
Usage2: fs(456,1,2)


#replace the frames of the current clip with the frames of another clip starting from frame start/end
Syntax: function replaceClipFromStart(clip clip1, clip clip2, int start)  #used to specify the first frame to replace
Syntax: function replaceClipFromEnd(clip clip1, clip clip2, int end)    #used to specify the last frame to replace
Usage:
FFVideoSource("my show.mkv")
ncop="my show ncop.mkv"
nced="my show nced.mkv"
ncopClip=FFVideoSource(ncop).trim(0,2263).Spline64Resize(1280,720)
ncedClip=FFVideoSource(nced).trim(0,2250).Spline64Resize(1280,720)
replaceClipFromStart(ncopClip,20)
replaceClipFromEnd(ncopClip,2205)
replaceClipFromStart(ncedClip,33359)
replaceClipFromEnd(ncedClip,35530)


#fixes clip - by replacing its frames with the frames from another clip 
Note: frame numbers/count must match from both clips - Meant for merging raw and stabalized video clips together.
- Can also be used to "undo" the filtering for a scene.
Syntax: function fclip(clip clip1, clip clip2, int start, int end)
Usage:
original=FFVideoSource(myvideo.mkv)
AVISource(myvideo_stabalized.avi)
fclip(original,324,538)
Usage2:
FFVideoSource("myvideo.mkv")
original=last
Tweak(sat=1.2)
fclip(original,50,550)


#sceneFilter - applies a set of filters to parts of a clip, from frameStart to frameEnd, defined by a function named "filterGroup" 
Syntax: function sceneFilter(clip clip1, int frameStart, int frameEnd, string filterGroup)
#Usage:
sceneFilter(4,2205,"op")
function op(clip clip2){last=clip2
LSFMod()
}
sceneFilter(2205,2505,"scene1")
function scene1(clip clip2){last=clip2
TemporalDegrain()
LSFMod()
}
last

#meant to "redo" the filtering for a scene - useful for fixing specific scenes that need to be filtered differently (like ops/eds)
Dependencies: fclip, sceneFilter
Syntax: redoSceneFilter(clip clip1, clip original, int frameStart, int frameEnd, string filterGroup)
Usage: 
FFVideoSource("myvideo.mkv")
original=last
Tweak(sat=1.2)
redoSceneFilter(original,32239,34434,"ed")
function ed(clip clip2){last=clip2
Tweak(sat=1.0)
}
last

#The idea is to define a rectangle area to replace. Can work similar to FreezeFrame() but for parts of a frame or be used to embed one clip inside of another.
Dependencies: Masktools2
function ReplaceBox(clip clp, int "offsetX", int "offsetY", int "width", int "height", int "startFrame", int "endFrame", int "sourceFrame", clip "clip2", bool "show")
Usage:
ReplaceBox(0, 0, 200, 300, show=true)
#Translation: Starting at coordinate (0,0) (top left), create a 200x300 pixel box.

ReplaceBox(250, 400, 200, 300, show=true)
#Translation: Start at coordinate (250,400) and use a 200x300 box. This means the bottom right corner of the box will extend to (450,700).

ReplaceBox(0, 0, 400, 500, startFrame=50, endFrame=250, sourceFrame=49)
#Translation: Start from the top left and use a 400x500 box. The contents displayed for frames 50-250 will be from frame 49. 

ReplaceBox(250, 400, 200, 300, 100, 120, 50)
#Translation: Start at coordinate (250,400) and use a 200x300 box. The box only affects frames 100-120, using the contents from frame 50.

ReplaceBox(250, 400, 200, 300, clip2=last.Greyscale())
#Translation: Start at coordinate (250,400) and use a 200x300 box. The box contents are from a different clip with identical properties.

ReplaceBox(250, 400, 200, 300, 100, 120, 50, clip2=last.Greyscale())
#Translation: Start at coordinate (250,400) and use a 200x300 box. The box freezes frames 100-120, using the contents from frame 50 from clip2. The normal frames from clip2 are for replacements outside of [100-120]. Note: Specifying clip2 will always replace the contents for the entire clip regardless of the specified range of frames to freeze.
```

Example for ReplaceBox:

![ReplaceBoxExample](pics/ReplaceBoxExampleSettings.jpg)

## Limitations and Dependencies:

* sceneFilter(), redoSceneFilter(), and fclip() do not support modifying the first or last 2 frames of a clip.
    * Make sure the number of total frames in the master clip stays the same when near the edges.
* replaceBox() requires [MaskTools2](http://avisynth.nl/index.php/MaskTools2).
* (optional) If using the mff(), merge fix frame, function, it has [this dependency](http://avisynth.org.ru/badframes/badframes.html).
* If downloading from github manually, instead of using an offical_release.zip then remember to change the line ending back from broken-because-of-github to Dos\Windows using [Notepad++](//notepad-plus-plus.org/download).

## License:
Pick your License: any version of GPL/BSD/MIT or Apache.

If I get any questions on licensing, I'm changing this to "beerware" and will refuse to elaborate further.
