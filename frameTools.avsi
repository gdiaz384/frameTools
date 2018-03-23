""" #start documentation#

Notice: Some of the following filters do not support modifying the first or last 2 frames of a clip.  (redo)sceneFilter() and fclip()
Merging clips is possible only if both clips have audio, or if neither do. Load audio for both or wait until after merging to AudioDub(vid,aud).

#fix frames by replacement - replace frame start for number of frames "length"
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


#reads frames to fix from a file (unimplemented)
fileff(string myfile,string functionName) (?) 


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

""" #end documentation#
#start functions#


function ff(clip clp, int start, int "len")
{
    len = default(len, 1)
    #b = (a==true) ? 1 : 2
    #if (a==true) then b=1 else b=2
    #if (len == 1) then FreezeFrame(clp,start,start,start+1) else FreezeFrame(clp,start,start+len-1,start+len)

    return (len == 1) ? FreezeFrame(clp,start,start,start+1) : FreezeFrame(clp,start,start+len-1,start+len)
}


function rff(clip clp, int start, int "len")
{
    len = default(len, 1)
    return (len == 1) ? FreezeFrame(clp,start,start,start-1) : FreezeFrame(clp,start-len,start,start-len)
}


function mff(clip clp, int frameNumber)
{
    return BadFrames(frameNumber,blend=true)
}


function fs(clip clp, int start, int "lengthPrior",int "lengthPost")
{
    lengthPrior = default(lengthPrior, 1)
    lengthPost = default(lengthPost, 1)
    
    #a=ff(clp,start,lengthPost)
    #b=rff(a,start-1,lengthPrior)
    #return b
    return rff(ff(clp,start,lengthPost),start-1,lengthPrior)
}


function replaceClipFromStart(clip clip1, clip clip2, int start)
{
resultClip = \
    (start==0) ? Eval("""
        clip2 ++ clip1.trim(start+clip2.FrameCount,clip1.FrameCount-1)
    """) : Eval("""
        clip1.trim(0,start-1) ++ clip2 ++ clip1.trim(start+clip2.FrameCount,clip1.FrameCount-1)
    """)
return resultClip
}

#function replaceClipFromStart(clip clip1, clip clip2, int start)
#{
    #len = default(len, 1)
    #b = (a==true) ? 1 : 2
    #if (a==true) then b=1 else b=2
    #if (len == 1) then FreezeFrame(clp,start,start,start+1) else FreezeFrame(clp,start,start+len-1,start+len)

    #clp2=clp2.trim(start,end)
    #return clip1.trim(0,start-1) ++ clip2.trim(start,end) ++ clip1.trim(end+1,clip2.FrameCount-1)
    #a = (len == 1) ? FreezeFrame(clp,start,start,start+1) : FreezeFrame(clp,start,start+len-1,start+len)
    #return a
    
    #clip2TotalLength = clip2.FrameCount
    #start==temp ? return clip1.trim(0,start-1) ++ clip2 : a =1
    #start!=0 ? return clip1.trim(0,start-1) ++ clip2 ++ clip1.trim(start+clip2.FrameCount+1,clip1.FrameCount-1)
#return clip1.trim(0,start-1) ++ clip2 ++ clip1.trim(start+clip2.FrameCount,clip1.FrameCount-1)
    #start==0 ? return clip2 ++ clip1.trim(clip2.FrameCount,clip1.FrameCount-1)
#}


function replaceClipFromEnd(clip clip1, clip clip2, int end)
{
resultClip = \
    (end==clip1.FrameCount) ? Eval("""
        clip1.trim(0,end-clip2.FrameCount-1) ++ clip2
    """) : Eval("""
        clip1.trim(0,end-clip2.FrameCount) ++ clip2 ++ clip1.trim(end+1,clip1.FrameCount-1)
    """)
return resultClip
}


function fclip(clip clip1, clip clip2, int start, int end)
{
resultClip = \
    (start==0) ? Eval("""
        clip2.trim(0,end) ++ clip1.trim(end+1,clip2.FrameCount-1)
    """) : ( \ 
    (end==clip1.FrameCount) ? Eval("""
        clip1.trim(0,start-1) ++ clip2.trim(start,end)
    """) : Eval("""
        clip1.trim(0,start-1) ++ clip2.trim(start,end) ++ clip1.trim(end+1,clip2.FrameCount-1)
    """))
return resultClip
}


