# frameTools

frameTools is a set of AviSynth functions for manipulating frames and clips.

Most notably, it supports scene filtering.

The development emphasis is on zero-configuration "just works" software.

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
```

## Limitations and Dependencies:

* sceneFilter(), redoSceneFilter(), and fclip() do not support modifying the first or last 2 frames of a clip.
* Make sure the number of total frames in the master clip stays the same when near the edges.
* (optional) If using the mff(), merge fix frame, function, it has [this dependency](http://avisynth.org.ru/badframes/badframes.html).
* If downloading from github manually, instead of using an offical_release.zip then remember to change the line ending back from broken-because-of-github to Dos\Windows using [Notepad++](//notepad-plus-plus.org/download).

Click [here](https://github.com/gdiaz384/frameTools/releases) or on "releases" at the top to download the latest version.

# One day

* I will figure out how to crop a section from one video and automatically insert it into another video with a simple UI.
* When that day comes, I will add that functionality. One day...

## License:
Pick your License: any version of GPL/BSD/MIT or Apache

If I get any questions on licensing, I'm changing this to "beerware" and will refuse to elaborate further.