function sceneFilter(clip clip1, int frameStart, int frameEnd, string filterGroup)
{
resultClip = \
    (frameStart==0) ? Eval("""
        Apply(filterGroup,clip1.trim(0,frameEnd)) ++ clip1.trim(frameEnd+1,clip1.FrameCount)
    """) : ( \ 
    (frameEnd==clip1.FrameCount) ? Eval("""
        clip1.trim(0,frameStart-1) ++ Apply(filterGroup,clip1.trim(frameStart,clip1.FrameCount-1))
    """) : Eval("""
        clip1.trim(0,frameStart-1) ++ Apply(filterGroup,clip1.trim(frameStart,frameEnd)) ++ clip1.trim(frameEnd+1,clip1.FrameCount-1)
    """))
return resultClip
}


"""
#GScript variant of sceneFilter, (should be possible to rewite the other functions in GScript easily)
Dependency: http://forum.doom9.org/showthread.php?t=147846
GImport("C:\Program Files (x86)\AviSynth\plugins\sceneFilter_GScript.avs")

##sceneFilter_GScript.avs##
function sceneFilter(clip clip1, int frameStart, int frameEnd, string filterGroup)
{
    if (frameStart==0)
    {
        return Apply(filterGroup,clip1.trim(0,frameEnd)) ++ clip1.trim(frameEnd+1,clip1.FrameCount)
    }
    else if (frameEnd==clip1.FrameCount)
    {
        return clip1.trim(0,frameStart-1) ++ Apply(filterGroup,clip1.trim(frameStart,clip1.FrameCount-1))
    }
    else
    {
        return clip1.trim(0,frameStart-1) ++ Apply(filterGroup,clip1.trim(frameStart,frameEnd)) ++ clip1.trim(frameEnd+1,clip1.FrameCount-1)
    }
}
"""


function redoSceneFilter(clip clip1, clip original, int frameStart, int frameEnd, string filterGroup)
{
    fclip(clip1,original,frameStart,frameEnd)
    sceneFilter(frameStart,frameEnd,filterGroup)
}


#It should be possible to define arbitrary shapes by using a more complex mask.
#Dependency: masktools2
function ReplaceBox(clip clp, int "offsetX", int "offsetY", int "width", int "height", int "startFrame", int "endFrame", int "sourceFrame", clip "clip2", bool "show")
{
offsetX= default(offsetX, 0)
offsetY= default(offsetY, 0)
startFrame= default(startFrame, -1)
endFrame= default(endFrame, -1)
sourceFrame= default(sourceFrame, -1)
clip2= default(clip2,clp)
show= default(show, false)

#If sourceFrame was specified, freeze frame over the range specified from clip2
outputClip = (sourceFrame==-1) ? Eval("""
        clip2
    """)  : Eval("""
        clip2.FreezeFrame(startFrame,endFrame,sourceFrame)
    """)

#create mask/white clip
#whiteClip=clp.Levels(255, 10.0, 0, 255, 255,coring=false)

#create debug clip
#blackClip = (show==false) ? Eval("""
#        1
#    """)  : Eval("""
#        clp.Levels(0, 1.0, 255, 0, 0,coring=false)
#    """)

#if show==false return mt_merge(clp,outputClip,whiteClip,w=width,h=height,offX=offsetX,offY=offsetY,luma=true)
#if show==true return mt_merge(clp,blackClip,whiteClip,w=width,h=height,offX=offsetX,offY=offsetY,luma=true)

return (show==false) ? Eval("""
        mt_merge(clp,outputClip,clp.Levels(255, 10.0, 0, 255, 255,coring=false),w=width,h=height,offX=offsetX,offY=offsetY,luma=true)
    """)  : Eval("""
        mt_merge(clp,clp.Levels(0, 1.0, 255, 0, 0,coring=false),clp.Levels(255, 10.0, 0, 255, 255,coring=false),w=width,h=height,offX=offsetX,offY=offsetY,luma=true)
    """)
}

#end functions#
